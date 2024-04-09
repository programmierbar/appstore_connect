import 'dart:typed_data';

import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/build.dart';
import 'package:appstore_connect/src/model/in_app_purchase.dart';
import 'package:appstore_connect/src/model/model.dart';
import 'package:appstore_connect/src/model/territory.dart';
import 'package:appstore_connect/src/model/version.dart';
import 'package:intl/date_symbol_data_local.dart';

class AppStoreConnectApi {
  final AppStoreConnectClient _client;
  final String _appId;

  AppStoreConnectApi(this._client, this._appId) {
    initializeDateFormatting();
  }

  Future<List<AppStoreVersion>> getVersions({
    Iterable<String>? versions,
    Iterable<AppStoreState>? states,
    Iterable<AppStorePlatform>? platforms,
  }) async {
    final request = GetRequest(AppStoreConnectUri.v1('apps/$_appId/appStoreVersions'))
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
    print('uri: ${request.toUri()}');
    final response = await _client.get(request);

    return response.asList<InAppPurchase>()..sort((a, b) => a.productId.compareTo(b.productId));
  }

  Future<bool> postInAppPurchase(InAppPurchaseAttributes attributes) async {
    await _client.postModel(
      AppStoreConnectUri.v2(),
      'inAppPurchases',
      attributes: attributes,
      relationships: {
        'app': SingleModelRelationship(type: 'apps', id: _appId),
      },
    );
    return true;
  }

  Future<bool> postInAppPurchaseLocalization(InAppPurchaseLocalizationAttributes attributes,
      {required String iapId}) async {
    await _client.postModel(
      AppStoreConnectUri.v1(null),
      'inAppPurchaseLocalizations',
      attributes: attributes,
      relationships: {
        'inAppPurchaseV2': SingleModelRelationship(type: 'inAppPurchases', id: iapId),
      },
    );
    return true;
  }

  Future<bool> postInAppPurchasePriceSchedule(
      {required String iapId, required String baseTerritoryId, required String pricePointId}) async {
    await _client.postModel(AppStoreConnectUri.v1(null), 'inAppPurchasePriceSchedules', relationships: {
      'baseTerritory': SingleModelRelationship(type: 'territories', id: baseTerritoryId),
      'inAppPurchase': SingleModelRelationship(type: 'inAppPurchases', id: iapId),
      'manualPrices': SingleModelRelationship(type: 'inAppPurchasePrices', id: pricePointId),
    }, includes: [
      ModelInclude(type: 'territories', id: baseTerritoryId),
      ModelInclude(type: 'inAppPurchasePrices', id: pricePointId, attributes: {
        'endDate': null,
        'startDate': null,
      }, relationships: {
        'inAppPurchaseV2': SingleModelRelationship(type: 'inAppPurchases', id: iapId),
        'inAppPurchasePricePoint': SingleModelRelationship(type: 'inAppPurchasePricePoints', id: pricePointId),
      }),
    ]);
    return true;
  }

  Future<bool> postInAppPurchaseAvailability(InAppPurchaseAvailabilityAttributes attributes, List<String> territoryIds,
      {required String iapId}) async {
    await _client.postModel(
      AppStoreConnectUri.v1(null),
      'inAppPurchaseAvailabilities',
      attributes: attributes,
      relationships: {
        'inAppPurchase': SingleModelRelationship(type: 'inAppPurchases', id: iapId),
        'availableTerritories': MultipleModelRelationship(
          territoryIds.map((id) => SingleModelRelationship(type: 'territories', id: id)).toList(),
        ),
      },
    );
    return true;
  }

  Future<bool> postInAppPurchaseSubmission({required String iapId}) async {
    await _client.postModel(AppStoreConnectUri.v1(null), 'inAppPurchaseSubmissions', relationships: {
      'inAppPurchaseV2': SingleModelRelationship(type: 'inAppPurchases', id: iapId),
    });
    return true;
  }

  Future<InAppPurchaseAppStoreReviewScreenshotCreate> postInAppPurchaseReviewScreenshotCreate(
      InAppPurchaseAppStoreReviewScreenshotCreateAttributes attributes,
      {required String iapId}) async {
    return await _client.postModel(
      AppStoreConnectUri.v1(null),
      'inAppPurchaseAppStoreReviewScreenshots',
      attributes: attributes,
      relationships: {
        'inAppPurchaseV2': SingleModelRelationship(type: 'inAppPurchases', id: iapId),
      },
    );
  }

  Future<bool> uploadInAppPurchaseAppStoreReviewScreenshot(UploadOperation operation, Uint8List data) async {
    final target = Uri.parse(operation.url);
    final Map<String, String> headers = Map.fromEntries(operation.requestHeaders.map((e) => MapEntry(e.name, e.value)));
    await _client.putBinary(target, data, headers);
    return true;
  }

  Future<bool> postInAppPurchaseAppStoreReviewScreenshotCommit(
      InAppPurchaseAppStoreReviewScreenshotCommitAttributes attributes,
      {required String screenshotId}) async {
    await _client.patchModel(
      AppStoreConnectUri.v1(null),
      'inAppPurchaseAppStoreReviewScreenshots',
      screenshotId,
      attributes: attributes,
    );
    return true;
  }

  Future<Object> getInAppPurchaseLocalizations(String iapId) async {
    final response = await _client
        .get(GetRequest(AppStoreConnectUri.v2('inAppPurchases/$iapId/inAppPurchaseLocalizations')));
    return response.asList<InAppPurchaseLocalization>();
  }

  Future<bool> deleteInAppPurchase(String id) async {
    await _client.delete(AppStoreConnectUri.v2('inAppPurchases/$id'));
    return true;
  }

  Future<List<Territory>> getTerritories() async {
    final response = await _client.get(GetRequest(AppStoreConnectUri.v1('territories'))..limit(200));
    return response.asList<Territory>();
  }

  Future<List<InAppPurchasePricePoint>> getPricePoints(Territory territory,
      {required String iapId, int limit = 8000}) async {
    final request = GetRequest(AppStoreConnectUri.v2('inAppPurchases/$iapId/pricePoints'))
      ..filter('territory', territory.id)
      ..limit(limit);
    final response = await _client.get(request);
    return response.asList<InAppPurchasePricePoint>();
  }
}
