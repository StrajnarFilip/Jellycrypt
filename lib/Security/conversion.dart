/*
Copyright 2022 Filip Strajnar

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
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
