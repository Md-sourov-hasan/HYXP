import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:hawiisaac/core/utils/logging/logger.dart';
import 'package:hawiisaac/features/authentication/services/auth_exception.dart';

class AuthApiClient {
  const AuthApiClient();

  Future<Map<String, dynamic>> putMultipart({
    required String url,
    required Map<String, String> fields,
    required String logLabel,
    MultipartFilePayload? file,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestMultipart(
      method: 'PUT',
      url: url,
      fields: fields,
      file: file,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<Map<String, dynamic>> patchMultipart({
    required String url,
    required Map<String, String> fields,
    required String logLabel,
    MultipartFilePayload? file,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestMultipart(
      method: 'PATCH',
      url: url,
      fields: fields,
      file: file,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<Map<String, dynamic>> postForm({
    required String url,
    required Map<String, String> body,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    return requestForm(
      method: 'POST',
      url: url,
      body: body,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );
  }

  Future<Map<String, dynamic>> postJson({
    required String url,
    required Map<String, dynamic> body,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestJson(
      method: 'POST',
      url: url,
      logLabel: logLabel,
      jsonBody: body,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<Map<String, dynamic>> putJson({
    required String url,
    required Map<String, dynamic> body,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestJson(
      method: 'PUT',
      url: url,
      logLabel: logLabel,
      jsonBody: body,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<Map<String, dynamic>> patchJson({
    required String url,
    required Map<String, dynamic> body,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestJson(
      method: 'PATCH',
      url: url,
      logLabel: logLabel,
      jsonBody: body,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<Map<String, dynamic>> putForm({
    required String url,
    required Map<String, String> body,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    return requestForm(
      method: 'PUT',
      url: url,
      body: body,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );
  }

  Future<Map<String, dynamic>> get({
    required String url,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    return requestForm(
      method: 'GET',
      url: url,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );
  }

  Future<List<dynamic>> getList({
    required String url,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestJson(
      method: 'GET',
      url: url,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is List<dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid list response received from the server.',
      statusCode: 0,
    );
  }

  Future<Map<String, dynamic>> delete({
    required String url,
    required String logLabel,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    return requestForm(
      method: 'DELETE',
      url: url,
      logLabel: logLabel,
      headers: headers,
      showDebugLog: showDebugLog,
    );
  }

  Future<Map<String, dynamic>> requestForm({
    required String method,
    required String url,
    required String logLabel,
    Map<String, String>? body,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final data = await requestJson(
      method: method,
      url: url,
      logLabel: logLabel,
      formBody: body,
      headers: headers,
      showDebugLog: showDebugLog,
    );

    if (data is Map<String, dynamic>) {
      return data;
    }

    throw const AuthException(
      message: 'Invalid response received from the server.',
      statusCode: 0,
    );
  }

  Future<dynamic> requestJson({
    required String method,
    required String url,
    required String logLabel,
    Map<String, String>? formBody,
    Map<String, dynamic>? jsonBody,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final client = HttpClient();
    final shouldPrintDebugLog = showDebugLog || kDebugMode;

    try {
      final request = await client.openUrl(method, Uri.parse(url));
      final requestBody = formBody?.entries
          .map(
            (entry) => '${entry.key}=${Uri.encodeQueryComponent(entry.value)}',
          )
          .join('&');
      final encodedJsonBody = jsonBody == null ? null : jsonEncode(jsonBody);

      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (requestBody != null) {
        request.headers.set(
          HttpHeaders.contentTypeHeader,
          'application/x-www-form-urlencoded',
        );
      }
      if (encodedJsonBody != null) {
        request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      }

      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }

      if (shouldPrintDebugLog) {
        AppLoggerHelper.debug('$logLabel API request: $method $url');
        AppLoggerHelper.debug(
          '$logLabel API headers: ${_sanitizeHeaders(headers)}',
        );
      }
      if (formBody != null) {
        if (shouldPrintDebugLog) {
          AppLoggerHelper.debug('$logLabel API body: $formBody');
        }
        final formBytes = utf8.encode(requestBody ?? '');
        request.contentLength = formBytes.length;
        request.add(formBytes);
      }
      if (encodedJsonBody != null) {
        if (shouldPrintDebugLog) {
          AppLoggerHelper.debug('$logLabel API body: $encodedJsonBody');
        }
        final encodedBytes = utf8.encode(encodedJsonBody);
        request.contentLength = encodedBytes.length;
        request.add(encodedBytes);
      }

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final dynamic data = responseBody.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(responseBody);

      AppLoggerHelper.info('$logLabel API status code: ${response.statusCode}');
      if (shouldPrintDebugLog) {
        AppLoggerHelper.debug(
          '$logLabel API status code: ${response.statusCode}',
        );
        AppLoggerHelper.debugLong('$logLabel API response: $responseBody');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final errorData = data is Map<String, dynamic>
          ? data
          : <String, dynamic>{};
      final errorMessage = _extractErrorMessage(errorData);
      AppLoggerHelper.error(
        '$logLabel API failed: status=${response.statusCode}, '
        'message=$errorMessage, url=$url',
        responseBody,
      );
      throw AuthException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    } on SocketException catch (error) {
      AppLoggerHelper.error(
        '$logLabel API network failure: method=$method, url=$url',
        error,
      );
      throw const AuthException(
        message: 'Unable to connect to the server. Please try again.',
        statusCode: 0,
      );
    } on FormatException catch (error) {
      AppLoggerHelper.error(
        '$logLabel API invalid response: method=$method, url=$url',
        error,
      );
      throw const AuthException(
        message: 'Invalid response received from the server.',
        statusCode: 0,
      );
    } catch (error) {
      AppLoggerHelper.error('$logLabel API failed', error);
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  Future<dynamic> requestMultipart({
    required String method,
    required String url,
    required Map<String, String> fields,
    required String logLabel,
    MultipartFilePayload? file,
    Map<String, String> headers = const <String, String>{},
    bool showDebugLog = false,
  }) async {
    final client = HttpClient();
    final shouldPrintDebugLog = showDebugLog || kDebugMode;
    final boundary = _multipartBoundary();

    try {
      final request = await client.openUrl(method, Uri.parse(url));
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'multipart/form-data; boundary=$boundary',
      );

      for (final entry in headers.entries) {
        request.headers.set(entry.key, entry.value);
      }

      if (shouldPrintDebugLog) {
        AppLoggerHelper.debug('$logLabel API request: $method $url');
        AppLoggerHelper.debug(
          '$logLabel API headers: ${_sanitizeHeaders(headers)}',
        );
        AppLoggerHelper.debug(
          '$logLabel API fields: $fields, hasFile=${file != null}',
        );
      }

      final builder = BytesBuilder(copy: false);
      void writeUtf8(String value) => builder.add(utf8.encode(value));

      for (final entry in fields.entries) {
        writeUtf8('--$boundary\r\n');
        writeUtf8(
          'Content-Disposition: form-data; name="${entry.key}"\r\n\r\n',
        );
        writeUtf8(entry.value);
        writeUtf8('\r\n');
      }

      if (file != null) {
        final fileBytes = await File(file.path).readAsBytes();
        writeUtf8('--$boundary\r\n');
        writeUtf8(
          'Content-Disposition: form-data; name="${file.fieldName}"; '
          'filename="${file.fileName}"\r\n',
        );
        writeUtf8('Content-Type: ${file.contentType}\r\n\r\n');
        builder.add(fileBytes);
        writeUtf8('\r\n');
      }

      writeUtf8('--$boundary--\r\n');
      final payloadBytes = builder.takeBytes();
      request.contentLength = payloadBytes.length;
      request.add(payloadBytes);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      final dynamic data = responseBody.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(responseBody);

      AppLoggerHelper.info('$logLabel API status code: ${response.statusCode}');
      if (shouldPrintDebugLog) {
        AppLoggerHelper.debug(
          '$logLabel API status code: ${response.statusCode}',
        );
        AppLoggerHelper.debug('$logLabel API response: $responseBody');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      }

      final errorData = data is Map<String, dynamic>
          ? data
          : <String, dynamic>{};
      final errorMessage = _extractErrorMessage(errorData);
      AppLoggerHelper.error(
        '$logLabel API failed: status=${response.statusCode}, '
        'message=$errorMessage, url=$url',
        responseBody,
      );
      throw AuthException(
        message: errorMessage,
        statusCode: response.statusCode,
      );
    } on SocketException catch (error) {
      AppLoggerHelper.error(
        '$logLabel API network failure: method=$method, url=$url',
        error,
      );
      throw const AuthException(
        message: 'Unable to connect to the server. Please try again.',
        statusCode: 0,
      );
    } on FormatException catch (error) {
      AppLoggerHelper.error(
        '$logLabel API invalid response: method=$method, url=$url',
        error,
      );
      throw const AuthException(
        message: 'Invalid response received from the server.',
        statusCode: 0,
      );
    } catch (error) {
      AppLoggerHelper.error('$logLabel API failed', error);
      rethrow;
    } finally {
      client.close(force: true);
    }
  }

  String _extractErrorMessage(Map<String, dynamic> data) {
    final detail = data['detail'];
    final message = data['message'];

    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    if (detail is List) {
      for (final item in detail) {
        if (item is Map<String, dynamic>) {
          final nestedMessage = item['msg']?.toString().trim() ?? '';
          if (nestedMessage.isNotEmpty) {
            return nestedMessage;
          }
        }

        final itemMessage = item.toString().trim();
        if (itemMessage.isNotEmpty) {
          return itemMessage;
        }
      }
    }

    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final fieldErrors = <String>[];
    for (final entry in data.entries) {
      final value = entry.value;
      if (value is List && value.isNotEmpty) {
        final firstError = value.first.toString().trim();
        if (firstError.isNotEmpty) {
          fieldErrors.add('${entry.key}: $firstError');
        }
      } else if (value is String && value.trim().isNotEmpty) {
        fieldErrors.add('${entry.key}: ${value.trim()}');
      }
    }

    if (fieldErrors.isNotEmpty) {
      return fieldErrors.join('\n');
    }

    return 'Request failed. Please check your information and try again.';
  }

  Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    return {
      for (final entry in headers.entries)
        entry.key: _isSensitiveHeader(entry.key)
            ? _maskValue(entry.value)
            : entry.value,
    };
  }

  bool _isSensitiveHeader(String key) {
    final normalized = key.trim().toLowerCase();
    return normalized == HttpHeaders.authorizationHeader ||
        normalized == 'refresh-token' ||
        normalized.contains('token') ||
        normalized.contains('secret');
  }

  String _maskValue(String value) {
    if (value.isEmpty) return value;
    if (value.length <= 10) return '***';
    return '${value.substring(0, 6)}...${value.substring(value.length - 4)}';
  }

  String _multipartBoundary() {
    final timestamp = DateTime.now().microsecondsSinceEpoch;
    final random = Random().nextInt(1 << 32);
    return 'codex-boundary-$timestamp-$random';
  }
}

class MultipartFilePayload {
  const MultipartFilePayload({
    required this.fieldName,
    required this.path,
    required this.fileName,
    required this.contentType,
  });

  final String fieldName;
  final String path;
  final String fileName;
  final String contentType;
}
