import 'package:equatable/equatable.dart';
import '../../data/models/bookmark_model.dart';

class QuranState extends Equatable {
  final int currentPage;
  final bool isTableOfContentsVisible;
  final List<QuranBookmark> bookmarks;
  final bool isBookmarksVisible;
  
  const QuranState({
    this.currentPage = 1,
    this.isTableOfContentsVisible = true,
    this.bookmarks = const [],
    this.isBookmarksVisible = false,
  });
  
  QuranState copyWith({
    int? currentPage,
    bool? isTableOfContentsVisible,
    List<QuranBookmark>? bookmarks,
    bool? isBookmarksVisible,
  }) {
    return QuranState(
      currentPage: currentPage ?? this.currentPage,
      isTableOfContentsVisible: isTableOfContentsVisible ?? this.isTableOfContentsVisible,
      bookmarks: bookmarks ?? this.bookmarks,
      isBookmarksVisible: isBookmarksVisible ?? this.isBookmarksVisible,
    );
  }
  
  @override
  List<Object> get props => [currentPage, isTableOfContentsVisible, bookmarks, isBookmarksVisible];
}