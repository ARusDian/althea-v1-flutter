class Pemeriksaan{
	int idPemeriksaan;
	int idPasien;
  String gender;
  String estimasiTinggiBadan;
  String estimasiBeratBadan;
  String statusGizi;
  String lingkarKepala;
  String lingkarLengan;

	Pemeriksaan({
		required this.idPemeriksaan,
		required this.idPasien,
    required this.gender,
    required this.estimasiTinggiBadan,
    required this.estimasiBeratBadan,
    required this.statusGizi,
    required this.lingkarKepala,
    required this.lingkarLengan
	});
}