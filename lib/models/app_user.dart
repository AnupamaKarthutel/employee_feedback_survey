enum Role {
  admin,
  employee,
}

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
  });

  final String id;
  final String email;
  final Role role;

  bool get isAdmin => role == Role.admin;
  bool get isEmployee => role == Role.employee;
}
