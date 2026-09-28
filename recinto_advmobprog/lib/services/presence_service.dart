import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;

// Keeps track of who is Online and when they were Last seen.
// It saves two fields in Users/<uid>:
//   isOnline (true/false) and lastSeen (server time).
class PresenceService {
  // One shared copy for the whole app, so there is only one timer.
  PresenceService._();
  static final PresenceService _instance = PresenceService._();
  factory PresenceService() => _instance;

  // While the app is open, we "ping" Firestore this often.
  static const Duration heartbeat = Duration(minutes: 1);

  // Someone counts as Online only if their last ping is newer than this.
  // This protects us when an app is force-closed and can't say "offline".
  static const Duration onlineWindow = Duration(minutes: 2);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _timer;

  // Call when the app opens or comes back to the screen.
  void start() {
    if (_auth.currentUser == null) return;

    _timer?.cancel();
    _write(true); // mark me online right now
    _timer = Timer.periodic(heartbeat, (_) => _write(true)); // then every minute
  }

  // Call when the app goes to the background, or when I log out.
  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    await _write(false); // mark me offline and save the time
  }

  Future<void> _write(bool online) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      // update() (not set) so we never create a half-empty user document.
      await _firestore.collection('Users').doc(uid).update({
        'isOnline': online,
        'lastSeen': FieldValue.serverTimestamp(), // server clock, not the phone's
      }).timeout(const Duration(seconds: 3)); // don't wait forever when offline
    } catch (e) {
      debugPrint('Presence update failed: $e');
    }
  }

  // ---------- Reading the status (used by the screens) ----------

  // Online = marked online AND pinged recently.
  static bool isOnline(Map<String, dynamic> user) {
    if (user['isOnline'] != true) return false;

    final lastSeen = user['lastSeen'];
    if (lastSeen is! Timestamp) return false;

    return DateTime.now().difference(lastSeen.toDate()) < onlineWindow;
  }

  // Text to show: "Online", "Last seen 15 mins ago", or '' if unknown.
  static String statusText(Map<String, dynamic> user) {
    final lastSeen = user['lastSeen'];
    if (lastSeen is! Timestamp) return ''; // never recorded yet

    if (isOnline(user)) return 'Online';
    return 'Last seen ${_timeAgo(lastSeen.toDate())}';
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static String _timeAgo(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '$m ${m == 1 ? 'min' : 'mins'} ago';
    }

    // Older than an hour: compare calendar days.
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(time.year, time.month, time.day);
    final daysApart = today.difference(day).inDays;

    if (daysApart == 0) return 'today at ${_clock(time)}';
    if (daysApart == 1) return 'yesterday at ${_clock(time)}';
    return '${_months[time.month - 1]} ${time.day}';
  }

  static String _clock(DateTime d) {
    final hour = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final minute = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}