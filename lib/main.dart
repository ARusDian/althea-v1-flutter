import 'package:althea/app/components/navbar_bottom.dart';
import 'package:althea/app/dashboard/tambah_pasien.dart';
import 'package:flutter/material.dart';

import 'app/pemeriksaan/get_data_pemeriksaan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
	const MyApp({Key? key}) : super(key: key);

		
	@override
	Widget build(BuildContext context) {
		return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // home:const GetDataPengukuran()
      home: MainPage(),
      // home: const TambahPasien()
		// home: const MyHomePage(title: 'Flutter Demo Home Page'),
		);
	}
}