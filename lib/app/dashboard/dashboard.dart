import 'package:althea/app/pemeriksaan/get_data_pemeriksaan.dart';
import 'package:althea/model/pasien.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _ListDataViewState createState() => _ListDataViewState();
}

class _ListDataViewState extends State<Dashboard> {
  List<Pasien> dataPasien = [];
  // List<Pasien> items = <Pasien>[...listPasien];
  List<Pasien> items = [];
  final _searchController = TextEditingController();
  String statusMessage = '';

  @override
  void initState() {
    super.initState();
    _getDataPasien();
    items.addAll(dataPasien);
  }

  void _getDataPasien() async {
    http.Response? response;
    try {
      await dotenv.load(fileName: ".env");
      String url = '${dotenv.env['APISERVER']}';
      print(url);
      response = await http.get(Uri.parse('$url/api/pasien'));
      dataPasien.clear();

      dataPasien = <Pasien>[
        for (var data in convert.jsonDecode(response.body))
          Pasien.fromJSON(data)
      ];
      items.clear();
      items = [...dataPasien];
    } catch (e) {
      print(e);
    } finally {
      if (response != null) {
        setState(() {
          statusMessage = (response?.statusCode == 200)
              ? "Data Pasien Berhasil diambil sebanyak ${dataPasien.length}"
              : "Gagal diambil Data Pasien";
        });
      } else {
        setState(() {
          statusMessage = "Server bermasalah";
        });
      }
    }
  }

  void filterSearchResults(String query) {
    List<Pasien> dummySearchList = [];
    dummySearchList.addAll(dataPasien);
    if (query.isNotEmpty) {
      List<Pasien> dummyListData = <Pasien>[];
      for (var item in dummySearchList) {
        if (item.namaPasien.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      }
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(dataPasien);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: ListView(
        children: [
          Container(
            margin: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: TextFormField(
                      controller: _searchController,
                      onChanged: (value) {
                        filterSearchResults(value);
                      },
                      decoration: InputDecoration(
                        labelText: 'Nama',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _getDataPasien();
                      final snackBar = SnackBar(
                        content: Text(statusMessage),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      );
                      // Find the ScaffoldMessenger in the widget tree
                      // and use it to show a SnackBar.
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      items.addAll(dataPasien);
                    });
                  },
                  child: const Text(
                    'Refresh',
                  ),
                )
              ],
            ),
          ),
          ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              GetDataPengukuran(pasien: items[index])));
                },
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  margin: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(items[index].namaPasien),
                      Text(items[index].jenisKelamin),
                      Text(items[index].tanggalLahir),
                    ],
                  ),
                ),
              );
            },
            itemCount: items.length,
          ),
        ],
      ),
    );
  }
}
