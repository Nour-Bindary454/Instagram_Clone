part of 'story_cubit.dart';

abstract class StoryState {}

class StoryInitial extends StoryState {}

class StoryLoading extends StoryState {}

class StorySuccess extends StoryState {}

class StoryError extends StoryState {
  final String error;
  StoryError(this.error);
}
