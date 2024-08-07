import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import '../i18n.dart';

final log = Logger('core.models');

class Token {
  final String? access;
  final String? refresh;
  Map<String, dynamic>? raw;
  bool? isValid;
  bool? isExpired;

  Token({
    this.access,
    this.refresh,
    this.isValid,
    this.isExpired,
    this.raw,
  });

  Map<String, dynamic>? getPayloadAccess() {
    var accessParts = access!.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(accessParts[1]))));
  }

  Map<String, dynamic>?  getPayloadRefresh() {
    var refreshParts = refresh!.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(refreshParts[1]))));
  }

  int? getUserPk() {
    var payload = getPayloadAccess()!;
    return payload['user_id'];
  }

  DateTime? getExpAccesss() {
    var payloadAccess = getPayloadAccess();
    if (payloadAccess == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000);
  }

  DateTime? getExpRefresh() {
    var payloadRefresh = getPayloadRefresh();
    if (payloadRefresh == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadRefresh["exp"]*1000);
  }

  void checkIsTokenValid() {
    var accessParts = access!.split(".");
    var refreshParts = refresh!.split(".");

    if(accessParts.length !=3 || refreshParts.length != 3) {
      isValid = false;
    } else {
      isValid = true;
    }
  }

  void checkIsTokenExpired() {
    var payloadAccess = getPayloadAccess();
    if (payloadAccess == null) {
      isExpired = true;
      return;
    }

    if(DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000).isAfter(DateTime.now())) {
      isExpired = false;
    } else {
      isExpired = true;
    }
  }

  factory Token.fromJson(Map<String, dynamic> parsedJson) {
    return Token(
      access: parsedJson['access'],
      refresh: parsedJson['refresh'],
      raw: parsedJson,
    );
  }
}

class SlidingToken {
  final String? token;
  Map<String, dynamic>? raw;
  bool? isValid;
  bool? isExpired;

  SlidingToken({
    this.token,
    this.isValid,
    this.isExpired,
    this.raw,
  });

  Map<String, dynamic>? getPayload() {
    var parts = token!.split(".");
    return json.decode(ascii.decode(base64.decode(base64.normalize(parts[1]))));
  }

  int? getUserPk() {
    var payload = getPayload()!;
    return payload['user_id'];
  }

  DateTime? getExp() {
    var payloadAccess = getPayload();
    if (payloadAccess == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadAccess["exp"]*1000);
  }

  void checkIsTokenValid() {
    var parts = token!.split(".");
    isValid = parts.length == 3 ? true : false;
  }

  void checkIsTokenExpired() {
    var payload = getPayload();
    if (payload == null) {
      isExpired = true;
      return;
    }
    log.info(payload);

    var expires = DateTime.fromMillisecondsSinceEpoch(payload["exp"]*1000);
    log.info('expires: $expires');

    if(expires.isAfter(DateTime.now())) {
      isExpired = false;
    } else {
      isExpired = true;
    }
  }

  factory SlidingToken.fromJson(Map<String, dynamic> parsedJson) {
    return SlidingToken(
      token: parsedJson['token'],
      raw: parsedJson,
    );
  }
}

class DefaultPageData {
  final String? memberPicture;
  final Widget? drawer;

  DefaultPageData({
    this.memberPicture,
    this.drawer
  });
}

class PaginationInfo {
  final int? count;
  final String? next;
  final String? previous;
  final int? currentPage;
  final int? pageSize;

  void debug() {
    log.info('count: $count, next: $next, previous: $previous, currentPage: $currentPage, pageSize: $pageSize');
  }

  PaginationInfo({
    this.count,
    this.next,
    this.previous,
    this.currentPage,
    this.pageSize
  });

  String getTitle($trans) {
    String title = "";
    if (count! > pageSize!) {
      int start =
          ((currentPage! - 1) * pageSize!) + 1;
      int? end = start + pageSize! <= count!
          ? start + pageSize! - 1
          : count;
      Map<String, String> namedArgs = {
        "start": "$start",
        "end": "$end",
        "total": "$count",
        "modelName": $trans("model_name")
      };

      title = My24i18n.tr("generic.pagination_more_pages", namedArgs: namedArgs);
    } else {
      int start = count! > 0 ? 1 : 0;
      int? end = count;
      Map<String, String> namedArgs = {
        "start": "$start",
        "end": "$end",
        "pageSize": "$pageSize",
        "modelName": $trans("model_name")
      };
      title = My24i18n.tr("generic.pagination_one_page", namedArgs: namedArgs);
    }

    return title;
  }
}

class SimpleAddress {
  String? street;
  String? postal;
  String? city;
  String? countryCode;

  SimpleAddress({
    this.street,
    this.postal,
    this.city,
    this.countryCode
  });

  factory SimpleAddress.fromJson(Map<String, dynamic> parsedJson) {
    return SimpleAddress(
      street: parsedJson['street'],
      postal: parsedJson['postal'],
      city: parsedJson['city'],
      countryCode: parsedJson['country_code'],
    );
  }

}
