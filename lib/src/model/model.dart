import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/build.dart';
import 'package:appstore_connect/src/model/phased_release.dart';
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
      //not yet supported by the App Store Connect API
      //case ReleaseRequest.type:
      //  return ReleaseRequest(id);
      case Build.type:
        return Build(id, attributes);
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

class ModelRelationship {
  final String type;
  final String id;

  ModelRelationship({required this.type, required this.id});

  Map<String, dynamic> toMap() {
    return {'type': type, 'id': id};
  }
}

class ModelParser {
  static List<T> parseList<T extends Model>(AppStoreConnectClient client, Map<String, dynamic> envelope) {
    final includedModels = _parseIncludes(client, envelope);
    final modelData = envelope['data'].cast<Map<String, dynamic>>();
    final modelList = modelData.map((data) => _parseModel(client, data, includedModels)).toList();

    return modelList.cast<T>();
  }

  static T parse<T extends Model>(AppStoreConnectClient client, Map<String, dynamic> envelope) {
    final includedModels = _parseIncludes(client, envelope);
    final data = envelope['data'] as Map<String, dynamic>;
    return _parseModel(client, data, includedModels) as T;
  }

  static Map<String, Map<String, Model>> _parseIncludes(AppStoreConnectClient client, Map<String, dynamic> envelope) {
    final includedModels = <String, Map<String, Model>>{};
    if (envelope.containsKey('included')) {
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
