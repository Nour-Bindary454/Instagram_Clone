part of 'upload_cubit.dart';

abstract class UploadState {}

class UploadInitial extends UploadState {}
class UploadLoading extends UploadState {}
class UploadSuccess extends UploadState {
  final String fileUrl; 
  UploadSuccess(this.fileUrl);
}
class UploadError extends UploadState {
  final String message;
  UploadError(this.message);
}