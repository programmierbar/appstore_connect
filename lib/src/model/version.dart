import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/build.dart';
import 'package:appstore_connect/src/model/model.dart';
import 'package:appstore_connect/src/model/phased_release.dart';
import 'package:appstore_connect/src/model/version_localization.dart';
import 'package:appstore_connect/src/model/version_submission.dart';
import 'package:intl/intl.dart';

final _earliestDateFormat = DateFormat("yyyy-MM-ddThh:'00Z'");

class AppStoreVersion extends CallableModel {
  static const type = 'appStoreVersions';
  static const fields = ['versionString', 'appStoreState', 'releaseType'];

  final AppStoreVersionAttributes _attributes;
  final Map<String, dynamic> _relations;

  AppStoreVersion(
    String id,
    AppStoreConnectClient client,
    Map<String, dynamic> attributes,
    this._relations,
  )   : _attributes = AppStoreVersionAttributes._(attributes),
        super(type, id, client);

  bool get live => AppStoreState.liveStates.contains(appStoreState);
  bool get editable => AppStoreState.editStates.contains(appStoreState);

  String get versionString => _attributes.versionString;
  AppStoreState get appStoreState => _attributes.appStoreState;
  ReleaseType get releaseType => _attributes.releaseType;

  Build? get build => _relations['build'];
  PhasedRelease? get phasedRelease => _relations['appStoreVersionPhasedRelease'];
  VersionSubmission? get submission => _relations['appStoreVersionSubmission'];

  Future<List<VersionLocalization>> getLocalizations() async {
    final request = GetRequest('appStoreVersions/$id/appStoreVersionLocalizations');
    final response = await client.get(request);
    return response.asList<VersionLocalization>();
  }

  Future<void> update(AppStoreVersionAttributes attributes) async {
    await client.patchModel(type: 'appStoreVersions', id: id, attributes: attributes);
    _attributes.merge(attributes);
  }

  Future<void> setBuild(Build build) async {
    await client.patchModel<AppStoreVersion>(
      type: AppStoreVersion.type,
      id: id,
      relationships: {'build': ModelRelationship(type: Build.type, id: build.id)},
    );
    _relations['build'] = build;
  }

  Future<PhasedRelease> setPhasedRelease(PhasedReleaseAttributes attributes) async {
    return _relations['appStoreVersionPhasedRelease'] = await client.postModel<PhasedRelease>(
      type: PhasedRelease.type,
      attributes: attributes,
      relationships: {'appStoreVersion': ModelRelationship(type: AppStoreVersion.type, id: id)},
    );
  }

  Future<VersionSubmission> addSubmission() async {
    return _relations['appStoreVersionSubmission'] = await client.postModel<VersionSubmission>(
      type: VersionSubmission.type,
      relationships: {'appStoreVersion': ModelRelationship(type: AppStoreVersion.type, id: id)},
    );
  }
}

class AppStoreVersionAttributes implements ModelAttributes {
  final Map<String, dynamic> _attributes;

  AppStoreVersionAttributes({
    AppStorePlatform? platform,
    String? versionString,
    ReleaseType? releaseType,
    DateTime? earliestReleaseDate,
  }) : _attributes = {
          if (platform != null) 'platform': platform.toString(),
          if (versionString != null) 'versionString': versionString,
          if (releaseType != null) 'releaseType': releaseType.toString(),
          if (earliestReleaseDate != null)
            'earliestReleaseDate': _earliestDateFormat.format(earliestReleaseDate.toUtc()),
        };

  AppStoreVersionAttributes._(this._attributes);

  String get versionString => _attributes['versionString'];
  AppStorePlatform get platform => AppStorePlatform._(_attributes['platform']);
  AppStoreState get appStoreState => AppStoreState._(_attributes['appStoreState']);
  ReleaseType get releaseType => ReleaseType._(_attributes['releaseType']);
  DateTime? get earliestReleaseDate => _attributes['earliest_release_date'] != null //
      ? DateTime.parse(_attributes['earliest_release_date'])
      : null;

  void merge(AppStoreVersionAttributes attributes) => _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class AppStorePlatform {
  static const iOS = AppStorePlatform._('IOS');
  static const MacOS = AppStorePlatform._('MacOS');
  static const TvOS = AppStorePlatform._('TV_OS');

  final String _name;
  const AppStorePlatform._(this._name);

  String toString() => _name;
}

class AppStoreState {
  static const readyForSale = AppStoreState._('READY_FOR_SALE');
  static const processingForAppStore = AppStoreState._('PROCESSING_FOR_APP_STORE');
  static const pendingDeveloperRelease = AppStoreState._('PENDING_DEVELOPER_RELEASE');
  static const pendingAppleRelease = AppStoreState._('PENDING_APPLE_RELEASE');
  static const inReview = AppStoreState._('IN_REVIEW');
  static const waitingForReview = AppStoreState._('WAITING_FOR_REVIEW');
  static const developerRejected = AppStoreState._('DEVELOPER_REJECTED');
  static const developerRemovedFromSale = AppStoreState._('DEVELOPER_REMOVED_FROM_SALE');
  static const rejected = AppStoreState._('REJECTED');
  static const prepareForSubmission = AppStoreState._('PREPARE_FOR_SUBMISSION');
  static const metadataRejected = AppStoreState._('METADATA_REJECTED');
  static const invalidBinary = AppStoreState._('INVALID_BINARY');

  static const liveStates = [
    readyForSale,
    pendingAppleRelease,
    pendingDeveloperRelease,
    processingForAppStore,
    inReview,
    developerRemovedFromSale
  ];
  static const editStates = [
    prepareForSubmission,
    developerRejected,
    rejected,
    metadataRejected,
    waitingForReview,
    invalidBinary
  ];
  static const rejectableStates = [
    pendingAppleRelease,
    pendingDeveloperRelease,
    inReview,
    waitingForReview,
  ];

  final String _name;
  const AppStoreState._(this._name);

  //int get hashCode => _name.hashCode;
  bool operator ==(dynamic other) => other is AppStoreState && other._name == _name;
  String toString() => _name;
}

class ReleaseType {
  static const afterApproval = ReleaseType._('AFTER_APPROVAL');
  static const manual = ReleaseType._('MANUAL');
  static const scheduled = ReleaseType._('SCHEDULED');

  final String _name;
  const ReleaseType._(this._name);

  int get hashCode => _name.hashCode;
  bool operator ==(dynamic other) => other is ReleaseType && other._name == _name;
  String toString() => _name;
}

extension DateTimeExtension on DateTime {
  /// Returns an ISO 8601 conform datetime string, that omits the microseconds part
  String toShortIso8601String() {
    return toIso8601String().replaceFirst(RegExp(r'\.\d+'), '');
  }
}

// no yet supported by App Store connect api
/*class ReleaseRequest extends Model {
  static const type = 'appStoreVersionReleaseRequests';
  ReleaseRequest(String id) : super(type, id);
}*/
