import 'dart:convert';

import 'package:appstore_connect/src/model/model.dart';
import 'package:appstore_connect/src/token.dart';
import 'package:http/http.dart';

extension AppStoreConnectUri on Uri {
  static Uri v1({String? resource = ''}) {
    return Uri.parse('https://api.appstoreconnect.apple.com/v1/$resource');
  }

  static Uri v2({String? resource = ''}) {
    return Uri.parse('https://api.appstoreconnect.apple.com/v2/$resource');
  }
}

class AppStoreConnectCredentials {
  final String keyId;
  final String issuerId;
  final String keyFile;

  const AppStoreConnectCredentials({
    required this.keyId,
    required this.issuerId,
    required this.keyFile,
  });
}

class AppStoreConnectClient {
  final AppStoreConnectCredentials _credentials;
  final Client _client = Client();

  AppStoreConnectToken? _token;

  AppStoreConnectClient(this._credentials);

  Future<ApiResponse> get(GetRequest request) async {
    return _handle(_client.get(
      request.toUri(),
      headers: await _getHeaders(),
    ));
  }

  Future<ApiResponse> post(Uri uri, Map<String, dynamic> body) async {
    return _handle(_client.post(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(body),
    ));
  }

  Future<T> postModel<T extends Model>(
    Uri baseUri,
    String type, {
    ModelAttributes? attributes,
    Map<String, ModelRelationship>? relationships,
  }) async {
    final response = await post(Uri.parse(baseUri.toString() + '$type'), {
      'data': {
        'type': type,
        if (attributes != null) //
          'attributes': attributes.toMap()..removeWhere((_, value) => value == null),
        if (relationships != null) //
          'relationships': relationships.map((key, value) => MapEntry(key, {'data': value.toMap()}))
      }
    });
    return response.as<T>();
  }

  Future<ApiResponse> patch(String path, Map<String, dynamic> data) async {
  Future<ApiResponse> patch(Uri uri, Map<String, dynamic> data) async {
    return _handle(_client.patch(
      uri,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    ));
  }

  Future<T> patchModel<T extends Model>(
    Uri baseUri,
    String type,
    String id, {
    ModelAttributes? attributes,
    Map<String, ModelRelationship>? relationships,
  }) async {
    final response = await patch(Uri.parse(baseUri.toString() + '$type/$id'), {
      'data': {
        'type': type,
        'id': id,
        if (attributes != null) //
          'attributes': attributes.toMap()..removeWhere((_, value) => value == null),
        if (relationships != null) //
          'relationships': relationships.map((key, value) => MapEntry(key, {'data': value.toMap()}))
      }
    });
    return response.as<T>();
  }

  Future<void> delete(Uri uri) async {
    await _handle(_client.delete(
      uri,
      headers: await _getHeaders(),
    ));
  }

  Uri _getUri(String path) => Uri.parse(_apiUri + path);

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${token.value}',
    };
  }

  Future<AppStoreConnectToken> _getToken() async {
    return _token ??= await AppStoreConnectToken.fromFile(
      keyId: _credentials.keyId,
      issuerId: _credentials.issuerId,
      path: _credentials.keyFile,
    );
  }

  Future<ApiResponse> _handle(Future<Response> operation) async {
    final response = await operation;
    if (response.statusCode >= 200 && response.statusCode <= 299) {
      return ApiResponse(this, response);
    } else {
      throw ApiException.fromResponse(response);
    }
  }
}

class GetRequest {
  final Uri _uri;
  final Map<String, dynamic> _filters = {};
  final Set<String> _includes = {};
  final Map<String, String> _fields = {};
  final Map<String, int> _limits = {};
  final Map<String, bool> _sort = {};
  int? _limit;

  GetRequest(this._uri);

  void filter(String field, dynamic value) {
    _filters[field] = value is Iterable ? value.map((item) => item.toString()).join(',') : value;
  }

  void include(String type, {List<String>? fields, int? limit}) {
    _includes.add(type);
    if (fields != null) {
      _fields[type] = fields.join(',');
    }
    if (limit != null) {
      _limits[type] = limit;
    }
  }

  void sort(String field, {bool descending = false}) {
    _sort[field] = descending;
  }

  void limit(int limit) {
    _limit = limit;
  }

  Uri toUri() {
    final params = <String, dynamic>{
      for (final filter in _filters.entries) //
        'filter[${filter.key}]': filter.value,
      if (_includes.isNotEmpty) //
        'include': _includes.join(','),
      for (final fields in _fields.entries) //
        'fields[${fields.key}]': fields.value,
      for (final limit in _limits.entries) //
        'limit[${limit.key}]': limit.value.toString(),
      if (_sort.isNotEmpty) //
        'sort': _sort.entries.map((entry) => '${entry.value ? '-' : ''}${entry.key}').join(','),
      if (_limit != null) //
        'limit': _limit.toString(),
    };

    return (_uri).replace(queryParameters: params);
  }
}

class ApiResponse {
  final AppStoreConnectClient _client;
  final Response _response;

  ApiResponse(this._client, this._response);

  int get status => _response.statusCode;
  Map<String, dynamic> get json => jsonDecode(_response.body);

  List<T> asList<T extends Model>() => ModelParser.parseList<T>(_client, json);
  T as<T extends Model>() => ModelParser.parse<T>(_client, json);
}

class ApiException {
  final int statusCode;
  final List<ApiError> errors;

  ApiException.fromResponse(Response response) : this.fromJson(response.statusCode, jsonDecode(response.body));
  ApiException.fromJson(this.statusCode, Map<String, dynamic> json)
      : errors = (json['errors'] as List).map((item) => ApiError.fromJson(item)).toList();

  String toString() => '$statusCode: ${errors.first}';
}

class ApiError {
  final String id;
  final int status;
  final String code;
  final String title;
  final String? detail;

  ApiError.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        status = int.parse(json['status']),
        code = json['code'],
        title = json['title'],
        detail = json['detail'];

  String toString() => '$code ${detail ?? title}';
}
