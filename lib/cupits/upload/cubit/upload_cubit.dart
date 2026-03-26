import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/repositories/post_repository.dart';

part 'upload_state.dart';

class UploadCubit extends Cubit<UploadState> {
  final PostRepository _postRepository = PostRepository();

  UploadCubit() : super(UploadInitial());

  Future<void> createPost({required List<File> files, required String caption}) async {
    emit(UploadLoading());
    try {
      await _postRepository.createPost(files: files, caption: caption);
      emit(UploadSuccess("Post Shared Successfully")); 
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        emit(UploadError("فشل العثور على مسار الفيديو المرفوع (قد يكون حجم الفيديو كبيراً جداً أو مسار الملف غير مدعوم). الرجاء المحاولة بفيديو آخر."));
      } else {
        emit(UploadError("خطأ في السيرفر: ${e.message}"));
      }
    } catch (e) {
      emit(UploadError(e.toString()));
    }
  }
}