import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qrscan2/qrscan2.dart' as scanner;
import 'package:permission_handler/permission_handler.dart';

import 'package:althea/model/MQTTManager.dart';
import 'package:althea/model/pasien.dart';

class GetDataPengukuran extends StatefulWidget {
  late Pasien pasien;
  GetDataPengukuran({Key? key, required this.pasien}) : super(key: key);

  @override
  _GetDataPengukuranState createState() =>
      _GetDataPengukuranState(pasien: pasien);
}

class _GetDataPengukuranState extends State<GetDataPengukuran> {
  late Pasien pasien;
  _GetDataPengukuranState({required this.pasien});

  late MqttClient client;

  String qrcode = "";
  String state = 'Disconnected';

  String topic = 'ALTHEATESTER/';

  final TextEditingController _topicsController = TextEditingController();

  Map<String, dynamic> mqttData = {};

  Widget CmdMsg() {
    if (state == 'Disconnected') {
      return Container();
    } else {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 83, 221, 255),
        ),
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10.0),
        child: const Text(
          "Silahkan Kirim Data Pengukuran pada Alat",
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengambilan Data Pasien'),
      ),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: ListView(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          children: [
            Container(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, right: 10, left: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 210, 255, 221),
                border: Border.all(
                  color: const Color.fromARGB(255, 0, 179, 54),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                pasien.namaPasien,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Container(
              padding: const EdgeInsets.only(bottom: 10, right: 10, left: 10),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 210, 255, 221),
                border: Border.all(
                  color: const Color.fromARGB(255, 4, 255, 79),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: TextFormField(
                controller: _topicsController,
                style: const TextStyle(
                    fontSize: 15.0, height: 2.0, color: Colors.black),
                decoration: const InputDecoration(
                  labelText: 'Masukkan Key Token yang muncul di Alat',
                  border: InputBorder.none,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 20, left: 20),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 92, 255, 97),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        state = 'Connecting';
                      });
                      connect().then((value) {
                        print('Connected');
                        client = value;
                        client.subscribe(topic + _topicsController.text,
                            MqttQos.exactlyOnce);
                        client.updates!.listen(
                            (List<MqttReceivedMessage<MqttMessage?>>? c) {
                          final recMess = c![0].payload as MqttPublishMessage;
                          final pt = MqttPublishPayload.bytesToStringAsString(
                              recMess.payload.message);
                          setState(() {
                            mqttData = jsonDecode(pt);
                          });
                        });
                      });
                    },
                    child: const Text(
                      'Ambil Data',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  padding: const EdgeInsets.only(
                      top: 10, bottom: 10, right: 20, left: 20),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 43, 177, 255),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      try {
                        await Permission.camera.request();
                        String? barcode = await scanner.scan();
                        if (barcode == null) {
                          _topicsController.text =
                              'Tidak ad Qr Code Terdeteksi';
                        } else {
                          _topicsController.text = barcode;
                        }
                      } catch (e) {
                        _topicsController.text = e.toString();
                      }
                    },
                    child: const Text(
                      'Scan QrCode',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            CmdMsg(),
            Container(
              margin: const EdgeInsets.only(top: 10, bottom: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.grey,
                  width: 1,
                ),
              ),
              child: DataTable(
                columnSpacing: 0,
                columns: const <DataColumn>[
                  DataColumn(
                    label: Text("No"),
                  ),
                  DataColumn(
                    label: Text("Data"),
                  ),
                  DataColumn(
                    label: Text("Nilai"),
                  ),
                ],
                rows: <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("1"),
                      ),
                      const DataCell(
                        Text("Gender"),
                      ),
                      DataCell(
                        Text(mqttData['gender'] ?? pasien.jenisKelamin),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("2"),
                      ),
                      const DataCell(
                        Text("Umur"),
                      ),
                      DataCell(
                        Text("${mqttData['umur'] ?? ""} Tahun"),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("3"),
                      ),
                      const DataCell(
                        Text("Estimasi Tinggi Badan"),
                      ),
                      DataCell(
                        Text("${mqttData['estimasi_tinggi_badan'] ?? ''} Cm"),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("4"),
                      ),
                      const DataCell(
                        Text("Estimasi Berat Badan"),
                      ),
                      DataCell(
                        Text("${mqttData['estimasi_berat_badan'] ?? ''} Cm"),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("5"),
                      ),
                      const DataCell(
                        Text("Status Gizi"),
                      ),
                      DataCell(
                        Text("${mqttData['status_gizi'] ?? ''}"),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("6"),
                      ),
                      const DataCell(
                        Text("Lingkar Kepala"),
                      ),
                      DataCell(
                        Text("${mqttData['lingkar_kepala'] ?? ''} Cm"),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("7"),
                      ),
                      const DataCell(
                        Text("Lingkar Lengan"),
                      ),
                      DataCell(
                        Text("${mqttData['lingkar_lengan'] ?? ''} Cm"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
