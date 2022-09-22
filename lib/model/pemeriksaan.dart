class Pemeriksaan {
  int idPemeriksaan;
  int idPasien;
  double estimasiTinggiBadan;
  double estimasiBeratBadan;
  double statusGizi;
  double lingkarKepala;
  double lingkarLengan;
  double panjangUlna;
  double suhu;


  Pemeriksaan({
    required this.idPemeriksaan,
    required this.idPasien,
    required this.estimasiTinggiBadan,
    required this.estimasiBeratBadan,
    required this.statusGizi,
    required this.lingkarKepala,
    required this.lingkarLengan,
    required this.panjangUlna,
    required this.suhu,
  });
}
