library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exceptions.dart';
import 'api_response.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() => _instance;

  ApiClient._internal();

  final http.Client _client = http.Client();
  final GetStorage _storage = GetStorage();

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userKey = 'user_data';

  String? get authToken => _storage.read(tokenKey);

  set authToken(String? token) {
    if (token != null) {
      _storage.write(tokenKey, token);
    } else {
      _storage.remove(tokenKey);
    }
  }

  String? get refreshToken => _storage.read(refreshTokenKey);

  set refreshToken(String? token) {
    if (token != null) {
      _storage.write(refreshTokenKey, token);
    } else {
      _storage.remove(refreshTokenKey);
    }
  }

  bool get isAuthenticated => authToken != null;

  void clearTokens() {
    _storage.remove(tokenKey);
    _storage.remove(refreshTokenKey);
    _storage.remove(userKey);
  }

  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (authToken != null) {
      headers['Authorization'] = 'Bearer $authToken';
    }

    return headers;
  }

  // ============ HTTP METHODS ============

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic json)? parser,
  }) async {
    return _request<T>(
      method: 'GET',
      endpoint: endpoint,
      queryParams: queryParams,
      parser: parser,
    );
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) async {
    return _request<T>(
      method: 'POST',
      endpoint: endpoint,
      body: body,
      parser: parser,
    );
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) async {
    return _request<T>(
      method: 'PUT',
      endpoint: endpoint,
      body: body,
      parser: parser,
    );
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
  }) async {
    return _request<T>(
      method: 'DELETE',
      endpoint: endpoint,
      body: body,
      parser: parser,
    );
  }

  /// Upload file (multipart/form-data)
  Future<ApiResponse<T>> uploadFile<T>(
    String endpoint,
    String filePath, {
    String fileFieldName = 'file',
    Map<String, String>? additionalFields,
    T Function(dynamic json)? parser,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final file = File(filePath);

      if (!file.existsSync()) {
        throw ApiException('File not found: $filePath');
      }

      // Create multipart request
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_headers);
      if (authToken != null) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }

      // Add file
      request.files.add(
        http.MultipartFile(
          fileFieldName,
          file.readAsBytes().asStream(),
          file.lengthSync(),
          filename: file.path.split('/').last,
        ),
      );

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      // Log request
      debugPrint('┌──────────────────────────────────────────');
      debugPrint('│ FILE UPLOAD REQUEST');
      debugPrint('│ POST: $uri');
      debugPrint('│ File: $filePath');
      debugPrint('└──────────────────────────────────────────');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log response
      _logResponse(response);

      // Handle response
      return _handleResponse<T>(response, parser);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      throw TimeoutException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Upload error: $e');
    }
  }

  // ============ CORE REQUEST METHOD ============
  Future<ApiResponse<T>> _request<T>({
    required String method,
    required String endpoint,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? body,
    T Function(dynamic json)? parser,
    int retryCount = 0,
  }) async {
    try {
      // Build URI
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint').replace(
        queryParameters: queryParams?.map(
          (key, value) => MapEntry(key, value.toString()),
        ),
      );

      // Log request
      _logRequest(method, uri, body);

      // Make request
      http.Response response;

      switch (method) {
        case 'GET':
          response = await _client
              .get(uri, headers: _headers)
              .timeout(ApiConfig.connectionTimeout);
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: _headers, body: jsonEncode(body))
              .timeout(ApiConfig.connectionTimeout);
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: _headers, body: jsonEncode(body))
              .timeout(ApiConfig.connectionTimeout);
          break;
        case 'DELETE':
          response = await _client
              .delete(uri, headers: _headers, body: jsonEncode(body))
              .timeout(ApiConfig.connectionTimeout);
          break;
        default:
          throw ApiException('Unsupported HTTP method: $method');
      }

      // Log response
      _logResponse(response);

      // Handle response
      return _handleResponse<T>(response, parser);
    } on SocketException {
      throw NetworkException();
    } on TimeoutException {
      // Retry logic
      if (ApiConfig.enableRetry && retryCount < ApiConfig.maxRetryAttempts) {
        await Future.delayed(Duration(seconds: retryCount + 1));
        return _request<T>(
          method: method,
          endpoint: endpoint,
          queryParams: queryParams,
          body: body,
          parser: parser,
          retryCount: retryCount + 1,
        );
      }
      throw TimeoutException();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Unexpected error: $e');
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response,
    T Function(dynamic json)? parser,
  ) {
    final statusCode = response.statusCode;
    dynamic jsonBody;

    try {
      jsonBody = jsonDecode(response.body);
    } catch (_) {
      jsonBody = response.body;
    }

    // Success responses (200-299)
    if (statusCode >= 200 && statusCode < 300) {
      final data = parser != null ? parser(jsonBody) : jsonBody as T;
      return ApiResponse.success(
        data,
        message: jsonBody is Map ? jsonBody['message'] : null,
        statusCode: statusCode,
      );
    }

    // Error responses
    final message = jsonBody is Map
        ? jsonBody['message'] ?? 'Request failed'
        : 'Request failed';
    final errors = jsonBody is Map ? jsonBody['errors'] : null;

    switch (statusCode) {
      case 401:
        clearTokens();
        throw UnauthorizedException(message);
      case 404:
        throw NotFoundException(message);
      case 422:
        throw ValidationException(message, errors: errors);
      case 500:
      case 502:
      case 503:
        throw ServerException(message, statusCode);
      default:
        throw ApiException(message, statusCode: statusCode, data: jsonBody);
    }
  }

  // ============ LOGGING ============
  void _logRequest(String method, Uri uri, Map<String, dynamic>? body) {
    if (!ApiConfig.enableLogging || !kDebugMode) return;

    debugPrint('┌──────────────────────────────────────────');
    debugPrint('│ API REQUEST');
    debugPrint('│ $method: $uri');
    if (body != null) {
      debugPrint('│ Body: ${jsonEncode(body)}');
    }
    debugPrint('└──────────────────────────────────────────');
  }

  void _logResponse(http.Response response) {
    if (!ApiConfig.enableLogging || !kDebugMode) return;

    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
    final emoji = isSuccess ? '✅' : '❌';

    debugPrint('┌──────────────────────────────────────────');
    debugPrint('│ $emoji API RESPONSE');
    debugPrint('│ Status: ${response.statusCode}');
    debugPrint(
      '│ Body: ${response.body.length > 500 ? '${response.body.substring(0, 500)}...' : response.body}',
    );
    debugPrint('└──────────────────────────────────────────');
  }

  // ============ CLEANUP ============
  void dispose() {
    _client.close();
  }
}
