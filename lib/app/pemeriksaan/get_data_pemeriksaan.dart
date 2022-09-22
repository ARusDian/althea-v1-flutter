import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:qrscan2/qrscan2.dart' as scanner;
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:althea/model/MQTTManager.dart';
import 'package:althea/model/pasien.dart';

enum IotDataState {
  waitingIotData,
  sendingIotData,
  dataAPISended,
}

enum MqttState {
  disconnected,
  connecting,
}

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

  MqttState mqttState = MqttState.disconnected;

  String topic = 'ALTHEATESTER/';

  String statusMessage = '';

  IotDataState iotDataState = IotDataState.waitingIotData;

  final TextEditingController _topicsController = TextEditingController();

  Map<String, dynamic> mqttData = {};

  Widget CmdMsg() {
    if (mqttState == MqttState.disconnected) {
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
                      top: 5, bottom: 5, right: 10, left: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 45, 141, 120),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        mqttState = MqttState.connecting;
                      });
                      connect().then((value) {
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
                            iotDataState = IotDataState.sendingIotData;
                            print(iotDataState);
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
                      top: 5, bottom: 5, right: 10, left: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 34, 142, 204),
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
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 10),
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, right: 10, left: 10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 43, 177, 255),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: TextButton(
                    onPressed: () async {
                      print(iotDataState);
                      if (iotDataState == IotDataState.sendingIotData) {
                        await dotenv.load(fileName: ".env");
                        String url = '${dotenv.env['APISERVER']}';
                        http.post(
                          Uri.parse('$url/api/rekam-pengukuran/store/'),
                          headers: <String, String>{
                            'Content-Type': 'application/json; charset=UTF-8',
                          },
                          body: jsonEncode(<String, dynamic>{
                            "pasienId": pasien.idPasien,
                            "lingkar_lengan": mqttData["lingkarLengan"],
                            "lingkar_kepala": mqttData["lingkarKepala"],
                            "panjang_ulna": mqttData["panjangUlna"],
                            "suhu": mqttData["suhu"],
                            "tinggi_badan": mqttData["tinggiBadan"],
                            "BEE": mqttData["BEE"],
                            "berat_badan": mqttData["beratBadan"],
                            "status_gizi": mqttData["statusGizi"],
                          }),
                        );
                        setState(() {
                          iotDataState = IotDataState.dataAPISended;
                          statusMessage = 'Data Berhasil Dikirim';
                        });
                      } else if (iotDataState == IotDataState.waitingIotData) {
                        statusMessage = 'Tunggu Data dari Alat';
                      } else if (iotDataState == IotDataState.dataAPISended) {
                        statusMessage = 'Data telah dikirim ke Server';
                      } else {
                        statusMessage = 'Data Tidak Ditemukan';
                      }
                      final snackBar = SnackBar(
                        content: Text(statusMessage),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: const Text(
                      'Kirim Data',
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
                        Text("${mqttData['tinggiBadan'] ?? ''} Cm"),
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
                        Text("${mqttData['beratBadan'] ?? ''} Kg"),
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
                        Text("${mqttData['statusGizi'] ?? ''}"),
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
                        Text("${mqttData['lingkarKepala'] ?? ''} Cm"),
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
                        Text("${mqttData['lingkarLengan'] ?? ''} Cm"),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      const DataCell(
                        Text("8"),
                      ),
                      const DataCell(
                        Text("Panjang Ulna"),
                      ),
                      DataCell(
                        Text("${mqttData['panjangUlna'] ?? ''} Cm"),
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
