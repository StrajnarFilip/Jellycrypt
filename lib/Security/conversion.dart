import 'dart:typed_data';

import 'package:convert/convert.dart';

extension StringConvenience on String {
  /// Decode UTF-16 string to bytes
  Uint8List toBytes() {
    return Uint8List.fromList(codeUnits);
  }

  /// Decode hexadecimal string to bytes
  Uint8List hexToBytes() {
    return Uint8List.fromList(hex.decode(this));
  }
}

extension BytesConvenience on List<int> {
  /// Encode bytes to hexadecimal string representation.
  String toHex() {
    return hex.encode(this);
  }

  String toUTF16() {
    return String.fromCharCodes(this);
  }
}
