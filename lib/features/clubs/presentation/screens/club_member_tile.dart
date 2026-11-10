import 'package:flutter/material.dart';
import 'package:seek/features/clubs/domain/entities/club_member.dart';

enum MemberAction { promote, kick }

class ClubMemberTile extends StatelessWidget {
  final ClubMember member;
  final bool isOwner;
  final bool showActions;
  final void Function(MemberAction action)? onAction;

  const ClubMemberTile({
    super.key,
    required this.member,
    this.isOwner = false,
    this.showActions = false,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final initial =
    member.userName.isNotEmpty ? member.userName[0].toUpperCase() : '?';

    return ListTile(
      leading: CircleAvatar(child: Text(initial)),
      title: Text(member.userName.isEmpty ? 'Tanpa nama' : member.userName),
      subtitle: Text(_roleLabel()),
      trailing: showActions
          ? PopupMenuButton<MemberAction>(
        onSelected: (action) => onAction?.call(action),
        itemBuilder: (_) => [
          if (member.role != ClubRole.admin)
            const PopupMenuItem(
              value: MemberAction.promote,
              child: Text('Jadikan admin'),
            ),
          const PopupMenuItem(
            value: MemberAction.kick,
            child: Text('Keluarkan'),
          ),
        ],
      )
          : null,
    );
  }

  String _roleLabel() {
    if (isOwner) return 'Owner';
    return member.role == ClubRole.admin ? 'Admin' : 'Member';
  }
}