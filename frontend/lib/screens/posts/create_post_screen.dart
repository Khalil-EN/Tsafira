import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
import '../../providers/post_composer_provider.dart';
import '../../services/api_services.dart';
import '../../widgets/community/community_selector_sheet.dart';
import '../../widgets/posts/post_composer_fields.dart';
import '../../widgets/posts/post_composer_sheets.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  static const int _maxCharacters = 500;

  late final TextEditingController _textController;
  late final FocusNode _textFocusNode;

  @override
  void initState() {
    super.initState();

    _textController = TextEditingController();
    _textFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final composer = context.read<PostComposerProvider>();
      _textController.text = composer.draft.text;
      _textController.addListener(_onTextChanged);
    });
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _textController.text;

    if (text.length > _maxCharacters) {
      _textController.value = _textController.value.copyWith(
        text: text.substring(0, _maxCharacters),
        selection: TextSelection.collapsed(offset: _maxCharacters),
      );
      return;
    }

    context.read<PostComposerProvider>().setText(text);
  }

  Future<void> _submit() async {
    final composer = context.read<PostComposerProvider>();
    final draft = composer.draft;

    if (!draft.canSubmit || composer.isSubmitting) return;

    _textFocusNode.unfocus();
    composer.setSubmitting(true);

    try {
      final response = await PostService.create(draft.toRequestBody());

      if (!mounted) return;

      composer.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post published successfully.')));

      Navigator.of(context).pop(response);
    } catch (error) {
      if (!mounted) return;

      composer.setError('We could not publish your post. Please try again.');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not publish your post. Please try again.')),
      );
    } finally {
      if (mounted) composer.setSubmitting(false);
    }
  }

  Future<void> _close() async {
    final composer = context.read<PostComposerProvider>();

    if (!composer.draft.hasText &&
        !composer.draft.hasImages &&
        composer.draft.communityId == null &&
        composer.draft.location == null) {
      composer.clear();
      Navigator.of(context).pop();
      return;
    }

    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Discard post?'),
          content: const Text('Your changes will be lost if you leave now.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep editing')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Discard')),
          ],
        );
      },
    );

    if (shouldDiscard == true && mounted) {
      composer.clear();
      Navigator.of(context).pop();
    }
  }

  Future<void> _showVisibilitySelector() async {
    final composer = context.read<PostComposerProvider>();

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => VisibilitySheet(selectedVisibility: composer.draft.visibility),
    );

    if (!mounted || selected == null) return;

    composer.setVisibility(selected);
  }

  Future<void> _showCommunitySelector() async {
    final composer = context.read<PostComposerProvider>();

    final selected = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommunitySelectorSheet(selectedCommunityId: composer.draft.communityId),
    );

    if (!mounted) return;

    composer.setCommunity(selected);
  }

  Future<void> _showAttachmentMenu() async {
    final action = await showModalBottomSheet<PostAttachmentAction>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const AttachmentSheet(),
    );

    if (!mounted || action == null) return;

    switch (action) {
      case PostAttachmentAction.photo:
        await _addPhotoPlaceholder();
        break;
      case PostAttachmentAction.feeling:
        await _showFeelingPicker();
        break;
      case PostAttachmentAction.location:
        await _showLocationDialog();
        break;
      case PostAttachmentAction.community:
        await _showCommunitySelector();
        break;
    }
  }

  Future<void> _addPhotoPlaceholder() async {
    /*
     * Image picking is intentionally isolated from the composer.
     *
     * Once you choose the image-picker package you want to use,
     * this method becomes:
     *
     *   final result = await ImagePicker().pickMultiImage();
     *
     * and then:
     *
     *   context.read<PostComposerProvider>().addImages(...);
     *
     * We are not pretending local image paths are upload URLs.
     */
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo picker will be connected next.')),
    );
  }

  Future<void> _showFeelingPicker() async {
    final feeling = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeelingSheet(),
    );

    if (!mounted || feeling == null) return;

    final currentText = _textController.text;
    final newText = currentText.trim().isEmpty ? feeling : '$currentText $feeling';

    _textController.text = newText;
    _textController.selection = TextSelection.collapsed(offset: _textController.text.length);
  }

  Future<void> _showLocationDialog() async {
    final controller = TextEditingController(
      text: context.read<PostComposerProvider>().draft.location ?? '',
    );

    final location = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add location'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Where are you?', prefixIcon: Icon(Icons.location_on_outlined)),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Add')),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || location == null) return;

    context.read<PostComposerProvider>().setLocation(location.isEmpty ? null : location);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    return Consumer<PostComposerProvider>(
      builder: (context, composer, _) {
        final draft = composer.draft;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: composer.isSubmitting ? null : _close,
              icon: const Icon(Icons.close),
              tooltip: 'Close',
            ),
            centerTitle: true,
            title: const Text('Create Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PublishButton(enabled: composer.canSubmit, loading: composer.isSubmitting, onPressed: _submit),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AuthorHeader(
                          name: user.fullName.isEmpty ? 'You' : user.fullName,
                          avatar: user.avatar,
                          visibility: draft.visibility,
                          onVisibilityTap: _showVisibilitySelector,
                        ),
                        const SizedBox(height: 24),
                        TextComposer(
                          controller: _textController,
                          focusNode: _textFocusNode,
                          characterCount: draft.text.length,
                          maxCharacters: _maxCharacters,
                        ),
                        if (draft.imagePaths.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          ImagePreviewGrid(images: draft.imagePaths, onRemove: composer.removeImageAt),
                        ],
                        if (draft.communityId != null) ...[
                          const SizedBox(height: 16),
                          SelectedOptionChip(
                            icon: Icons.groups_outlined,
                            label: 'Community selected',
                            onRemove: () => composer.setCommunity(null),
                          ),
                        ],
                        if (draft.location != null) ...[
                          const SizedBox(height: 12),
                          SelectedOptionChip(
                            icon: Icons.location_on_outlined,
                            label: draft.location!,
                            onRemove: () => composer.setLocation(null),
                          ),
                        ],
                        const SizedBox(height: 28),
                        const Text('Add to your post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 14),
                        AttachmentCard(
                          icon: Icons.photo_library_outlined,
                          title: 'Photos',
                          subtitle: 'Add photos to your post',
                          onTap: _addPhotoPlaceholder,
                        ),
                        const SizedBox(height: 10),
                        AttachmentCard(
                          icon: Icons.emoji_emotions_outlined,
                          title: 'Feeling',
                          subtitle: 'Share how you feel',
                          onTap: _showFeelingPicker,
                        ),
                        const SizedBox(height: 10),
                        AttachmentCard(
                          icon: Icons.location_on_outlined,
                          title: 'Location',
                          subtitle: draft.location ?? 'Add a location',
                          onTap: _showLocationDialog,
                        ),
                        const SizedBox(height: 10),
                        AttachmentCard(
                          icon: Icons.groups_outlined,
                          title: 'Community',
                          subtitle: draft.communityId == null ? 'Post to a community' : 'Community selected',
                          onTap: _showCommunitySelector,
                        ),
                        if (composer.error != null) ...[
                          const SizedBox(height: 20),
                          ErrorBanner(message: composer.error!),
                        ],
                      ],
                    ),
                  ),
                ),
                BottomActionBar(onAddAttachment: _showAttachmentMenu, enabled: !composer.isSubmitting),
              ],
            ),
          ),
        );
      },
    );
  }
}