import 'package:appstore_connect/src/model/model.dart';

class Territory extends Model {
  static const String type = 'territories';
  static final Territory USA = Territory('USA', {'currency': 'USD'});

  final String id;
  final String currency;

  Territory(String id, Map<String, dynamic> attributes)
      : id = id,
        currency = attributes['currency'],
        super(type, id);
}

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
  bool operator ==(dynamic other) => other is InAppPurchaseState && other._value == _value;
  String toString() => _value;
}

class InAppPurchaseLocalization extends Model {
  static const String type = 'inAppPurchaseLocalizations';

  final String id;
  final String name;
  final String locale;
  final String description;
  final InAppPurchaseLocalizationState state;

  InAppPurchaseLocalization(String id, Map<String, dynamic> attributes)
      : id = id,
        name = attributes['name'],
        locale = attributes['locale'],
        description = attributes['description'],
        state = InAppPurchaseLocalizationState._(attributes['state']),
        super(type, id);
}

class InAppPurchaseLocalizationState {
  static const prepareForSubmission = InAppPurchaseLocalizationState._('PREPARE_FOR_SUBMISSION');
  static const waitingForReview = InAppPurchaseLocalizationState._('WAITING_FOR_REVIEW');
  static const approved = InAppPurchaseLocalizationState._('APPROVED');
  static const rejected = InAppPurchaseLocalizationState._('REJECTED');

  final String _value;
  const InAppPurchaseLocalizationState._(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(dynamic other) => other is InAppPurchaseState && other._value == _value;
  String toString() => _value;
}

class InAppPurchasePriceSchedule extends Model {
  static const String type = 'inAppPurchasePriceSchedules';

  final String id;

  InAppPurchasePriceSchedule(String id)
      : id = id,
        super(type, id);
}

class InAppPurchaseAppStoreReviewScreenshots extends Model {
  static const String type = 'inAppPurchaseAppStoreReviewScreenshots';

  final String id;
  final int fileSize;
  final String fileName;
  final String assetToken;
  final List<UploadOperation> uploadOperations;

  InAppPurchaseAppStoreReviewScreenshots(String id, Map<String, dynamic> attributes)
      : id = id,
        fileSize = attributes['fileSize'] as int,
        fileName = attributes['fileName'],
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
