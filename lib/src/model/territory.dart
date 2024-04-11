import 'package:appstore_connect/src/model/model.dart';

class Territory extends Model {
  static const String type = 'territories';

  final String id;
  final String currency;

  Territory(String id, Map<String, dynamic> attributes)
      : id = id,
        currency = attributes['currency'],
        super(type, id);
}