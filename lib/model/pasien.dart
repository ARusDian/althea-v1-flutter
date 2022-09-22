class Pasien {
  int idPasien;
  String namaPasien;
  String jenisKelamin;
  String tempatLahir;
  String tanggalLahir;
  String alamatPasien;

  Pasien({
    required this.idPasien,
    required this.namaPasien,
    required this.jenisKelamin,
    required this.tempatLahir,
    required this.tanggalLahir,
    required this.alamatPasien,
  });

  factory Pasien.fromJSON(Map<String, dynamic> json) {
    return Pasien(
      idPasien: json['id'],
      namaPasien: json['nama'],
      jenisKelamin: json['gender'],
      tempatLahir: json['tempat_lahir'],
      tanggalLahir: json['tanggal_lahir'],
      alamatPasien: "",
    );
  }
}

var listPasien = <Pasien>[
  Pasien(
    idPasien: 1,
    namaPasien: "Andi Muhammad Rizky",
    tanggalLahir: "12/12/2019",
    tempatLahir: "Jakarta",
    jenisKelamin: "Laki-laki",
    alamatPasien: "Jl. Raya",
  ),
  Pasien(
      idPasien: 2,
      namaPasien: "Nasa",
      tempatLahir: "Jakarta",
      tanggalLahir: "11/12/2018",
      jenisKelamin: "Laki-laki",
      alamatPasien: "Jl. P Hidayatullah"),
  Pasien(
      idPasien: 3,
      namaPasien: "Ainz",
      tempatLahir: "Jakarta",
      tanggalLahir: "11/2/2020",
      jenisKelamin: "Laki-laki",
      alamatPasien: "Jl. P Ponogoro"),
  Pasien(
      idPasien: 4,
      namaPasien: "Luthfi",
      tempatLahir: "Samarinda",
      jenisKelamin: "Laki-laki",
      tanggalLahir: "11/3/2019",
      alamatPasien: "Jl. Imam Bonjol"),
  Pasien(
      idPasien: 5,
      namaPasien: "Melody",
      tempatLahir: "Samarinda",
      jenisKelamin: "Perempuan",
      tanggalLahir: "21/1/2020",
      alamatPasien: "Jl. P.H.M. Soekarno"),
  Pasien(
      idPasien: 6,
      namaPasien: "Rizky",
      jenisKelamin: "Laki-laki",
      tempatLahir: "Samarinda",
      tanggalLahir: "11/1/2020",
      alamatPasien: "Jl. P.H.M. Soekarno"),
  Pasien(
      idPasien: 7,
      namaPasien: "Udin",
      jenisKelamin: "Laki-laki",
      tempatLahir: "Samarinda",
      tanggalLahir: "12/1/2020",
      alamatPasien: "Jl. Hariono"),
  Pasien(
      idPasien: 8,
      namaPasien: "Amin",
      jenisKelamin: "Laki-laki",
      tempatLahir: "Samarinda",
      tanggalLahir: "13/1/2020",
      alamatPasien: "Jl. kartini"),
  Pasien(
      idPasien: 9,
      namaPasien: "laila",
      jenisKelamin: "Permpuan",
      tempatLahir: "Samarinda",
      tanggalLahir: "10/1/2020",
      alamatPasien: "Jl. Spombob"),
  Pasien(
      idPasien: 10,
      namaPasien: "Patrik",
      jenisKelamin: "Laki-laki",
      tempatLahir: "Samarinda",
      tanggalLahir: "15/1/2020",
      alamatPasien: "Jl. Bakso"),
];
