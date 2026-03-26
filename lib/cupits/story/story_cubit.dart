import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_compress/video_compress.dart';

part 'story_state.dart';

class StoryCubit extends Cubit<StoryState> {
  StoryCubit() : super(StoryInitial());

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;
  
  final cloudinary = CloudinaryPublic('dewjx1auh', 'insta_clone_preset', cache: false);

  Future<void> addStory(File file) async {
    emit(StoryLoading());
    try {
      String uid = _auth.currentUser?.uid ?? 'unknown_user';
      String username = _auth.currentUser?.email?.split('@')[0] ?? 'User';

      if (!file.existsSync()) {
        throw Exception("File not found");
      }

      String extension = file.path.contains('.') ? file.path.split('.').last.toLowerCase() : 'jpg';
      File fileToUpload = file;
      CloudinaryResourceType resourceType = CloudinaryResourceType.Image;
      String type = 'image';

      if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
        type = 'video';
        resourceType = CloudinaryResourceType.Video;
        // Compress the story video for faster load times
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

      // Save story to Firestore
      await _firestore.collection('stories').add({
        'userId': uid,
        'username': username,
        'mediaUrl': response.secureUrl,
        'type': type,
        'timestamp': FieldValue.serverTimestamp(),
      });

      emit(StorySuccess());
    } catch (e) {
      emit(StoryError(e.toString()));
    }
  }
}
