import 'dart:convert';
import 'dart:io' show Directory, Platform;
import 'dart:io' as io;

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:logging/logging.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:url_launcher/url_launcher.dart';

import 'api/api_mixin.dart';
import 'models/models.dart';

final log = Logger('core.utils');

class CoreUtils with CoreApiMixin {

  // default and settable for tests
  http.Client _httpClient = http.Client();
  set httpClient(http.Client client) {
    _httpClient = client;
  }

  Future<String> getBaseUrl() async {
    return getBaseUrlPrefs();
  }

  String formatDate(DateTime date) {
    return "${date.toLocal()}".split(' ')[0];
  }

  String formatDateDDMMYYYY(DateTime date) {
    return DateFormat("d/M/y").format(date);
  }

  String formatTime(DateTime time) {
    return '$time'.split(' ')[1];
  }

  String timeNoSeconds(String? time) {
    if (time != null) {
      List parts = time.split(':');
      return "${parts[0]}:${parts[1]}";
    }
    return "-";
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  double round(double num) {
    return (num * 100).round() / 100;
  }

  Locale? lang2locale(String? lang) {
    if (lang == 'nl') {
      return const Locale('nl', 'NL');
    }

    if (lang == 'en') {
      return const Locale('en', 'US');
    }

    return null;
  }

  Future<bool> isLoggedInSlidingToken() async {
    // refresh token
    SlidingToken? newToken = await refreshSlidingToken(_httpClient);

    if(newToken == null) {
      return false;
    }

    return true;
  }

  Future<SlidingToken?> attemptLogIn(String username, String password) async {
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    final url = await getUrl('/jwt-token/');
    final res = await _httpClient.post(
        Uri.parse(url),
        body: json.encode({
          "username": username,
          "password": password
        }),
      headers: allHeaders
    );

    if (res.statusCode == 200) {
      SlidingToken token = SlidingToken.fromJson(json.decode(res.body));
      token.checkIsTokenExpired();

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token.token!);

      return token;
    }

    return null;
  }

  Future<String?> createStreamPrivateChannel(String toUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    final url = await getUrl('/company/stream-private-channel-create/');
    final token = prefs.getString('token');
    final authHeaders = getHeaders(token);
    Map<String, String> allHeaders = {"Content-Type": "application/json; charset=UTF-8"};
    allHeaders.addAll(authHeaders);
    final res = await _httpClient.post(
        Uri.parse(url),
        body: json.encode(<String, String>{"to_member_user_id": toUserId}),
        headers: allHeaders
    );

    if (res.statusCode == 200) {
      var responseData = json.decode(res.body);
      if (responseData["error"] != null) {
        throw Exception(res.body);
      }

      return responseData["created"];
    }

    return null;
  } //


  Future<String?> getUserSubmodel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString('submodel');
  }

  Future<void> requestFCMPermissions() async {
    // request permissions
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('fcm_allowed')) {
      bool isAllowed = false;

      if (Platform.isAndroid) {
        isAllowed = true;
      } else {
        await Firebase.initializeApp();
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          sound: true,
          announcement: false,
          badge: false,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
        );

        // are we allowed?
        if (settings.authorizationStatus == AuthorizationStatus.authorized) {
          isAllowed = true;
        }
      }

      prefs.setBool('fcm_allowed', isAllowed);

      if (isAllowed) {
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          log.info('Got a message whilst in the foreground!');
          log.info('Message data: ${message.data}');

          if (message.notification != null) {
            log.info('Message also contained a notification: ${message.notification}');
          }
        });
      }
    }
  }

  Future<String?> getOrderListTitleForUser() async {
    String? submodel = await getUserSubmodel();

    if (submodel == 'customer_user') {
      return 'orders.list.app_title_customer_user'.tr();
    }

    if (submodel == 'planning_user') {
      return 'orders.list.app_title_planning_user'.tr();
    }

    if (submodel == 'sales_user') {
      return 'orders.list.app_title_sales_user'.tr();
    }

    if (submodel == 'branch_employee_user') {
      return 'orders.list.app_title_employee_user'.tr();
    }

    return null;
  }

  Future<Map<String, dynamic>> openDocument(url) async {
    final file = await DefaultCacheManager().getSingleFile(url);
    final Directory tmpDir = io.Platform.isAndroid ? (await getExternalStorageDirectory())! : await getTemporaryDirectory();
    final tmpFilePath = "${tmpDir.absolute.path}/${file.basename}";
    file.copySync(tmpFilePath);

    if (!io.File(tmpFilePath).existsSync()) {
      log.info('file $tmpFilePath does not EXIST hellup');
      return {
        'result': false,
        'message': 'file does not exist'
      };
    }

    try {
      await OpenFilex.open(tmpFilePath);
    } catch (e) {
      log.info("Error in OpenFilex: $e");
      return {
        'message': "generic.error",
        'result': false,
      };
    }

    return {
      'result': true,
    };
  }

  launchURL(String url) async {
    if (url == '') {
      return;
    }

    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  /// Calculates number of weeks for a given year as per https://en.wikipedia.org/wiki/ISO_week_date#Weeks_per_year
  int numOfWeeks(int year) {
    DateTime dec28 = DateTime(year, 12, 28);
    int dayOfDec28 = int.parse(DateFormat("D").format(dec28));
    return ((dayOfDec28 - dec28.weekday + 10) / 7).floor();
  }

  /// Calculates week number from a date as per https://en.wikipedia.org/wiki/ISO_week_date#Calculation
  int weekNumber(DateTime date) {
    int dayOfYear = int.parse(DateFormat("D").format(date));
    int woy =  ((dayOfYear - date.weekday + 10) / 7).floor();
    if (woy < 1) {
      woy = numOfWeeks(date.year - 1);
    } else if (woy > numOfWeeks(date.year)) {
      woy = 1;
    }
    return woy;
  }

  DateTime getMonday() {
    var today = DateTime.now();
    // if it's sunday, use next day as start date
    if (today.weekday == DateTime.sunday) {
      return today.add(const Duration(days: 1));
    }

    if (today.weekday == 1) {
      return today;
    }

    return today.subtract(Duration(days: today.weekday - 1));
  }

}

CoreUtils coreUtils = CoreUtils();
