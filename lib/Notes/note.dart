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
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart' as path;

Future<io.File> _localFile() async {
  final directory = await path.getApplicationDocumentsDirectory();
  return io.File('${directory.path}/counter.txt');
}

Future<void> writeToFile(Uint8List content) async {
  final file = await _localFile();
  file.writeAsBytes(content, flush: true);
}

Future<Uint8List> readFromFile() async {
  final file = await _localFile();
  return await file.readAsBytes();
}

Future<bool> fileExists() async {
  final file = await _localFile();
  return await file.exists();
}

Future<void> deleteFile() async {
  final file = await _localFile();
  await file.delete();
}
