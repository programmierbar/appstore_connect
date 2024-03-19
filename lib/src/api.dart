import 'dart:io';

import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/build.dart';
import 'package:appstore_connect/src/model/in_app_purchase.dart';
import 'package:appstore_connect/src/model/territory.dart';
import 'package:appstore_connect/src/model/version.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:path/path.dart';

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
    final response = await _client.get(GetRequest(AppStoreConnectUri.v2(resource: 'inAppPurchases/$id')));
    return response.as<InAppPurchase>();
  }

  Future<List<InAppPurchase>> getInAppPurchases({int limit = 200}) async {
    final request = GetRequest(AppStoreConnectUri.v1('apps/$_appId/inAppPurchasesV2'))..limit(limit);
    print('uri: ${request.toUri()}');
    final response = await _client.get(request);

    return response.asList<InAppPurchase>()..sort((a, b) => a.productId.compareTo(b.productId));
  }

  Future<bool> postInAppPurchase(String productId, String name, String reviewNote, InAppPurchaseType type) async {
    final body = {
      'data': {
        'type': 'inAppPurchases',
        'attributes': {
          'familySharable': false,
          'inAppPurchaseType': type.toString(),
          'name': name,
          'productId': productId,
          "reviewNote": reviewNote,
        },
        'relationships': {
          'app': {
            'data': {
              'type': 'apps',
              'id': _appId,
            }
          }
        }
      }
    };

    await _client.post(AppStoreConnectUri.v2(resource: 'inAppPurchases'), body);
    return true;
  }

  Future<bool> postInAppPurchaseLocalization(String iapId, String locale, String name, String description) async {
    final body = {
      'data': {
        'type': 'inAppPurchaseLocalizations',
        'attributes': {
          'name': name,
          'description': description,
          'locale': locale,
        },
        'relationships': {
          'inAppPurchaseV2': {
            'data': {
              'type': 'inAppPurchases',
              'id': iapId,
            }
          }
        }
      }
    };

    await _client.post(AppStoreConnectUri.v1('inAppPurchaseLocalizations'), body);
    return true;
  }

  Future<bool> postInAppPurchasePricePoint(String iapId, String baseTerritoryId, String pricePointId) async {
    final body = {
      'data': {
        'type': 'inAppPurchasePriceSchedules',
        'relationships': {
          'baseTerritory': {
            'data': {
              'type': 'territories',
              'id': baseTerritoryId,
            }
          },
          'inAppPurchase': {
            'data': {
              'type': 'inAppPurchases',
              'id': iapId,
            }
          },
          'manualPrices': {
            'data': [
              {
                'type': 'inAppPurchasePrices',
                'id': pricePointId,
              }
            ]
          }
        },
      },
      'included': [
        {
          'type': 'territories',
          'id': baseTerritoryId,
        },
        {
          'type': 'inAppPurchasePrices',
          'id': pricePointId,
          'attributes': {
            'endDate': null,
            'startDate': null,
          },
          'relationships': {
            'inAppPurchaseV2': {
              'data': {
                'type': 'inAppPurchases',
                'id': iapId,
              }
            },
            'inAppPurchasePricePoint': {
              'data': {
                'type': 'inAppPurchasePricePoints',
                'id': pricePointId,
              }
            }
          }
        }
      ]
    };

    await _client.post(AppStoreConnectUri.v1('inAppPurchasePriceSchedules'), body);
    return true;
  }

  Future<bool> postInAppPurchaseAvailability(String iapId, List<String> territoryIds) async {
    final body = {
      'data': {
        'type': 'inAppPurchaseAvailabilities',
        'attributes': {
          'availableInNewTerritories': true,
        },
        'relationships': {
          'availableTerritories': {
            'data': territoryIds.map((id) => {'type': 'territories', 'id': id}).toList()
          },
          'inAppPurchase': {
            'data': {
              'type': 'inAppPurchases',
              'id': iapId,
            }
          }
        }
      },
    };
    await _client.post(AppStoreConnectUri.v1('inAppPurchaseAvailabilities'), body);
    return true;
  }

  Future<bool> postInAppPurchaseSubmission(String iapId) async {
    final body = {
      'data': {
        'type': 'inAppPurchaseSubmissions',
        'relationships': {
          'inAppPurchaseV2': {
            'data': {
              'type': 'inAppPurchases',
              'id': iapId,
            }
          }
        },
      }
    };
    await _client.post(AppStoreConnectUri.v1('inAppPurchaseSubmissions'), body);
    return true;
  }

  Future<bool> createInAppPurchaseReviewScreenshot(String iapId, File asset) async {
    final reservationBody = {
      'data': {
        'type': 'inAppPurchaseAppStoreReviewScreenshots',
        'attributes': {
          'fileName': basename(asset.path),
          'fileSize': asset.lengthSync(),
        },
        'relationships': {
          'inAppPurchaseV2': {
            'data': {
              'type': 'inAppPurchases',
              'id': iapId,
            }
          }
        }
      }
    };

    //make an asset reservation
    final response =
        await _client.post(AppStoreConnectUri.v1('inAppPurchaseAppStoreReviewScreenshots'), reservationBody);
    final reservation = response.as<InAppPurchaseAppStoreReviewScreenshots>();

    //upload asset
    final operation = reservation.uploadOperations.first;
    final target = Uri.parse(operation.url);
    final Map<String, String> headers = Map.fromEntries(operation.requestHeaders.map((e) => MapEntry(e.name, e.value)));
    final binaryAsset = await asset.readAsBytes();
    try {
      _client.putBinary(target, binaryAsset, headers);
    } catch (e) {
      _client.putBinary(target, binaryAsset, headers);
    }

    await Future<void>.delayed(const Duration(milliseconds: 500));

    //commit the upload
    await _client.patch(AppStoreConnectUri.v1('inAppPurchaseAppStoreReviewScreenshots/${reservation.id}'), {
      'data': {
        'type': 'inAppPurchaseAppStoreReviewScreenshots',
        'id': reservation.id,
        'attributes': {'uploaded': true, 'sourceFileChecksum': sha256.convert(binaryAsset).toString()}
      }
    });

    return true;
  }

  Future<Object> getInAppPurchaseLocalizations(String iapId) async {
    final response = await _client
        .get(GetRequest(AppStoreConnectUri.v2(resource: 'inAppPurchases/$iapId/inAppPurchaseLocalizations')));
    return response.asList<InAppPurchaseLocalization>();
  }

  Future<bool> deleteInAppPurchase(String id) async {
    await _client.delete(AppStoreConnectUri.v2(resource: 'inAppPurchases/$id'));
    return true;
  }

  Future<List<Territory>> getTerritories() async {
    final response = await _client.get(GetRequest(AppStoreConnectUri.v1('territories'))..limit(200));
    return response.asList<Territory>();
  }

  Future<List<InAppPurchasePricePoint>> getPricePoints(String iapId, Territory territory, {int limit = 8000}) async {
    final request = GetRequest(AppStoreConnectUri.v2(resource: 'inAppPurchases/$iapId/pricePoints'))
      ..filter('territory', territory.id)
      ..limit(limit);
    final response = await _client.get(request);
    return response.asList<InAppPurchasePricePoint>();
  }
}
