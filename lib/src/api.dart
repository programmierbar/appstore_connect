import 'package:appstore_connect/appstore_connect.dart';
import 'package:appstore_connect/src/model/model.dart';
import 'package:appstore_connect/src/model/territory.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppStoreConnectApi {
  final AppStoreConnectClient _client;
  final String _appId;

  AppStoreConnectApi(this._client, this._appId) {
    initializeDateFormatting();
  }

  Future<List<AppStoreVersion>> getVersions({
    Iterable<String>? versions,
    Iterable<AppVersionState>? states,
    Iterable<AppStorePlatform>? platforms,
  }) async {
    final request = GetRequest(AppStoreConnectUri.v1('apps/$_appId/appStoreVersions'))
      ..include('appStoreVersionPhasedRelease')
      ..include('build');

    if (versions != null) {
      request.filter('versionString', versions);
    }
    if (states != null) {
      request.filter('appVersionState', states);
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
      AppStoreConnectUri.v1('appStoreVersions'),
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
    final request = GetRequest(AppStoreConnectUri.v1('builds')) //
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

  Future<InAppPurchase> getInAppPurchase(String id) async {
    final response = await _client.get(GetRequest(AppStoreConnectUri.v2('inAppPurchases/$id')));
    return response.as<InAppPurchase>();
  }

  Future<List<InAppPurchase>> getInAppPurchases({int limit = 200}) async {
    final request = GetRequest(AppStoreConnectUri.v1('apps/$_appId/inAppPurchasesV2'))..limit(limit);
    final response = await _client.get(request);

    return response.asList<InAppPurchase>()..sort((a, b) => a.productId.compareTo(b.productId));
  }

  Future<InAppPurchase> postInAppPurchase(InAppPurchaseAttributes attributes) async {
    return _client.postModel(
      AppStoreConnectUri.v2(),
      'inAppPurchases',
      attributes: attributes,
      relationships: {
        'app': SingleModelRelationship(type: 'apps', id: _appId),
      },
    );
  }

  Future<List<Territory>> getTerritories() async {
    final response = await _client.get(GetRequest(AppStoreConnectUri.v1('territories'))..limit(200));
    return response.asList<Territory>();
  }

  Future<ReviewSubmission> postReviewSubmission(AppStorePlatform platform) async {
    return await _client.postModel<ReviewSubmission>(
      AppStoreConnectUri.v1(),
      ReviewSubmission.type,
      attributes: ReviewSubmissionCreateAttributes(platform: platform),
      relationships: {'app': SingleModelRelationship(type: 'apps', id: _appId)},
    );
  }

  Future<List<ReviewSubmission>> getReviewSubmission() async {
    final request = GetRequest(AppStoreConnectUri.v1('reviewSubmissions'))
      ..include('appStoreVersionForReview')
      ..filter('app', _appId);
    final response = await _client.get(request);
    return response.asList();
  }
}
