import 'package:appstore_connect/src/model/model.dart';

class InAppPurchase extends Model {
  static const type = 'inAppPurchases';

  final String id;
  final String name;
  final String productId;
  final String? reviewNote;
  final bool familySharable;
  final bool? contentHosting;
  final InAppPurchaseType inAppPurchaseType;
  final InAppPurchaseState state;

  InAppPurchase(String id, Map<String, dynamic> attributes)
      : id = id,
        name = attributes['name'],
        productId = attributes['productId'],
        reviewNote = attributes['reviewNote'],
        familySharable = attributes['familySharable'],
        contentHosting = attributes['contentHosting'],
        inAppPurchaseType = InAppPurchaseType._(attributes['inAppPurchaseType']),
        state = InAppPurchaseState._(attributes['state']),
        super(type, id);
}

class InAppPurchaseAttributes implements ModelAttributes {
  final Map<String, dynamic> _attributes;

  InAppPurchaseAttributes({
    required InAppPurchaseType inAppPurchaseType,
    required String name,
    required String productId,
    required String reviewNote,
    bool? familySharable,
  }) : _attributes = {
          'name': name,
          'productId': productId,
          'inAppPurchaseType': inAppPurchaseType.toString(),
          'reviewNote': reviewNote,
          if (familySharable != null) 'familySharable': familySharable,
        };

  InAppPurchaseAttributes._(this._attributes);

  String get name => _attributes['name'];
  String get productId => _attributes['productId'];
  InAppPurchaseType get inAppPurchaseType => InAppPurchaseType._(_attributes['inAppPurchaseType']);
  String get reviewNote => _attributes['reviewNote'];
  bool? get familySharable => _attributes['familySharable'];

  void merge(InAppPurchaseAttributes attributes) => _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class InAppPurchaseState {
  static const approved = InAppPurchaseState._('APPROVED');
  static const developerActionNeeded = InAppPurchaseState._('DEVELOPER_ACTION_NEEDED');
  static const developerRemovedFromSale = InAppPurchaseState._('DEVELOPER_REMOVED_FROM_SALE');
  static const inReview = InAppPurchaseState._('IN_REVIEW');
  static const missingMetadata = InAppPurchaseState._('MISSING_METADATA');
  static const pendingBinaryApproval = InAppPurchaseState._('PENDING_BINARY_APPROVAL');
  static const processingContent = InAppPurchaseState._('PROCESSING_CONTENT');
  static const readyToSubmit = InAppPurchaseState._('READY_TO_SUBMIT');
  static const rejected = InAppPurchaseState._('REJECTED');
  static const removedFromSale = InAppPurchaseState._('REMOVED_FROM_SALE');
  static const waitingForReview = InAppPurchaseState._('WAITING_FOR_REVIEW');
  static const waitingForUpload = InAppPurchaseState._('WAITING_FOR_UPLOAD');

  final String _value;
  const InAppPurchaseState._(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(dynamic other) => other is InAppPurchaseState && other._value == _value;
  String toString() => _value;
}

class InAppPurchaseType {
  static const consumable = InAppPurchaseType._('CONSUMABLE');
  static const nonConsumable = InAppPurchaseType._('NON_CONSUMABLE');
  static const nonRenewingSubscription = InAppPurchaseType._('NON_RENEWING_SUBSCRIPTION');

  final String _value;
  const InAppPurchaseType._(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(dynamic other) => other is InAppPurchaseType && other._value == _value;
  String toString() => _value;
}

class InAppPurchaseLocalization extends Model {
  static const String type = 'inAppPurchaseLocalizations';

  final String id;
  final InAppPurchaseLocalizationAttributes attributes;
  final InAppPurchaseLocalizationState state;

  InAppPurchaseLocalization(String id, Map<String, dynamic> attributes)
      : id = id,
        attributes = InAppPurchaseLocalizationAttributes._(attributes),
        state = InAppPurchaseLocalizationState._(attributes['state']),
        super(type, id);
}

class InAppPurchaseLocalizationAttributes implements ModelAttributes {
  final Map<String, dynamic> _attributes;

  InAppPurchaseLocalizationAttributes({
    required String locale,
    required String name,
    String? description,
  }) : _attributes = {
          'name': name,
          'locale': locale,
          if (description != null) 'description': description,
        };

  InAppPurchaseLocalizationAttributes._(this._attributes);

  String get name => _attributes['name'];
  String get locale => _attributes['locale'];
  String? get description => _attributes['description'];

  void merge(InAppPurchaseLocalizationAttributes attributes) => _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class InAppPurchaseLocalizationState {
  static const prepareForSubmission = InAppPurchaseLocalizationState._('PREPARE_FOR_SUBMISSION');
  static const waitingForReview = InAppPurchaseLocalizationState._('WAITING_FOR_REVIEW');
  static const approved = InAppPurchaseLocalizationState._('APPROVED');
  static const rejected = InAppPurchaseLocalizationState._('REJECTED');

  final String _value;
  const InAppPurchaseLocalizationState._(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(dynamic other) => other is InAppPurchaseLocalizationState && other._value == _value;
  String toString() => _value;
}

class InAppPurchasePriceSchedule extends Model {
  static const String type = 'inAppPurchasePriceSchedules';

  final String id;

  InAppPurchasePriceSchedule(String id)
      : id = id,
        super(type, id);
}

class InAppPurchaseAvailability extends Model {
  static const String type = 'inAppPurchaseAvailabilities';

  final String id;
  final InAppPurchaseAvailabilityAttributes attributes;

  InAppPurchaseAvailability(String id, Map<String, dynamic> attributes)
      : id = id,
        attributes = InAppPurchaseAvailabilityAttributes._(attributes),
        super(type, id);
}

class InAppPurchaseAvailabilityAttributes implements ModelAttributes {
  final Map<String, dynamic> _attributes;

  InAppPurchaseAvailabilityAttributes({bool? availableInNewTerritories})
      : _attributes = {
          if (availableInNewTerritories != null) 'availableInNewTerritories': availableInNewTerritories,
        };

  InAppPurchaseAvailabilityAttributes._(this._attributes);

  bool? get availableInNewTerritories => _attributes['availableInNewTerritories'];

  void merge(InAppPurchaseAvailabilityAttributes attributes) => _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class InAppPurchaseAppStoreReviewScreenshotCreate extends Model {
  static const String type = 'inAppPurchaseAppStoreReviewScreenshots';

  final String id;
  final InAppPurchaseAppStoreReviewScreenshotCreateAttributes attributes;
  final String assetToken;
  final List<UploadOperation> uploadOperations;

  InAppPurchaseAppStoreReviewScreenshotCreate(String id, Map<String, dynamic> attributes)
      : id = id,
        attributes = InAppPurchaseAppStoreReviewScreenshotCreateAttributes._(attributes),
        assetToken = attributes['assetToken'],
        uploadOperations = (attributes['uploadOperations'] as List)
            .map((operation) => UploadOperation(
                  operation['method'],
                  operation['url'],
                  operation['length'] as int,
                  operation['offset'] as int,
                  (operation['requestHeaders'] as List)
                      .map((header) => RequestHeader(header['name'], header['value']))
                      .toList(),
                ))
            .toList(),
        super(type, id);
}

class InAppPurchaseAppStoreReviewScreenshotCreateAttributes implements ModelAttributes {
  final Map<String, dynamic> _attributes;

  InAppPurchaseAppStoreReviewScreenshotCreateAttributes({required String fileName, required int fileSize})
      : _attributes = {
          'fileName': fileName,
          'fileSize': fileSize,
        };

  InAppPurchaseAppStoreReviewScreenshotCreateAttributes._(this._attributes);

  String get fileName => _attributes['fileName'];
  int get fileSize => _attributes['fileSize'] as int;

  void merge(InAppPurchaseAppStoreReviewScreenshotCreateAttributes attributes) =>
      _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class InAppPurchaseAppStoreReviewScreenshotCommitAttributes implements ModelAttributes {
  final Map<String, dynamic> _attributes;

  InAppPurchaseAppStoreReviewScreenshotCommitAttributes({required bool uploaded, required String sourceFileChecksum})
      : _attributes = {
          'uploaded': uploaded,
          'sourceFileChecksum': sourceFileChecksum,
        };

  InAppPurchaseAppStoreReviewScreenshotCommitAttributes._(this._attributes);

  bool get uploaded => _attributes['uploaded'] as bool;
  String get sourceFileChecksum => _attributes['sourceFileChecksum'];

  void merge(InAppPurchaseAppStoreReviewScreenshotCommitAttributes attributes) =>
      _attributes.addAll(attributes._attributes);

  Map<String, dynamic> toMap() => _attributes;
}

class InAppPurchasePricePoint extends Model {
  static const String type = 'inAppPurchasePricePoints';

  final String id;
  final double customerPrice;
  final double proceeds;
  final int priceTier;

  InAppPurchasePricePoint(String id, Map<String, dynamic> attributes)
      : id = id,
        customerPrice = double.parse(attributes['customerPrice']),
        proceeds = double.parse(attributes['proceeds']),
        priceTier = int.parse(attributes['priceTier']),
        super(type, id);
}

class InAppPurchaseSubmission extends Model {
  static const String type = 'inAppPurchaseSubmissions';

  final String id;

  InAppPurchaseSubmission(String id)
      : id = id,
        super(type, id);
}

class UploadOperation {
  final String method;
  final String url;
  final int length;
  final int offset;
  final List<RequestHeader> requestHeaders;

  UploadOperation(this.method, this.url, this.length, this.offset, this.requestHeaders);
}

class RequestHeader {
  final String name;
  final String value;

  const RequestHeader(this.name, this.value);
}
