import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/model.dart';

class VersionSubmission extends CallableModel {
  static const type = 'appStoreVersionSubmissions';

  final bool canReject;

  VersionSubmission(String id, AppStoreConnectClient client, Map<String, dynamic> attributes)
      : canReject = attributes['canReject'] ?? true,
        super(type, id, client);

  Future<void> delete() {
    return client.delete(AppStoreConnectUri.v1(resource: '$type/$id'));
  }
}
