import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Both users always get the same chat room ID (sorted, then joined by "_").
  String getChatRoomId(String userA, String userB) {
    final ids = [userA, userB]..sort();
    return ids.join('_');
  }

  // Live list of all registered users, EXCEPT the one who is logged in.
  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection('Users').snapshots().map((snapshot) {
      final myUid = _auth.currentUser?.uid;
      return snapshot.docs
          .map((doc) {
            final user = Map<String, dynamic>.from(doc.data());
            user['uid'] = user['uid'] ?? doc.id;
            return user;
          })
          .where((user) => user['uid'] != myUid)
          .toList();
    });
  }

  // Saves one message inside chat_rooms/<chatRoomId>/messages
  Future<void> sendMessage(String receiverId, String message) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw Exception('You must be signed in to send a message.');
    }

    final newMessage = MessageModel(
      senderId: currentUser.uid,
      senderEmail: currentUser.email ?? '',
      receiverId: receiverId,
      message: message,
      timestamp: Timestamp.now(),
    );

    await _firestore
        .collection('chat_rooms')
        .doc(getChatRoomId(currentUser.uid, receiverId))
        .collection('messages')
        .add(newMessage.toMap());
  }

  // Live stream of messages (newest first).
  // includeMetadataChanges lets the screen know when a message is still
  // "sending" (not yet confirmed by the server) versus delivered.
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessage(
    String userId,
    String otherUserId,
  ) {
    return _firestore
        .collection('chat_rooms')
        .doc(getChatRoomId(userId, otherUserId))
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots(includeMetadataChanges: true);
  }

  // Marks every unread message sent TO me by this person as seen.
  Future<void> markMessagesAsSeen(
    String currentUserId,
    String otherUserId,
  ) async {
    final messagesRef = _firestore
        .collection('chat_rooms')
        .doc(getChatRoomId(currentUserId, otherUserId))
        .collection('messages');

    final unread = await messagesRef
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unread.docs.isEmpty) return;

    final batch = _firestore.batch();
    for (final doc in unread.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ---------- Personal chat settings (nickname + wallpaper) ----------
  // Saved at: Users/<myUid>/chat_settings/<otherUid>
  // These are private to the logged-in user: your nickname for someone
  // does not change what they see, and vice versa.

  CollectionReference<Map<String, dynamic>>? _settingsCollection() {
    final myUid = _auth.currentUser?.uid;
    if (myUid == null) return null;
    return _firestore.collection('Users').doc(myUid).collection('chat_settings');
  }

  // Live settings (nickname, wallpaper) for ONE chat.
  Stream<Map<String, dynamic>> getChatSettingsStream(String otherUserId) {
    final settings = _settingsCollection();
    if (settings == null) return Stream.value(<String, dynamic>{});

    return settings
        .doc(otherUserId)
        .snapshots()
        .map((snapshot) => snapshot.data() ?? <String, dynamic>{});
  }

  // Live map of { otherUserUid: nickname } for the chat list.
  Stream<Map<String, String>> getNicknamesStream() {
    final settings = _settingsCollection();
    if (settings == null) return Stream.value(<String, String>{});

    return settings.snapshots().map((snapshot) {
      final nicknames = <String, String>{};
      for (final doc in snapshot.docs) {
        final nickname = (doc.data()['nickname'] ?? '').toString().trim();
        if (nickname.isNotEmpty) nicknames[doc.id] = nickname;
      }
      return nicknames;
    });
  }

  // Saves the nickname and/or wallpaper for one chat.
  // An empty nickname removes the nickname.
  Future<void> saveChatSettings(
    String otherUserId, {
    String? nickname,
    String? wallpaper,
  }) async {
    final settings = _settingsCollection();
    if (settings == null) {
      throw Exception('You must be signed in to save chat settings.');
    }

    final data = <String, dynamic>{};
    if (nickname != null) {
      final trimmed = nickname.trim();
      data['nickname'] = trimmed.isEmpty ? FieldValue.delete() : trimmed;
    }
    if (wallpaper != null) data['wallpaper'] = wallpaper;
    if (data.isEmpty) return;

    await settings.doc(otherUserId).set(data, SetOptions(merge: true));
  }

  // From the PDF: finds a user's UID from their email (not used yet).
  Future<String?> getUidByEmail(String email) async {
    final q = await _firestore
        .collection('Users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    if (q.docs.isEmpty) return null;
    return (q.docs.first.data()['uid'] ?? q.docs.first.id).toString();
  }
}