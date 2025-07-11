import 'package:flutter/material.dart';
class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _HomeState();
}

class _HomeState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [Text('Hello'), ]);
  }
}

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text("data"),
    );
  }
}
