import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_compress/video_compress.dart';
import 'package:instagram_clone/core/constants.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudinaryPublic cloudinary = CloudinaryPublic(
      AppConstants.cloudinaryCloudName, AppConstants.cloudinaryUploadPreset,
      cache: false);

  Future<void> createPost(
      {required List<File> files, required String caption}) async {
    List<String> downloadUrls = [];
    String uid = _auth.currentUser?.uid ?? 'unknown_user';

    for (var file in files) {
      if (!file.existsSync()) {
        throw Exception(
            "عذراً، مسار هذا الملف غير موجود أو لا يمكن قراءته من المعرض.");
      }
      if (file.lengthSync() == 0) {
        throw Exception(
            "هذا الملف حجمه 0 بايت (فارغ أو تالف) ولا يمكن رفعه. يرجى تجربة فيديو آخر.");
      }

      String extension = file.path.contains('.')
          ? file.path.split('.').last.toLowerCase()
          : 'mp4';

      File fileToUpload = file;
      CloudinaryResourceType resourceType = CloudinaryResourceType.Image;

      if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
        resourceType = CloudinaryResourceType.Video;
        MediaInfo? mediaInfo = await VideoCompress.compressVideo(
          file.path,
          quality: VideoQuality.DefaultQuality,
          deleteOrigin: false,
          includeAudio: true,
        );

        if (mediaInfo != null && mediaInfo.file != null) {
          fileToUpload = mediaInfo.file!;
        }
      }

      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(fileToUpload.path, resourceType: resourceType),
      );

      downloadUrls.add(response.secureUrl);
    }

    await _firestore.collection('posts').add({
      'userId': uid,
      'username': _auth.currentUser?.email?.split('@')[0] ?? 'User',
      'mediaUrls': downloadUrls,
      'caption': caption,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
