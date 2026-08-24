import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/models/post.dart';
import '../models/create_post_input.dart';
import '../providers/posts_providers.dart';

class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({
    super.key,
    this.initialType = 'original',
    this.replyToId,
    this.quotedPostId,
    this.quotedPreview,
  });

  final String initialType;
  final String? replyToId;
  final String? quotedPostId;
  final Post? quotedPreview;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  final _textController = TextEditingController();
  final _picker = ImagePicker();
  final List<_PickedMedia> _pendingMedia = [];
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage(imageQuality: 85);
    if (files.isEmpty) return;

    setState(() {
      for (final file in files) {
        if (_pendingMedia.length >= 4) break;
        _pendingMedia.add(
          _PickedMedia(
            path: file.path,
            name: file.name,
            mimeType: file.mimeType ?? 'image/jpeg',
            type: 'image',
          ),
        );
      }
    });
  }

  Future<void> _submit() async {
    final text = _textController.text.trim();
    final isRepost = widget.initialType == 'repost';

    if (!isRepost && text.isEmpty && _pendingMedia.isEmpty) {
      setState(() => _error = 'Add text or media');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final uploaded = <CreatePostMediaInput>[];
      for (var i = 0; i < _pendingMedia.length; i++) {
        final item = _pendingMedia[i];
        final media = await ref.read(composeControllerProvider.notifier).upload(
              filePath: item.path,
              fileName: item.name,
              mimeType: item.mimeType,
            );
        uploaded.add(
          CreatePostMediaInput(
            url: media.url,
            type: media.type,
            sortOrder: i,
          ),
        );
      }

      final created = await ref.read(composeControllerProvider.notifier).submit(
            CreatePostInput(
              text: isRepost ? null : text,
              type: widget.initialType,
              replyToId: widget.replyToId,
              quotedPostId: widget.quotedPostId,
              media: uploaded,
            ),
          );

      if (!mounted) return;
      Navigator.of(context).pop(created);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error is AppException ? error.message : 'Failed to post';
        _submitting = false;
      });
    }
  }

  String get _title {
    return switch (widget.initialType) {
      'reply' => 'Reply',
      'quote' => 'Quote',
      'repost' => 'Repost',
      _ => 'New post',
    };
  }

  @override
  Widget build(BuildContext context) {
    final isRepost = widget.initialType == 'repost';

    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Post'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!isRepost)
            TextField(
              controller: _textController,
              maxLines: null,
              minLines: 5,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: "What's happening?",
                border: InputBorder.none,
              ),
            ),
          if (widget.quotedPreview != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.quotedPreview!.author.name,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (widget.quotedPreview!.displayText.isNotEmpty)
                    Text(widget.quotedPreview!.displayText),
                ],
              ),
            ),
          ],
          if (_pendingMedia.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 88,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _pendingMedia.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(_pendingMedia[index].path),
                          width: 88,
                          height: 88,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 88,
                            height: 88,
                            color: Theme.of(context).colorScheme.surface,
                            child: const Icon(Icons.image),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            setState(() => _pendingMedia.removeAt(index));
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      bottomNavigationBar: isRepost
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _pendingMedia.length >= 4 ? null : _pickImages,
                      icon: const Icon(Icons.image_outlined),
                    ),
                    Text(
                      '${_pendingMedia.length}/4',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _PickedMedia {
  const _PickedMedia({
    required this.path,
    required this.name,
    required this.mimeType,
    required this.type,
  });

  final String path;
  final String name;
  final String mimeType;
  final String type;
}
