import 'package:appstore_connect/src/client.dart';
import 'package:appstore_connect/src/model/model.dart';

class PhasedReleaseAttributes extends ModelAttributes {
  final PhasedReleaseState phasedReleaseState;

  PhasedReleaseAttributes({required this.phasedReleaseState});

  Map<String, dynamic> toMap() {
    return {'phasedReleaseState': phasedReleaseState.toString()};
  }
}

class PhasedRelease extends CallableModel {
  static const type = 'appStoreVersionPhasedReleases';
  static const fields = ['phasedReleaseState', 'totalPauseDuration', 'currentDayNumber'];
  static const _userFractions = {1: 0.01, 2: 0.02, 3: 0.05, 4: 0.1, 5: 0.2, 6: 0.5, 7: 1.0};

  final PhasedReleaseState phasedReleaseState;
  final Duration totalPauseDuration;
  final int currentDayNumber;

  PhasedRelease(String id, AppStoreConnectClient client, Map<String, dynamic> attributes)
      : phasedReleaseState = PhasedReleaseState._(attributes['phasedReleaseState']),
        totalPauseDuration = Duration(days: attributes['totalPauseDuration']),
        currentDayNumber = attributes['currentDayNumber'],
        super(type, id, client);

  double get userFraction {
    if (phasedReleaseState == PhasedReleaseState.complete) {
      return 1;
    } else if (phasedReleaseState == PhasedReleaseState.active) {
      return _userFractions[currentDayNumber] ?? 0;
    } else {
      return 0;
    }
  }

  Future<void> update(PhasedReleaseAttributes attributes) {
    final baseUri = AppStoreConnectUri.v1();
    return client.patchModel(baseUri, type, id, attributes: attributes);
  }

  Future<void> delete() {
    return client.delete(AppStoreConnectUri.v1('$type/$id'));
  }
}

class PhasedReleaseState {
  static const inactive = PhasedReleaseState._('INACTIVE');
  static const active = PhasedReleaseState._('ACTIVE');
  static const paused = PhasedReleaseState._('PAUSED');
  static const complete = PhasedReleaseState._('COMPLETE');

  final String _value;
  const PhasedReleaseState._(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(Object other) => other is PhasedReleaseState && other._value == _value;
  String toString() => _value;
}
