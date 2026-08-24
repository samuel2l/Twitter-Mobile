class CreatePostInput {
  const CreatePostInput({
    this.text,
    required this.type,
    this.replyToId,
    this.quotedPostId,
    this.media = const [],
  });

  final String? text;
  final String type;
  final String? replyToId;
  final String? quotedPostId;
  final List<CreatePostMediaInput> media;

  Map<String, dynamic> toJson() {
    return {
      if (text != null && text!.trim().isNotEmpty) 'text': text!.trim(),
      'type': type,
      if (replyToId != null) 'replyToId': replyToId,
      if (quotedPostId != null) 'quotedPostId': quotedPostId,
      if (media.isNotEmpty) 'media': media.map((m) => m.toJson()).toList(),
    };
  }
}

class CreatePostMediaInput {
  const CreatePostMediaInput({
    required this.url,
    required this.type,
    this.sortOrder = 0,
  });

  final String url;
  final String type;
  final int sortOrder;

  Map<String, dynamic> toJson() => {
        'url': url,
        'type': type,
        'sortOrder': sortOrder,
      };
}

class UploadedMedia {
  const UploadedMedia({
    required this.url,
    required this.type,
  });

  final String url;
  final String type;

  factory UploadedMedia.fromJson(Map<String, dynamic> json) {
    return UploadedMedia(
      url: json['url'] as String,
      type: json['type'] as String,
    );
  }
}
