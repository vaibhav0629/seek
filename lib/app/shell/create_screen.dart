import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seek/app/router/app_routes.dart';

/// The "Create" tab: a small menu that opens the create flows.
class CreateScreen extends StatelessWidget {
  const CreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text('New club'),
            subtitle: const Text('Start a group for your sport'),
            onTap: () => context.push(AppRoutes.newClub),
          ),
          ListTile(
            leading: const Icon(Icons.event),
            title: const Text('New meet'),
            subtitle: const Text('Schedule a session for a club'),
            onTap: () => context.push(AppRoutes.newMeet),
          ),
        ],
      ),
    );
  }
}
