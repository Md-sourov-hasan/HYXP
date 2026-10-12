class ContentItem {
  const ContentItem({
    required this.id,
    required this.title,
    required this.feedType,
    required this.contentType,
    required this.workouts,
    required this.summary,
    required this.body,
    required this.image,
    required this.video,
    required this.isActive,
    required this.isFree,
    required this.createdAt,
    required this.updatedAt,
    required this.bookmarkCount,
    required this.shareCount,
    required this.reactionCount,
    required this.viewCount,
    required this.isBookmarked,
    required this.myReaction,
  });

  final int id;
  final String title;
  final String feedType;
  final String contentType;
  final List<ContentWorkout> workouts;
  final String summary;
  final String body;
  final String image;
  final String video;
  final bool isActive;
  final bool isFree;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int bookmarkCount;
  final int shareCount;
  final int reactionCount;
  final int viewCount;
  final bool isBookmarked;
  final String myReaction;

  String get feedLabel {
    final words = feedType
        .replaceAll('_', ' ')
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty);

    return words
        .map((word) {
          final lower = word.toLowerCase();
          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }

  ContentItem copyWith({
    int? bookmarkCount,
    bool? isBookmarked,
    String? myReaction,
  }) {
    return ContentItem(
      id: id,
      title: title,
      feedType: feedType,
      contentType: contentType,
      workouts: workouts,
      summary: summary,
      body: body,
      image: image,
      video: video,
      isActive: isActive,
      isFree: isFree,
      createdAt: createdAt,
      updatedAt: updatedAt,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      shareCount: shareCount,
      reactionCount: reactionCount,
      viewCount: viewCount,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      myReaction: myReaction ?? this.myReaction,
    );
  }

  factory ContentItem.fromJson(Map<String, dynamic> json) {
    final workoutsJson = json['workouts'];

    return ContentItem(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      title: json['title']?.toString() ?? '',
      feedType: json['feed_type']?.toString() ?? '',
      contentType: json['type']?.toString() ?? '',
      workouts: workoutsJson is List
          ? workoutsJson
                .whereType<Map<String, dynamic>>()
                .map(ContentWorkout.fromJson)
                .toList(growable: false)
          : const [],
      summary: json['summary']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      video: json['video']?.toString() ?? '',
      isActive: json['is_active'] == true,
      isFree: json['is_free'] == true,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(json['updated_at']?.toString() ?? ''),
      bookmarkCount:
          int.tryParse(json['bookmark_count']?.toString() ?? '') ?? 0,
      shareCount: int.tryParse(json['share_count']?.toString() ?? '') ?? 0,
      reactionCount:
          int.tryParse(json['reaction_count']?.toString() ?? '') ?? 0,
      viewCount: int.tryParse(json['view_count']?.toString() ?? '') ?? 0,
      isBookmarked: json['is_bookmarked'] == true,
      myReaction: json['my_reaction']?.toString() ?? '',
    );
  }
}

class ContentWorkout {
  const ContentWorkout({
    required this.id,
    required this.name,
    required this.workoutType,
    required this.metValue,
    required this.time,
    required this.duration,
    required this.distance,
    required this.speed,
    required this.incline,
    required this.isFree,
  });

  final int id;
  final String name;
  final String workoutType;
  final double metValue;
  final String time;
  final String duration;
  final double distance;
  final double speed;
  final double incline;
  final bool isFree;

  factory ContentWorkout.fromJson(Map<String, dynamic> json) {
    return ContentWorkout(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      workoutType: json['workout_type']?.toString() ?? '',
      metValue: double.tryParse(json['met_value']?.toString() ?? '') ?? 0,
      time: json['time']?.toString() ?? '',
      duration: json['duration']?.toString() ?? '',
      distance: double.tryParse(json['distance']?.toString() ?? '') ?? 0,
      speed: double.tryParse(json['speed']?.toString() ?? '') ?? 0,
      incline: double.tryParse(json['incline']?.toString() ?? '') ?? 0,
      isFree: json['is_free'] == true,
    );
  }
}

class ContentBookmarkResult {
  const ContentBookmarkResult({
    required this.contentId,
    required this.isBookmarked,
    required this.bookmarkCount,
    required this.myReaction,
  });

  final int contentId;
  final bool isBookmarked;
  final int bookmarkCount;
  final String myReaction;

  ContentBookmarkResult copyWith({int? bookmarkCount}) {
    return ContentBookmarkResult(
      contentId: contentId,
      isBookmarked: isBookmarked,
      bookmarkCount: bookmarkCount ?? this.bookmarkCount,
      myReaction: myReaction,
    );
  }

  factory ContentBookmarkResult.fromJson(Map<String, dynamic> json) {
    return ContentBookmarkResult(
      contentId: int.tryParse(json['content_id']?.toString() ?? '') ?? 0,
      isBookmarked: json['is_bookmarked'] == true,
      bookmarkCount:
          int.tryParse(json['bookmark_count']?.toString() ?? '') ?? 0,
      myReaction: json['my_reaction']?.toString() ?? '',
    );
  }
}

class ContentBookmarkCount {
  const ContentBookmarkCount({
    required this.contentId,
    required this.bookmarkCount,
  });

  final int contentId;
  final int bookmarkCount;

  factory ContentBookmarkCount.fromJson(Map<String, dynamic> json) {
    return ContentBookmarkCount(
      contentId: int.tryParse(json['content_id']?.toString() ?? '') ?? 0,
      bookmarkCount:
          int.tryParse(json['bookmark_count']?.toString() ?? '') ?? 0,
    );
  }
}
