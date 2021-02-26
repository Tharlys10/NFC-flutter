import 'package:flutter/material.dart';
import 'package:nfc_in_flutter/nfc_in_flutter.dart';
import 'dart:async';
import 'dart:io';

class RecordEditor {
  TextEditingController mediaTypeController;
  TextEditingController payloadController;

  RecordEditor() {
    mediaTypeController = TextEditingController();
    payloadController = TextEditingController();
  }
}

class WriteExampleScreen extends StatefulWidget {
  @override
  _WriteExampleScreenState createState() => _WriteExampleScreenState();
}

class _WriteExampleScreenState extends State<WriteExampleScreen> {
  StreamSubscription<NDEFMessage> _stream;
  List<RecordEditor> _records = [];
  bool _hasClosedWriteDialog = false;

  void _addRecord() {
    setState(() {
      _records.add(RecordEditor());
    });
  }

  void _write(BuildContext context) async {
    List<NDEFRecord> records = _records.map((record) {
      return NDEFRecord.type(
        // record.mediaTypeController.text,
        "text/plain",
        record.payloadController.text,
      );
    }).toList();
    NDEFMessage message = NDEFMessage.withRecords(records);

    // Show dialog on Android (iOS has it's own one)
    if (Platform.isAndroid) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Digitalize aproximando o NFC"),
          actions: <Widget>[
            FlatButton(
              child: const Text("Cancelar"),
              onPressed: () {
                _hasClosedWriteDialog = true;
                _stream?.cancel();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    }

    // Write to the first tag scanned
    await NFC.writeNDEF(message).first;
    if (!_hasClosedWriteDialog) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF000000),
        title: const Text("Escreva um NFC"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Center(
            child: OutlineButton(
              child: const Text("Adicionar registro"),
              onPressed: _addRecord,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text("Tipo: text/plain"),
          ),

          for (var record in _records)

            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text("Registro", style: Theme.of(context).textTheme.body2),
                  // TextFormField(
                  //   controller: record.mediaTypeController,
                  //   decoration: InputDecoration(
                  //     hintText: "Tipo de mídia",
                  //   ),
                  // ),
                  TextFormField(
                    controller: record.payloadController,
                    decoration: InputDecoration(
                      hintText: "Carga útil",
                    ),
                  )
                ],
              ),
            ),
          Center(
            child: RaisedButton(
              child: const Text("Escreva para a tag"),
              onPressed: _records.length > 0 ? () => _write(context) : null,
            ),
          ),
        ],
      ),
    );
  }
}
