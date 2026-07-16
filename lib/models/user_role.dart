enum UserRole {
  guest(0),
  staff(1),
  supervisor(2),
  executive(3);

  final int level;
  const UserRole(this.level);

  // Helper to check if a user has at least the required role
  bool hasAccess(UserRole required) => level >= required.level;
}