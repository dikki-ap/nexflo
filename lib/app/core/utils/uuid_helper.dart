import 'package:uuid/uuid.dart';

class UuidHelper {
  UuidHelper._();
  static const _uuid = Uuid();
  static String generate() => _uuid.v4();
}
