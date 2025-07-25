class AppStorePlatform {
  static const ios = AppStorePlatform('IOS');
  static const macOs = AppStorePlatform('MAC_OS');
  static const tvOs = AppStorePlatform('TV_OS');
  static const visionOs = AppStorePlatform('VISION_OS');

  final String _value;
  const AppStorePlatform(this._value);

  int get hashCode => _value.hashCode;
  bool operator ==(Object other) => other is AppStorePlatform && other._value == _value;
  String toString() => _value;
}
