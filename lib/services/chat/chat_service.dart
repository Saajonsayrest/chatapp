import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:messenger_app/models/message.dart';

class ChatService {
  final FirebaseFirestore _fireStore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get user list
  Stream<List<Map<String, dynamic>>> getUserStream() =>
      _fireStore.collection("Users").snapshots().map(
            (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
          );

  //send message
  Future<void> sendMessage(
      {required String receiverID,String? message, File? audioFile}) async {
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    print("Sender User Id/Current user ID: ${_auth.currentUser!.uid}");
    final Timestamp timestamp = Timestamp.now();

    // Upload audio if present
    String? audioUrl;
    if (audioFile != null) {
      audioUrl = await _uploadAudio(audioFile);
      print('👀Audio URL after upload: $audioUrl'); // Debug statement
      if (audioUrl.isEmpty) {
        print('👀Audio upload failed or URL is empty.'); // Debug statement
        audioUrl = null;
      }
    }

    // Create new message
    final newMessage = Message(
      senderID: currentUserId,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      // Handle empty messages for audio
      timestamp: timestamp,
      audioUrl: audioUrl,
    );

    // Construct chat room ID for 2 users (sorted for uniqueness)
    List<String> ids = [currentUserId, receiverID];
    ids.sort();
    String chatRoomID = ids.join('_');

    // Add new message to database
    await _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .add(newMessage.toMap());
    print('👀Message sent: $message, Audio URL: ${newMessage.audioUrl}'); // Debug statement
  }

  // Get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    // Construct a chatroom ID for the 2 users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');
    return _fireStore
        .collection('chat_rooms')
        .doc(chatRoomID)
        .collection('messages')
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // Upload audio file and return the download URL
  Future<String> _uploadAudio(File audioFile) async {
    try {
      // Ensure the file exists
      if (!audioFile.existsSync()) {
        print('👀Audio file does not exist.');
        return '';
      }

      // Generate a unique filename
      final String fileName = 'audios/${DateTime.now().millisecondsSinceEpoch}.m4a';
      print('👀Generated file path: $fileName'); // Debug statement

      // Reference to the Firebase Storage path
      final Reference ref = _storage.ref().child(fileName);

      // Start the upload
      UploadTask uploadTask = ref.putFile(audioFile);

      // Listen to the upload status
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        print('Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
      }, onError: (e) {
        print('👀Upload error during snapshot: $e');
      });

      // Await completion of the upload
      TaskSnapshot snapshot = await uploadTask;

      // Get the download URL
      String downloadUrl = await snapshot.ref.getDownloadURL();
      print('👀Audio uploaded successfully. URL: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      if (e is FirebaseException && e.code == 'object-not-found') {
        print('👀Failed to upload audio: No object exists at the desired reference.');
      } else {
        print('👀Failed to upload audio: $e');
      }
      return '';
    }
  }

}
