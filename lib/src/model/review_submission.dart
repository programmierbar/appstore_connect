import 'package:appstore_connect/appstore_connect.dart';
import 'package:appstore_connect/src/model/app_store_platform.dart';
import 'package:appstore_connect/src/model/model.dart';

class ReviewSubmission extends CallableModel {
  static const type = 'reviewSubmissions';

  final ReviewSubmissionState state;
  final AppStorePlatform platform;
  final String? submittedDate;
  final Map<String, dynamic> _relations;

  AppStoreVersion get appStoreVersionForReview => _relations['appStoreVersionForReview'];

  ReviewSubmission(
    String id,
    AppStoreConnectClient client,
    Map<String, dynamic> attributes,
    this._relations,
  )   : state = ReviewSubmissionState._(attributes['state']),
        platform = AppStorePlatform(attributes['platform']),
        submittedDate = attributes['submittedDate'] ?? null,
        super(type, id, client);

  Future<ReviewSubmission> submit() {
    return client.patchModel(AppStoreConnectUri.v1(), type, id,
        attributes: ReviewSubmissionUpdateAttributes(submitted: true));
  }

  Future<ReviewSubmission> cancel() {
    return client.patchModel(AppStoreConnectUri.v1(), type, id,
        attributes: ReviewSubmissionUpdateAttributes(canceled: true));
  }

  Future<List<ReviewSubmissionItem>> items() async {
    final response = await client.get(GetRequest(AppStoreConnectUri.v1('$type/$id/items')));
    return response.asList<ReviewSubmissionItem>();
  }

  Future<ReviewSubmissionItem> postItem({AppStoreVersion? appStoreVersion}) {
    return client.postModel(
      AppStoreConnectUri.v1(),
      'reviewSubmissionItems',
      relationships: {
        if (appStoreVersion != null)
          'appStoreVersion': SingleModelRelationship(type: AppStoreVersion.type, id: appStoreVersion.id),
        'reviewSubmission': SingleModelRelationship(type: type, id: id),
      },
    );
  }

  @override
  String toString() {
    return 'ReviewSubmission{state: $state, platform: $platform, submittedDate: $submittedDate, appStoreVersionForReview: $appStoreVersionForReview}';
  }
}

class ReviewSubmissionState {
  static const readyForReview = ReviewSubmissionState._('READY_FOR_REVIEW');
  static const waitingForReview = ReviewSubmissionState._('WAITING_FOR_REVIEW');
  static const inReview = ReviewSubmissionState._('IN_REVIEW');
  static const unresolvedIssues = ReviewSubmissionState._('UNRESOLVED_ISSUES');
  static const canceling = ReviewSubmissionState._('CANCELING');
  static const completing = ReviewSubmissionState._('COMPLETING');
  static const complete = ReviewSubmissionState._('COMPLETE');

  final String _value;
  const ReviewSubmissionState._(this._value);

  int get hashCode => _value.hashCode;
  // ignore: non_nullable_equals_parameter
  bool operator ==(dynamic other) => other is ReviewSubmissionState && other._value == _value;
  String toString() => _value;
}

class ReviewSubmissionCreateAttributes implements ModelAttributes {
  final AppStorePlatform platform;

  ReviewSubmissionCreateAttributes({required this.platform});

  @override
  Map<String, dynamic> toMap() {
    return {
      'platform': platform.toString(),
    };
  }
}

class ReviewSubmissionUpdateAttributes implements ModelAttributes {
  final bool? _canceled;
  final AppStorePlatform? _platform;
  final bool? _submitted;

  ReviewSubmissionUpdateAttributes({
    bool? canceled,
    AppStorePlatform? platform,
    bool? submitted,
  })  : _canceled = canceled,
        _platform = platform,
        _submitted = submitted;

  @override
  Map<String, dynamic> toMap() {
    return {
      if (_canceled != null) 'canceled': _canceled,
      if (_platform != null) 'platform': _platform.toString(),
      if (_submitted != null) 'submitted': _submitted,
    };
  }
}

class ReviewSubmissionItem extends CallableModel {
  static const type = 'reviewSubmissionItems';

  final ReviewSubmissionItemState state;
  final Map<String, dynamic> _relations;

  ReviewSubmissionItem(
    String id,
    AppStoreConnectClient client,
    Map<String, dynamic> attributes,
    this._relations,
  )   : state = ReviewSubmissionItemState._(attributes['state']),
        super(type, id, client);

  AppStoreVersion? get appStoreVersion => _relations['appStoreVersion'];

  Future<void> delete() async {
    await client.delete(AppStoreConnectUri.v1('$type/$id'));
  }

  @override
  String toString() {
    return 'ReviewSubmissionItem{id: $id, state: $state, _relations: $_relations}';
  }
}

class ReviewSubmissionItemState {
  static const readyForReview = ReviewSubmissionState._('READY_FOR_REVIEW');
  static const accepted = ReviewSubmissionState._('ACCEPTED');
  static const approved = ReviewSubmissionState._('APPROVED');
  static const rejected = ReviewSubmissionState._('REJECTED');
  static const removed = ReviewSubmissionState._('REMOVED');

  final String _value;
  const ReviewSubmissionItemState._(this._value);

  int get hashCode => _value.hashCode;
  // ignore: non_nullable_equals_parameter
  bool operator ==(dynamic other) => other is ReviewSubmissionState && other._value == _value;
  String toString() => _value;
}
