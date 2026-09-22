import 'package:flutter/material.dart';
import '../screens/profile_page.dart';

class ProfileButton extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const ProfileButton({
    super.key,
    this.userName = 'User',
    this.userEmail = 'user@sahyog.com',
    this.userRole = 'Citizen',
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Profile',
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilePage(
              userName: userName,
              userEmail: userEmail,
              userRole: userRole,
            ),
          ),
        );
      },
      icon: const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFFE8F5E9),
        child: Icon(
          Icons.person,
          color: Color(0xFF2E7D32),
          size: 21,
        ),
      ),
    );
  }
}