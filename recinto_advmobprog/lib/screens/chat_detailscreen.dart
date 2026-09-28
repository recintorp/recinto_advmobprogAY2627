import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/chat_wallpaper.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';
import '../widgets/custom_text.dart';

// The three states a message you sent can be in.
enum _MessageStatus { sending, delivered, seen }

// Best available name for a user: "First Last", else username, else email.
String _displayNameOf(Map<String, dynamic> user) {
  final first = (user['firstName'] ?? '').toString().trim();
  final last = (user['lastName'] ?? '').toString().trim();
  final full = '$first $last'.trim();
  if (full.isNotEmpty) return full;

  final username = (user['username'] ?? '').toString().trim();
  if (username.isNotEmpty) return username;

  final email = (user['email'] ?? '').toString().trim();
  return email.isNotEmpty ? email : 'Unknown';
}

class ChatDetailScreen extends StatefulWidget {
  final Map<String, dynamic> tappedUser;

  const ChatDetailScreen({super.key, required this.tappedUser});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  static const _indigo = Color(0xFF3949AB);
  static const _indigoDeep = Color(0xFF262E7A);
  static const _amber = Colors.amber;

  final ChatService _chatService = ChatService();
  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();

  late final String _currentUserId;
  late final String _otherUserId;
  late final String _realName;
  late final String _otherEmail;

  // Streams are created ONCE here (not inside build), so the screen doesn't
  // re-subscribe to Firestore every time it rebuilds.
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _messagesStream;
  late final Stream<Map<String, dynamic>> _settingsStream;

  // Used so only NEW messages play the fade/slide animation,
  // not the whole history every time the screen opens or scrolls.
  final Set<String> _knownIds = {};
  bool _initialLoaded = false;

  // Prevents calling "mark as seen" many times at once.
  bool _markingSeen = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _otherUserId = (widget.tappedUser['uid'] ?? '').toString();
    _realName = _displayNameOf(widget.tappedUser);
    _otherEmail = (widget.tappedUser['email'] ?? '').toString();

    _messagesStream = _chatService.getMessage(_currentUserId, _otherUserId);
    _settingsStream = _chatService.getChatSettingsStream(_otherUserId);
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ---------- Sending ----------

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    // Clear the box right away. The message itself shows up in the list
    // immediately with a "Sending…" label until the server confirms it.
    _msgCtrl.clear();
    _msgFocus.requestFocus();

    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(
        0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }

    _chatService.sendMessage(_otherUserId, text).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    });
  }

  // ---------- Seen ----------

  // If there are messages sent TO me that are still unread, mark them as seen.
  void _markSeenIfNeeded(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (_markingSeen || !mounted) return;

    final hasUnread = docs.any((d) {
      final m = d.data();
      return m['receiverId'] == _currentUserId && m['isRead'] == false;
    });
    if (!hasUnread) return;

    _markingSeen = true;
    _chatService
        .markMessagesAsSeen(_currentUserId, _otherUserId)
        .catchError((e) => debugPrint('Failed to mark messages as seen: $e'))
        .whenComplete(() => _markingSeen = false);
  }

  // ---------- Customize (nickname + wallpaper) ----------

  void _openCustomizeSheet({
    required String nickname,
    required String wallpaperKey,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => _CustomizeSheet(
        realName: _realName,
        initialNickname: nickname,
        initialWallpaperKey: wallpaperKey,
        onSave: (newNickname, newWallpaperKey) {
          _chatService
              .saveChatSettings(
                _otherUserId,
                nickname: newNickname,
                wallpaper: newWallpaperKey,
              )
              .catchError((e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save: $e')),
            );
          });
        },
      ),
    );
  }

  // ---------- Helpers ----------

  String _formatTime(Timestamp ts) {
    final d = ts.toDate();
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // ---------- UI ----------

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Rebuilds only the screen chrome when nickname/wallpaper change.
    return StreamBuilder<Map<String, dynamic>>(
      stream: _settingsStream,
      builder: (context, settingsSnapshot) {
        final settings = settingsSnapshot.data ?? const <String, dynamic>{};
        final nickname = (settings['nickname'] ?? '').toString().trim();
        final wallpaper = ChatWallpaper.byKey(settings['wallpaper']?.toString());

        final shownName = nickname.isNotEmpty ? nickname : _realName;
        final initial = shownName.isNotEmpty ? shownName[0].toUpperCase() : '?';

        return Scaffold(
          appBar: AppBar(
            foregroundColor: Colors.white,
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: false,
            titleSpacing: 0,
            flexibleSpace: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_indigo, _indigoDeep],
                ),
              ),
            ),
            title: Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Colors.white24,
                  child: CustomText(
                    text: initial,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        text: shownName,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (_otherEmail.isNotEmpty)
                        CustomText(
                          text: _otherEmail,
                          fontSize: 11.sp,
                          color: Colors.white70,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Customize chat',
                icon: const Icon(Icons.palette_outlined),
                onPressed: () => _openCustomizeSheet(
                  nickname: nickname,
                  wallpaperKey: wallpaper.key,
                ),
              ),
            ],
          ),
          body: Container(
            // The wallpaper sits behind the messages (null = normal background).
            decoration: wallpaper.decoration,
            child: Column(
              children: [
                Expanded(child: _buildMessageList(isDark, shownName)),
                _buildComposer(isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageList(bool isDark, String shownName) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _messagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _centerMessage(Icons.error_outline_rounded, 'Error loading messages');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        final docs = snapshot.data!.docs;

        // Mark incoming messages as seen (after the frame, never during build).
        WidgetsBinding.instance.addPostFrameCallback((_) => _markSeenIfNeeded(docs));

        if (docs.isEmpty) {
          _initialLoaded = true;
          return _centerMessage(
            Icons.chat_bubble_outline_rounded,
            'No messages yet.\nSay hi to $shownName!',
          );
        }

        // Decide which messages are new (these will animate in).
        final animateFlags =
            docs.map((d) => _initialLoaded && !_knownIds.contains(d.id)).toList();
        _knownIds.addAll(docs.map((d) => d.id));
        _initialLoaded = true;

        return ListView.builder(
          controller: _scrollCtrl,
          reverse: true, // newest message at the bottom
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final msg = MessageModel.fromMap(doc.data());
            final isMe = msg.senderId == _currentUserId;

            final _MessageStatus status;
            if (doc.metadata.hasPendingWrites) {
              status = _MessageStatus.sending;
            } else if (msg.isRead) {
              status = _MessageStatus.seen;
            } else {
              status = _MessageStatus.delivered;
            }

            return _AnimatedMessage(
              key: ValueKey(doc.id),
              animate: animateFlags[index],
              isMe: isMe,
              child: _buildBubble(msg, isMe, status, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildBubble(
    MessageModel msg,
    bool isMe,
    _MessageStatus status,
    bool isDark,
  ) {
    final receivedColor = isDark ? const Color(0xFF2A2A2A) : Colors.grey.shade200;
    final textColor = isMe
        ? Colors.white
        : (isDark ? Colors.white : Colors.black87);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 3.h),
        padding: EdgeInsets.fromLTRB(14.w, 9.h, 14.w, 6.h),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          // My messages: indigo gradient. Their messages: soft grey.
          gradient: isMe
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_indigo, _indigoDeep],
                )
              : null,
          color: isMe ? null : receivedColor,
          // The small "tail" corner points toward the sender.
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(18.r),
            topRight: Radius.circular(18.r),
            bottomLeft: Radius.circular(isMe ? 18.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 18.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicWidth(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomText(
                text: msg.message.isNotEmpty ? msg.message : '[empty]',
                fontSize: 15.sp,
                color: textColor,
              ),
              SizedBox(height: 4.h),
              _buildMeta(msg, isMe, status, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // Time + (for my messages) the status: Sending… / ✓ Delivered / ✓✓ Seen
  Widget _buildMeta(
    MessageModel msg,
    bool isMe,
    _MessageStatus status,
    bool isDark,
  ) {
    final metaColor = isMe
        ? Colors.white.withValues(alpha: 0.75)
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);
    final time = _formatTime(msg.timestamp);

    Widget content;
    if (isMe && status == _MessageStatus.sending) {
      content = Row(
        key: const ValueKey('sending'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 12.sp, color: metaColor),
          SizedBox(width: 4.w),
          CustomText(text: 'Sending…', fontSize: 10.sp, color: metaColor),
        ],
      );
    } else if (isMe) {
      final seen = status == _MessageStatus.seen;
      content = Row(
        key: ValueKey(seen ? 'seen' : 'delivered'),
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(text: time, fontSize: 10.sp, color: metaColor),
          SizedBox(width: 4.w),
          Icon(
            seen ? Icons.done_all_rounded : Icons.done_rounded,
            size: 15.sp,
            color: seen ? _amber : metaColor,
          ),
        ],
      );
    } else {
      content = CustomText(
        key: const ValueKey('time'),
        text: time,
        fontSize: 10.sp,
        color: metaColor,
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: content,
      ),
    );
  }

  Widget _buildComposer(bool isDark) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF121212) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                focusNode: _msgFocus,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  hintStyle: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
                  filled: true,
                  fillColor: isDark ? const Color(0xFF1C1C1C) : Colors.grey.shade100,
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            // The send button lights up only when there is text to send.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _msgCtrl,
              builder: (context, value, _) {
                final canSend = value.text.trim().isNotEmpty;
                return AnimatedScale(
                  scale: canSend ? 1.0 : 0.9,
                  duration: const Duration(milliseconds: 150),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: canSend ? _indigo : Colors.grey.shade400,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      color: Colors.white,
                      disabledColor: Colors.white70,
                      onPressed: canSend ? _send : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _centerMessage(IconData icon, String message) {
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

// Bottom sheet where you set a nickname and pick a wallpaper for this chat.
class _CustomizeSheet extends StatefulWidget {
  final String realName;
  final String initialNickname;
  final String initialWallpaperKey;
  final void Function(String nickname, String wallpaperKey) onSave;

  const _CustomizeSheet({
    required this.realName,
    required this.initialNickname,
    required this.initialWallpaperKey,
    required this.onSave,
  });

  @override
  State<_CustomizeSheet> createState() => _CustomizeSheetState();
}

class _CustomizeSheetState extends State<_CustomizeSheet> {
  static const _indigo = Color(0xFF3949AB);

  late final TextEditingController _nicknameCtrl =
      TextEditingController(text: widget.initialNickname);
  late String _selectedKey = widget.initialWallpaperKey;

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Lifts the sheet above the keyboard while typing the nickname.
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 20.h + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: 'Customize chat',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 2.h),
            CustomText(
              text: 'Only you can see these changes.',
              fontSize: 12.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: _nicknameCtrl,
              maxLength: 30,
              textCapitalization: TextCapitalization.words,
              style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
              decoration: InputDecoration(
                labelText: 'Nickname',
                hintText: widget.realName,
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            CustomText(
              text: 'Wallpaper',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 14.w,
              runSpacing: 12.h,
              children: ChatWallpaper.presets.map(_buildSwatch).toList(),
            ),
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _indigo,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                onPressed: () {
                  widget.onSave(_nicknameCtrl.text, _selectedKey);
                  Navigator.pop(context);
                },
                child: Text(
                  'Save',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwatch(ChatWallpaper wallpaper) {
    final selected = wallpaper.key == _selectedKey;
    final noWallpaper = wallpaper.colors == null;

    return GestureDetector(
      onTap: () => setState(() => _selectedKey = wallpaper.key),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: noWallpaper
                  ? null
                  : LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: wallpaper.colors!,
                    ),
              color: noWallpaper ? Colors.grey.shade300 : null,
              border: Border.all(
                color: selected ? _indigo : Colors.grey.shade400,
                width: selected ? 3 : 1,
              ),
            ),
            child: selected
                ? Icon(
                    Icons.check_rounded,
                    color: wallpaper.isDark ? Colors.white : _indigo,
                  )
                : (noWallpaper
                    ? Icon(
                        Icons.format_color_reset_rounded,
                        size: 20.sp,
                        color: Colors.grey.shade700,
                      )
                    : null),
          ),
          SizedBox(height: 4.h),
          CustomText(text: wallpaper.name, fontSize: 11.sp),
        ],
      ),
    );
  }
}

// Wraps one message bubble with a fade + slide-in animation.
// Messages that were already on screen (history) skip the animation.
class _AnimatedMessage extends StatefulWidget {
  final bool animate;
  final bool isMe;
  final Widget child;

  const _AnimatedMessage({
    super.key,
    required this.animate,
    required this.isMe,
    required this.child,
  });

  @override
  State<_AnimatedMessage> createState() => _AnimatedMessageState();
}

class _AnimatedMessageState extends State<_AnimatedMessage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _fade = curved;
    // My messages slide in from the right, theirs from the left.
    _slide = Tween<Offset>(
      begin: Offset(widget.isMe ? 0.25 : -0.25, 0.15),
      end: Offset.zero,
    ).animate(curved);

    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1; // already visible, no animation
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}