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
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:async/async.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart' as pointyCastle;
import 'package:cryptography/cryptography.dart' as crypto;
import './conversion.dart';

Result<Uint8List> strongScryptFunction(
    Uint8List input, Uint8List salt, int desiredKeyLength,
    {int strength = 262144}) {
  return Result<Uint8List>(() {
    final Uint8List outputList = Uint8List(desiredKeyLength);
    final strongScrypt = pointyCastle.Scrypt();
    strongScrypt.init(
        pointyCastle.ScryptParameters(strength, 8, 1, desiredKeyLength, salt));
    final managedToGenerate = strongScrypt.deriveKey(input, 0, outputList, 0);
    if (managedToGenerate != desiredKeyLength) {
      throw Exception(
          "Failed to generate the right key. Generated: $managedToGenerate bytes, wanted: $desiredKeyLength bytes.");
    }
    return outputList;
  });
}

Result<Uint8List> scryptFromPassphrase(String input, {int strength = 262144}) {
  // returns Result of 256 bit AES key.
  return strongScryptFunction(
      input.toBytes(), "intentionally static salt".toBytes(), 32,
      strength: strength);
}

Future<Uint8List> aesEncrypt(List<int> plaintext, List<int> key) async {
  final keyBytes = Uint8List.fromList(key);
  final plaintextBytes = Uint8List.fromList(plaintext);

  final aes = crypto.AesCbc.with256bits(macAlgorithm: crypto.Hmac.sha512());
  final encrypted =
      await aes.encrypt(plaintextBytes, secretKey: crypto.SecretKey(keyBytes));

  return encrypted.concatenation(nonce: true, mac: true);
}

Future<Uint8List> aesDecrypt(List<int> ciphertext, List<int> key) async {
  final keyBytes = Uint8List.fromList(key);
  final ciphertextBytes = Uint8List.fromList(ciphertext);

  final aes = crypto.AesCbc.with256bits(macAlgorithm: crypto.Hmac.sha512());
  final decrypted = await aes.decrypt(
      crypto.SecretBox.fromConcatenation(ciphertextBytes,
          nonceLength: 16, macLength: 64),
      secretKey: crypto.SecretKey(keyBytes));
  return Uint8List.fromList(decrypted);
}
