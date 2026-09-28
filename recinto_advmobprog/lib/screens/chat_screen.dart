import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../services/chat_service.dart';
import '../services/presence_service.dart';
import '../widgets/custom_text.dart';
import 'chat_detailscreen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const _indigo = Color(0xFF3949AB);
  static const _indigoDeep = Color(0xFF262E7A);

  final TextEditingController _searchController = TextEditingController();
  final ChatService _chatService = ChatService();
  String _searchText = '';

  // Created once, so typing in the search bar doesn't re-subscribe to Firestore.
  late final Stream<List<Map<String, dynamic>>> _usersStream =
      _chatService.getUsersStream();
  late final Stream<Map<String, String>> _nicknamesStream =
      _chatService.getNicknamesStream();

  // NEW: redraws the list every 30 seconds so green dots don't go stale
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // The person's real name: "First Last", else username, else email.
  String _realName(Map<String, dynamic> user) {
    final first = (user['firstName'] ?? '').toString().trim();
    final last = (user['lastName'] ?? '').toString().trim();
    final full = '$first $last'.trim();
    if (full.isNotEmpty) return full;

    final username = (user['username'] ?? '').toString().trim();
    if (username.isNotEmpty) return username;

    final email = (user['email'] ?? '').toString().trim();
    return email.isNotEmpty ? email : 'Unknown';
  }

  // Enhancement 2: keep only users whose nickname, name or email contains the search text.
  List<Map<String, dynamic>> _filterUsers(
    List<Map<String, dynamic>> users,
    Map<String, String> nicknames,
  ) {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return users;

    return users.where((user) {
      final nickname = (nicknames[user['uid']] ?? '').toLowerCase();
      final name = _realName(user).toLowerCase();
      final email = (user['email'] ?? '').toString().toLowerCase();
      return nickname.contains(query) ||
          name.contains(query) ||
          email.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: CustomText(
          text: 'Chats',
          fontSize: 22.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_indigo, _indigoDeep],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
              onChanged: (value) => setState(() => _searchText = value),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchText.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? const Color(0xFF1C1C1C) : Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Enhancement 1: live list of all other registered users
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _usersStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator.adaptive());
                }
                if (snapshot.hasError) {
                  return _emptyState(Icons.error_outline_rounded, 'Error loading users');
                }

                final allUsers = snapshot.data ?? [];
                if (allUsers.isEmpty) {
                  return _emptyState(
                    Icons.people_outline_rounded,
                    'No other users yet',
                  );
                }

                // Nicknames you set for people (private to you).
                return StreamBuilder<Map<String, String>>(
                  stream: _nicknamesStream,
                  builder: (context, nickSnapshot) {
                    final nicknames = nickSnapshot.data ?? const <String, String>{};
                    final users = _filterUsers(allUsers, nicknames);

                    if (users.isEmpty) {
                      return _emptyState(
                        Icons.search_off_rounded,
                        'No users match "${_searchText.trim()}"',
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                      itemCount: users.length,
                      itemBuilder: (context, index) {
                        final user = users[index];
                        return _buildUserTile(user, nicknames[user['uid']]);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(Map<String, dynamic> user, String? nickname) {
    final hasNickname = nickname != null && nickname.isNotEmpty;
    final realName = _realName(user);
    final name = hasNickname ? nickname : realName;
    final email = (user['email'] ?? 'No email').toString();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final online = PresenceService.isOnline(user); // NEW: is this person online?

    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatDetailScreen(tappedUser: user),
            ),
          );
        },
        leading: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 24.r,
              backgroundColor: _indigo,
              child: CustomText(
                text: initial,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            // NEW: green dot on the avatar = online
            if (online)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 13.w,
                  height: 13.w,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: CustomText(
          text: name,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: CustomText(
          // With a nickname, also show the real name so you know who it is.
          text: hasNickname ? '$realName · $email' : email,
          fontSize: 12.sp,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _emptyState(IconData icon, String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48.sp, color: Colors.grey),
            SizedBox(height: 12.h),
            CustomText(
              text: message,
              fontSize: 15.sp,
              textAlign: TextAlign.center,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}