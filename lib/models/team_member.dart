class TeamMember {
  final String id;
  final String name;
  final String role;
  final String department;
  final String email;
  final bool isLeader;

  const TeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.department,
    required this.email,
    this.isLeader = false,
  });
}