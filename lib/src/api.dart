import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/build.dart';
import 'package:appstore_connect/src/model/version.dart';

class AppStoreConnectApi {
  final AppStoreConnectClient _client;
  final String _appId;

  AppStoreConnectApi(this._client, this._appId);

  Future<List<AppStoreVersion>> getVersions({
    Iterable<String>? versions,
    Iterable<AppStoreState>? states,
    Iterable<AppStorePlatform>? platforms,
  }) async {
    final request = GetRequest(AppStoreConnectUri.v1(resource: 'apps/$_appId/appStoreVersions')) //
      ..include('appStoreVersionPhasedRelease')
      ..include('appStoreVersionSubmission')
      ..include('build');

    if (versions != null) {
      request.filter('versionString', versions);
    }
    if (states != null) {
      request.filter('appStoreState', states);
    }
    if (platforms != null) {
      request.filter('platform', platforms);
    }

    final response = await _client.get(request);
    return response.asList<AppStoreVersion>();
  }

  Future<AppStoreVersion> postVersion({
    required AppStoreVersionAttributes attributes,
  }) async {
    final response = await _client.post(
      AppStoreConnectUri.v1(resource: 'appStoreVersions'),
      {
        'data': {
          'type': 'appStoreVersions',
          'attributes': attributes.toMap()..removeWhere((_, value) => value == null),
          'relationships': {
            'app': {
              'data': {
                'type': 'apps',
                'id': _appId,
              }
            }
          }
        }
      },
    );
    return response.as<AppStoreVersion>();
  }

  Future<List<Build>> getBuilds({required String version, String? buildNumber}) async {
    final request = GetRequest(AppStoreConnectUri.v1(resource: 'builds')) //
      ..filter('app', _appId)
      ..filter('preReleaseVersion.version', version)
      ..filter('processingState', ['PROCESSING', 'FAILED', 'INVALID', 'VALID'])
      ..sort('uploadedDate', descending: true);

    if (buildNumber != null) {
      request.filter('version', buildNumber);
    }

    final response = await _client.get(request);
    return response.asList<Build>();
  }
}
