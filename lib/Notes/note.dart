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
