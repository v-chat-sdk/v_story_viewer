import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

Future<void> showUserProfile(BuildContext context, VStoryUser user) async {
  await showModalBottomSheet(
    context: context,
    builder: (ctx) => Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(user.imageUrl),
            radius: 50,
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('User ID: ${user.id}'),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProfileStat('Posts', '42'),
              _buildProfileStat('Followers', '1.2K'),
              _buildProfileStat('Following', '180'),
            ],
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('View Full Profile'),
          ),
        ],
      ),
    ),
  );
}

Widget _buildProfileStat(String label, String value) {
  return Column(
    children: [
      Text(value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      Text(label, style: const TextStyle(color: Colors.grey)),
    ],
  );
}

Future<bool> showStoryMenu(
  BuildContext context,
  VStoryGroup group,
  VStoryItem item,
) async {
  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.flag_outlined),
            title: const Text('Report'),
            onTap: () => Navigator.pop(ctx, 'report'),
          ),
          ListTile(
            leading: const Icon(Icons.volume_off_outlined),
            title: Text('Mute ${group.user.name}'),
            onTap: () => Navigator.pop(ctx, 'mute'),
          ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: Text('Block ${group.user.name}'),
            onTap: () => Navigator.pop(ctx, 'block'),
          ),
          ListTile(
            leading: const Icon(Icons.share_outlined),
            title: const Text('Share'),
            onTap: () => Navigator.pop(ctx, 'share'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Delete', style: TextStyle(color: Colors.red)),
            onTap: () => Navigator.pop(ctx, 'delete'),
          ),
        ],
      ),
    ),
  );
  if (action != null && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Action: $action for ${group.user.name}')),
    );
  }
  return true;
}
