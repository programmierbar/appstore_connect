import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/build.dart';
import 'package:appstore_connect/src/model/in_app_purchase.dart';
import 'package:appstore_connect/src/model/phased_release.dart';
import 'package:appstore_connect/src/model/review_submission.dart';
import 'package:appstore_connect/src/model/territory.dart';
import 'package:appstore_connect/src/model/version.dart';
import 'package:appstore_connect/src/model/version_localization.dart';
import 'package:appstore_connect/src/model/version_submission.dart';

abstract class Model {
  final String _type;
  final String id;

  Model(this._type, this.id);

  factory Model._fromJson(
    String type,
    String id,
    AppStoreConnectClient client,
    Map<String, dynamic> attributes,
    Map<String, dynamic> relations,
  ) {
    switch (type) {
      case AppStoreVersion.type:
        return AppStoreVersion(id, client, attributes, relations);
      case VersionLocalization.type:
        return VersionLocalization(id, client, attributes);
      case PhasedRelease.type:
        return PhasedRelease(id, client, attributes);
      case VersionSubmission.type:
        return VersionSubmission(id, client, attributes);
      case ReviewSubmission.type:
        return ReviewSubmission(id, client, attributes, relations);
      case ReviewSubmissionItem.type:
        return ReviewSubmissionItem(id, client, attributes, relations);
      //not yet supported by the App Store Connect API
      //case ReleaseRequest.type:
      //  return ReleaseRequest(id);
      case Build.type:
        return Build(id, attributes);
      case InAppPurchase.type:
        return InAppPurchase(id, attributes, client);
      case InAppPurchaseLocalization.type:
        return InAppPurchaseLocalization(id, attributes);
      case InAppPurchasePriceSchedule.type:
        return InAppPurchasePriceSchedule(id);
      case Territory.type:
        return Territory(id, attributes);
      case InAppPurchaseAppStoreReviewScreenshot.type:
        return InAppPurchaseAppStoreReviewScreenshot(id, attributes, client);
      case InAppPurchasePricePoint.type:
        return InAppPurchasePricePoint(id, attributes);
      case InAppPurchaseAvailability.type:
        return InAppPurchaseAvailability(id, attributes);
      case InAppPurchaseSubmission.type:
        return InAppPurchaseSubmission(id);
      default:
        throw Exception('Type $type is not supported yet');
    }
  }
}

abstract class CallableModel extends Model {
  final AppStoreConnectClient client;

  CallableModel(String type, String id, this.client) : super(type, id);
}

abstract class ModelAttributes {
  Map<String, dynamic> toMap();
}

abstract class ModelRelationship {
  dynamic toJson();
}

class SingleModelRelationship extends ModelRelationship {
  final String type;
  final String id;

  SingleModelRelationship({required this.type, required this.id});

  @override
  toJson() {
    return {'type': type, 'id': id};
  }
}

class MultiModelRelationship extends ModelRelationship {
  final List<SingleModelRelationship> relationships;

  MultiModelRelationship(List<SingleModelRelationship> this.relationships);

  @override
  toJson() {
    return this.relationships.map((e) => e.toJson()).toList();
  }
}

class ModelInclude {
  final String type;
  final String id;
  final Map<String, dynamic>? attributes;
  final Map<String, ModelRelationship>? relationships;

  ModelInclude({required this.type, required this.id, this.attributes, this.relationships});

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'id': id,
      if (attributes != null) //
        'attributes': attributes,
      if (relationships != null) //
        'relationships': relationships!.map((key, value) => MapEntry(key, {'data': value.toJson()}))
    };
  }
}

class ModelParser {
  static List<T> parseList<T extends Model>(AppStoreConnectClient client, Map<String, dynamic> envelope) {
    final includedModels = _parseIncludes(client, envelope);

    final Iterable<Model> modelList;
    final dataValue = envelope['data'];
    if (dataValue is Map) {
      modelList = dataValue.values.map((value) => _parseModel(client, value, includedModels));
    } else if (dataValue is List) {
      modelList = dataValue.map((value) => _parseModel(client, value, includedModels));
    } else {
      throw Error();
    }

    return modelList.toList().cast<T>();
  }

  static T parse<T extends Model>(AppStoreConnectClient client, Map<String, dynamic> envelope) {
    final includedModels = _parseIncludes(client, envelope);
    final data = envelope['data'] as Map<String, dynamic>;
    return _parseModel(client, data, includedModels) as T;
  }

  static Map<String, Map<String, Model>> _parseIncludes(AppStoreConnectClient client, Map<String, dynamic> envelope) {
    final includedModels = <String, Map<String, Model>>{};
    if (envelope.containsKey('included')) {
      //TODO: included property is not always of type Map, see https://developer.apple.com/documentation/appstoreconnectapi/inapppurchasesubmissionresponse
      final includedData = envelope['included'].cast<Map<String, dynamic>>();
      for (final data in includedData) {
        final model = _parseModel(client, data, includedModels);
        includedModels.putIfAbsent(model._type, () => {})[model.id] = model;
      }
    }

    return includedModels;
  }

  static Model _parseModel(
    AppStoreConnectClient client,
    Map<String, dynamic> data,
    Map<String, Map<String, Model>> includes,
  ) {
    final type = data['type'] as String;
    final id = data['id'] as String;
    final attributes = data['attributes'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final relations = data.containsKey('relationships')
        ? _parseRelations(data['relationships'] as Map<String, dynamic>, includes)
        : <String, dynamic>{};

    return Model._fromJson(type, id, client, attributes, relations);
  }

  static Map<String, dynamic> _parseRelations(Map<String, dynamic> data, Map<String, Map<String, Model>> includes) {
    final relations = <String, dynamic>{};
    for (final entry in data.entries) {
      final relationName = entry.key;
      final relationShip = entry.value as Map<String, dynamic>;
      final relationShipData = relationShip['data'];
      if (relationShipData != null) {
        if (relationShipData is List) {
          for (final element in relationShipData) {
            final relatedType = element['type'] as String;
            final relatedId = element['id'] as String;
            relations.putIfAbsent(relationName, () => []).add(includes[relatedType]![relatedId]!);
          }
        } else {
          final relatedType = relationShipData['type'] as String;
          final relatedId = relationShipData['id'] as String;
          relations[relationName] = includes[relatedType]![relatedId]!;
        }
      }
    }

    return relations;
  }
}
