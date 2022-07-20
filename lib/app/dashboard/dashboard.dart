import 'package:althea/app/pemeriksaan/get_data_pemeriksaan.dart';
import 'package:althea/model/pasien.dart';
import 'package:flutter/material.dart';
    
class Dashboard extends StatefulWidget {
  Dashboard({ Key? key }) : super(key: key);

  @override
  _ListDataViewState createState() => _ListDataViewState();
}

class _ListDataViewState extends State<Dashboard> {

  List<Pasien> dataPasien = listPasien;
  List<Pasien> items = <Pasien>[];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    items.addAll(dataPasien);
  }

  void filterSearchResults(String query) {
    List<Pasien> dummySearchList = [];
    dummySearchList.addAll(dataPasien);
    if(query.isNotEmpty) {
      List<Pasien> dummyListData = <Pasien>[];
      dummySearchList.forEach((item) {
        if(item.namaPasien.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
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
            child:Row(
              children: [
                Expanded(
                  child:Container(
                    padding: const EdgeInsets.all(10.0),
                    child:TextFormField(
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
                  onPressed: (){
                  },
                  child: const Text(
                    'Tambah Pasien\nBaru'
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
            print("Tapped item ${index + 1}");
            Navigator.push(context,MaterialPageRoute(builder: (context) =>
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

