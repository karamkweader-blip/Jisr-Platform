import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:jisr_platform/core/api/api_exception.dart';

class ApiResponseHandler {
  const ApiResponseHandler._();

  static Map<String, dynamic> handleResponse(
    http.Response response, {
    required ApiOperation operation,
  }) {
    final decoded = _decodeResponseBody(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isNotEmpty && decoded == null) {
        throw ApiException(
          statusCode: response.statusCode,
          operation: operation,
          type: ApiFailureType.invalidResponse,
        );
      }

      return decoded ?? <String, dynamic>{};
    }

    final backendMessage =
        decoded?['message']?.toString().trim() ??
        response.reasonPhrase?.trim() ??
        '';

    throw ApiException(
      statusCode: response.statusCode,
      backendMessage: backendMessage,
      errors: _parseErrors(decoded?['errors']),
      operation: operation,
      type: ApiFailureType.http,
    );
  }

  static ApiException fromError(
    Object error, {
    required ApiOperation operation,
  }) {
    if (error is ApiException) {
      return error;
    }

    if (error is TimeoutException) {
      return ApiException(
        operation: operation,
        type: ApiFailureType.timeout,
        originalError: error,
      );
    }

    if (error is SocketException ||
        error is HandshakeException ||
        error is http.ClientException) {
      return ApiException(
        operation: operation,
        type: ApiFailureType.network,
        originalError: error,
      );
    }

    if (error is FormatException) {
      return ApiException(
        operation: operation,
        type: ApiFailureType.invalidResponse,
        originalError: error,
      );
    }

    return ApiException(
      operation: operation,
      type: ApiFailureType.unknown,
      originalError: error,
    );
  }

  static Map<String, dynamic>? _decodeResponseBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded = jsonDecode(body);

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return <String, dynamic>{
        'data': decoded,
      };
    } catch (_) {
      return null;
    }
  }

  static Map<String, List<String>> _parseErrors(dynamic rawErrors) {
    if (rawErrors is! Map) {
      return const <String, List<String>>{};
    }

    final result = <String, List<String>>{};

    for (final entry in rawErrors.entries) {
      final key = entry.key.toString();
      final value = entry.value;

      if (value is List) {
        final messages = value
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList();

        if (messages.isNotEmpty) {
          result[key] = messages;
        }

        continue;
      }

      final message = value?.toString().trim();

      if (message != null && message.isNotEmpty) {
        result[key] = <String>[message];
      }
    }

    return result;
  }
}