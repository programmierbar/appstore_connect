import 'package:appstore_connect/appstore_connect.dart';
import 'package:appstore_connect/src/model/model.dart';
import 'package:intl/intl.dart';

final _earliestDateFormat = DateFormat("yyyy-MM-ddThh:'00Z'");

class AppStoreVersion extends CallableModel {
  static const type = 'appStoreVersions';

  final AppStoreVersionAttributes _attributes;
  final Map<String, dynamic> _relations;

  AppStoreVersion(
    String id,
    AppStoreConnectClient client,
    Map<String, dynamic> attributes,
    this._relations,
  )   : _attributes = AppStoreVersionAttributes._(attributes),
        super(type, id, client);

  bool get live => AppVersionState.liveStates.contains(appVersionState);
  bool get editable => AppVersionState.editStates.contains(appVersionState);
  bool get rejectable => AppVersionState.rejectableStates.contains(appVersionState);

  String get versionString => _attributes.versionString;
  AppVersionState get appVersionState => _attributes.appVersionState;
  ReleaseType get releaseType => _attributes.releaseType;

  Build? get build => _relations['build'];
  PhasedRelease? get phasedRelease => _relations['appStoreVersionPhasedRelease'];

  Future<List<VersionLocalization>> getLocalizations() async {
    final request = GetRequest(AppStoreConnectUri.v1('appStoreVersions/$id/appStoreVersionLocalizations'));
    final response = await client.get(request);
    return response.asList<VersionLocalization>();
  }

  Future<void> update(AppStoreVersionAttributes attributes) async {
    await client.patchModel(AppStoreConnectUri.v1(), 'appStoreVersions', id, attributes: attributes);
    _attributes.merge(attributes);
  }

  Future<void> setBuild(Build build) async {
    await client.patchModel<AppStoreVersion>(
      AppStoreConnectUri.v1(),
      AppStoreVersion.type,
      id,
      relationships: {'build': SingleModelRelationship(type: Build.type, id: build.id)},
    );
    _relations['build'] = build;
  }

  Future<PhasedRelease> setPhasedRelease(PhasedReleaseAttributes attributes) async {
    return _relations['appStoreVersionPhasedRelease'] = await client.postModel<PhasedRelease>(
      AppStoreConnectUri.v1(),
      PhasedRelease.type,
      attributes: attributes,
      relationships: {'appStoreVersion': SingleModelRelationship(type: AppStoreVersion.type, id: id)},
    );
  }

  Future<void> requestRelease() async {
    await client.postModel(
      AppStoreConnectUri.v1(),
      AppStoreVersionReleaseRequest.type,
      relationships: {'appStoreVersion': SingleModelRelationship(type: AppStoreVersion.type, id: id)},
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
  AppStorePlatform get platform => AppStorePlatform(_attributes['platform']);
  AppVersionState get appVersionState => AppVersionState._(_attributes['appVersionState']);
  ReleaseType get releaseType => ReleaseType._(_attributes['releaseType']);
  DateTime? get earliestReleaseDate => _attributes['earliest_release_date'] != null //
      ? DateTime.parse(_attributes['earliest_release_date'])
      : null;

  void merge(AppStoreVersionAttributes attributes) => _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class AppVersionState {
  static const accepted = AppVersionState._('ACCEPTED');
  static const developerRejected = AppVersionState._('DEVELOPER_REJECTED');
  static const inReview = AppVersionState._('IN_REVIEW');
  static const invalidBinary = AppVersionState._('INVALID_BINARY');
  static const metadataRejected = AppVersionState._('METADATA_REJECTED');
  static const pendingAppleRelease = AppVersionState._('PENDING_APPLE_RELEASE');
  static const pendingDeveloperRelease = AppVersionState._('PENDING_DEVELOPER_RELEASE');
  static const prepareForSubmission = AppVersionState._('PREPARE_FOR_SUBMISSION');
  static const processingForDistribution = AppVersionState._('PROCESSING_FOR_DISTRIBUTION');
  static const readyForDistribution = AppVersionState._('READY_FOR_DISTRIBUTION');
  static const readyForReview = AppVersionState._('READY_FOR_REVIEW');
  static const rejected = AppVersionState._('REJECTED');
  static const replacedWithNewVersion = AppVersionState._('REPLACED_WITH_NEW_VERSION');
  static const waitingForExportCompliance = AppVersionState._('WAITING_FOR_EXPORT_COMPLIANCE');
  static const waitingForReview = AppVersionState._('WAITING_FOR_REVIEW');

  static const liveStates = [
    readyForDistribution,
    pendingAppleRelease,
    pendingDeveloperRelease,
    processingForDistribution,
    inReview,
    replacedWithNewVersion,
  ];
  static const editStates = [
    accepted,
    readyForReview,
    prepareForSubmission,
    developerRejected,
    rejected,
    metadataRejected,
    waitingForReview,
    invalidBinary,
    waitingForExportCompliance
  ];
  static const rejectableStates = [
    pendingAppleRelease,
    pendingDeveloperRelease,
    inReview,
    waitingForReview,
    waitingForExportCompliance,
  ];

  final String _value;
  const AppVersionState._(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(Object other) => other is AppVersionState && other._value == _value;
  String toString() => _value;
}

class ReleaseType {
  static const afterApproval = ReleaseType._('AFTER_APPROVAL');
  static const manual = ReleaseType._('MANUAL');
  static const scheduled = ReleaseType._('SCHEDULED');

  final String _name;
  const ReleaseType._(this._name);

  int get hashCode => _name.hashCode;
  bool operator ==(Object other) => other is ReleaseType && other._name == _name;
  String toString() => _name;
}

class AppStoreVersionReleaseRequest extends Model {
  static const type = 'appStoreVersionReleaseRequests';

  AppStoreVersionReleaseRequest(String id) : super(type, id);
}

extension DateTimeExtension on DateTime {
  /// Returns an ISO 8601 conform datetime string, that omits the microseconds part
  String toShortIso8601String() {
    return toIso8601String().replaceFirst(RegExp(r'\.\d+'), '');
  }
}
