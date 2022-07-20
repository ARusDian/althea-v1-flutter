class Users {
  int idUser;
  String username;
  String email;
  String password;
  String role;

  Users({
    required this.idUser,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
  });
}

var listUsers = <Users>[];