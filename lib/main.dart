import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:safefile/Security/main.dart';
import './Notes/note.dart';
import './Security/conversion.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Safe text storage'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _strength = 65536;

  bool checkedForFileExistance = false;

  bool intervalExists = false;
  bool loggedIn = false;
  bool fileDoesNotExist = false;

  String hintToUser = "";

  /// Controller of plaintext / main editor.
  TextEditingController textController = TextEditingController(text: "");

  /// Controller of password editor.
  TextEditingController passwordTextController =
      TextEditingController(text: "");

  TextEditingController newPassword1Controller =
      TextEditingController(text: "");
  TextEditingController newPassword2Controller =
      TextEditingController(text: "");

  Future<Uint8List> get _keyFuture =>
      scryptFromPassphrase(passwordTextController.text, strength: _strength)
          .asFuture;

  _saveChanges() {
    if (loggedIn) {
      _keyFuture.then((key) {
        aesEncrypt(textController.text.toBytes(), key)
            .then((encryptedFileContent) {
          writeToFile(encryptedFileContent).then((x) => null);
        });
      });
    }
  }

  _changePassword() {
    if (newPassword1Controller.text == newPassword2Controller.text &&
        newPassword2Controller.text != "") {
      passwordTextController.text = newPassword2Controller.text;
      _saveChanges();
      setState(() {
        hintToUser = "Password changed!";
      });
    } else {
      setState(() {
        hintToUser = "New passwords do not match!";
      });
    }
  }

  _unlock() {
    readFromFile().then((value) {
      _keyFuture.then((scryptBytes) {
        aesDecrypt(value, scryptBytes).then((decrypted) {
          if (!loggedIn) {
            textController = TextEditingController(text: decrypted.toUTF16());
          }
          setState(() {
            loggedIn = true;
          });
        });
      });
    }).catchError((err) {
      fileDoesNotExist = true;
    });
  }

  _lockFile() {
    textController = TextEditingController(text: "");
    passwordTextController = TextEditingController(text: "");
    setState(() {
      loggedIn = false;
    });
  }

  _setNewPassword() {
    if (newPassword1Controller.text == newPassword2Controller.text &&
        newPassword2Controller.text != "") {
      scryptFromPassphrase(newPassword2Controller.text, strength: _strength)
          .asFuture
          .then((newKey) {
        aesEncrypt("".toBytes(), newKey).then((encryptedFileContent) {
          writeToFile(encryptedFileContent).then((x) {
            passwordTextController.text = newPassword2Controller.text;
            loggedIn = true;
            fileDoesNotExist = false;
            setState(() {
              hintToUser = "Password has been set!";
            });
          });
        });
      });
    } else {
      setState(() {
        hintToUser = "New passwords do not match!";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!checkedForFileExistance) {
      fileExists().then((value) {
        hintToUser = "File existance: $fileDoesNotExist";
        checkedForFileExistance = true;
        setState(() {
          fileDoesNotExist = !value;
        });
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(hintToUser),
            if (fileDoesNotExist)
              Flexible(
                  child: ListView(children: [
                const Text(
                    "Your password (it's really important to remember!)"),
                TextField(
                  controller: newPassword1Controller,
                  obscureText: true,
                ),
                TextField(
                  controller: newPassword2Controller,
                  obscureText: true,
                ),
                ElevatedButton(
                    onPressed: _setNewPassword,
                    child: const Text("Set password"))
              ])),
            if (!fileDoesNotExist)
              Flexible(
                  child: ListView(children: [
                if (!loggedIn) const Text('Password:'),
                if (!loggedIn)
                  TextField(
                    controller: passwordTextController,
                    obscureText: true,
                  ),
                if (!loggedIn)
                  ElevatedButton(
                      onPressed: _unlock, child: const Text('Unlock')),
                if (loggedIn) const Text('Text:'),
                if (loggedIn)
                  TextFormField(
                      maxLengthEnforcement: MaxLengthEnforcement.none,
                      controller: textController,
                      minLines: 5,
                      maxLines: null),
                if (loggedIn)
                  ElevatedButton(
                      onPressed: _saveChanges,
                      child: const Text('Save changes')),
                if (loggedIn)
                  ElevatedButton(
                      onPressed: _lockFile, child: const Text('Lock')),
                if (loggedIn) const Text("New password:"),
                if (loggedIn)
                  TextField(
                    obscureText: true,
                    controller: newPassword1Controller,
                  ),
                if (loggedIn) const Text("Repeat new password:"),
                if (loggedIn)
                  TextField(
                    obscureText: true,
                    controller: newPassword2Controller,
                  ),
                if (loggedIn)
                  ElevatedButton(
                      onPressed: _changePassword,
                      child: const Text("Change password")),
                if (loggedIn)
                  ElevatedButton(
                      child: const Text("Delete file"),
                      onPressed: () {
                        deleteFile();
                        setState(() {
                          fileDoesNotExist = true;
                        });
                      }),
              ])),
          ],
        ),
      ),
    );
  }
}
