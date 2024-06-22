import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_mixin.dart';
import '../models/models.dart';
import '../models/base_models.dart';

final log = Logger('core.base_crud');

abstract class BaseCrud<T extends BaseModel, U extends BaseModelPagination> with CoreApiMixin {
  final String basePath = "";
  set basePath(String path) {
    this.basePath = path;
  }

  http.Client httpClient = http.Client();

  U fromJsonList(Map<String, dynamic>? parsedJson);
  T fromJsonDetail(Map<String, dynamic>? parsedJson);

  Future<U> list({Map<String, dynamic>? filters, String? basePathAddition,
    http.Client? httpClientOverride, bool needsAuth=true}) async {
    final String responseBody = await getListResponseBody(
        filters: filters, basePathAddition: basePathAddition,
      httpClientOverride: httpClientOverride, needsAuth: needsAuth
    );
    return fromJsonList(json.decode(responseBody));
  }

  Future<String> getListResponseBody({Map<String, dynamic>? filters,
    String? basePathAddition, http.Client? httpClientOverride,
    bool needsAuth=true
  }) async {
    var client = httpClientOverride ?? httpClient;

    Map<String, String> headers = {};
    if (needsAuth) {
      SlidingToken newToken = await getNewToken(httpClientOverride: client);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? token = prefs.getString('token');
      log.info('getListResponseBody after getNewToken: newToken: ${newToken.token}');
      headers = {'Authorization': 'Bearer $token'};
      log.info('headers token length by hand: ${"Bearer ${newToken.token}".length}');
      // log.info('headers token from prefs: ${"Bearer $token".length}');
    }

    // List<String> args = ["page_size=5"];
    List<String> args = [];
    if (filters != null) {
      for (String key in filters.keys) {
        if (filters[key] != null || (key == 'q' && filters[key] != "" && filters[key] != null)) {
          args.add("$key=${filters[key]}");
        }
      }
    }

    String url = await getUrl(basePath);
    if (basePathAddition != null) {
      url = "$url/$basePathAddition";
    }

    // print('url.substring ${url.substring(url.length-1)}');
    if (url.substring(url.length-1) == '/') {
      url = url.substring(0, url.length-1);
    }

    if (args.isNotEmpty) {
      url = "$url/?${args.join('&')}";
    } else {
      url = "$url/";
    }

    log.info('getListResponseBody: $url, client: $client, headers: $headers');
    log.info('headers token length: ${headers["Authorization"]!.length}');
    log.info('headers token: ${headers["Authorization"]}');

    final response = await client.get(
        Uri.parse(url),
        headers: headers
    );

    if (response.statusCode == 200) {
      return response.body;
    }
    //print(response.body);

    String msg = "fetch: (${response.body})";
    log.severe('error in fetch, url=$url');

    throw Exception(msg);
  }

  Future<T> detail(dynamic pk, {String? basePathAddition, bool needsAuth=true}) async {
    Map<String, String> headers = {};
    if (needsAuth) {
      SlidingToken newToken = await getNewToken();
      headers = getHeaders(newToken.token);
    }

    String url = pk != null ? await getUrl('$basePath/$pk/') : await getUrl('$basePath/');
    if (basePathAddition != null) {
      url = "$url$basePathAddition";
    }
    log.info('detail: $url, client: $httpClient');

    final response = await httpClient.get(
        Uri.parse(url),
        headers: headers
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    String msg = "fetch detail: (${response.body})";

    throw Exception(msg);
  }

  Future<T> insert(BaseModel model) async {
    SlidingToken newToken = await getNewToken(httpClientOverride: httpClient);

    final url = await getUrl('$basePath/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(newToken.token));
    log.info('insert: $url, client: $httpClient');

    final response = await httpClient.post(
      Uri.parse(url),
      body: model.toJson(),
      headers: allHeaders,
    );

    if (response.statusCode == 201) {
      return fromJsonDetail(json.decode(response.body));
    }

    String msg = "insert: (${response.body})";

    throw Exception(msg);
  }

  Future<dynamic> insertCustom(Map data, String basePathAddition, {bool returnTypeBool = true}) async {
    // insert custom data within the base URL
    SlidingToken newToken = await getNewToken(httpClientOverride: httpClient);

    final url = await getUrl('$basePath/$basePathAddition');

    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(newToken.token));
    log.info('insertCustom: $url, client: $httpClient');

    // print(data);
    final response = await httpClient.post(
      Uri.parse(url),
      body: json.encode(data),
      headers: allHeaders,
    );

    // print(response.body);

    if (response.statusCode == 200) {
      if (returnTypeBool) {
        return true;
      }

      return json.decode(response.body);
    }

    if (returnTypeBool) {
      return false;
    }

    return json.decode(response.body);
  }

  Future<T> update(int pk, BaseModel model) async {
    SlidingToken newToken = await getNewToken(httpClientOverride: httpClient);

    final url = await getUrl('$basePath/$pk/');
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(getHeaders(newToken.token));
    log.info('update: $url, client: $httpClient');

    final response = await httpClient.patch(
      Uri.parse(url),
      body: model.toJson(),
      headers: allHeaders,
    );

    if (response.statusCode == 200) {
      return fromJsonDetail(json.decode(response.body));
    }

    String msg = "update: (${response.body})";
    throw Exception(msg);
  }

  Future<bool> delete(int pk) async {
    SlidingToken newToken = await getNewToken(httpClientOverride: httpClient);

    final url = await getUrl('$basePath/$pk/');
    log.info('delete: $url, client: $httpClient');

    final response = await httpClient.delete(
        Uri.parse(url),
        headers: getHeaders(newToken.token)
    );

    if (response.statusCode == 204) {
      return true;
    }

    String msg = "delete: (${response.body})";
    throw Exception(msg);
  }

  Future<SlidingToken> getNewToken({http.Client? httpClientOverride}) async {
    var client = httpClientOverride ?? httpClient;
    SlidingToken? newToken = await refreshSlidingToken(client);

    if(newToken == null) {
      throw Exception('Token expired');
    }

    return newToken;
  }
}
