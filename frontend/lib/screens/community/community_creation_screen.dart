import 'package:flutter/material.dart';
import '../../services/api_services.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() =>
      _CreateCommunityScreenState();
}

class _CreateCommunityScreenState
    extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _descriptionController =
  TextEditingController();

  bool _isLoading = false;

  static const int _maxNameLength = 50;
  static const int _maxDescriptionLength = 250;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createCommunity() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final String name = _nameController.text.trim();
    final String description =
    _descriptionController.text.trim();

    setState(() {
      _isLoading = true;
    });

    try {
      final Map<String, dynamic> community =
      await CommunityService.create(
        name: name,
        description: description,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Community created successfully!',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, community);
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not create community: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Community',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    12,
                    20,
                    24,
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      // --------------------------------------------------
                      // HEADER
                      // --------------------------------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color:
                          colorScheme.primaryContainer,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.groups_rounded,
                                color:
                                colorScheme.onPrimary,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Bring people together',
                              style: theme
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                fontWeight:
                                FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Create a space where people can '
                                  'share interests, discover ideas, '
                                  'and connect.',
                              style: theme
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                color: colorScheme
                                    .onPrimaryContainer
                                    .withOpacity(0.75),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // --------------------------------------------------
                      // SECTION TITLE
                      // --------------------------------------------------

                      Text(
                        'Community details',
                        style: theme
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Choose a clear name and tell people '
                            'what your community is about.',
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color:
                          colorScheme.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // COMMUNITY NAME
                      // --------------------------------------------------

                      Text(
                        'Community name',
                        style: theme
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _nameController,
                        enabled: !_isLoading,
                        maxLength: _maxNameLength,
                        textInputAction:
                        TextInputAction.next,
                        textCapitalization:
                        TextCapitalization.words,
                        decoration: InputDecoration(
                          hintText:
                          'e.g. Morocco Travel Lovers',
                          prefixIcon: const Icon(
                            Icons.groups_outlined,
                          ),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                            borderSide:
                            BorderSide.none,
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                            borderSide:
                            BorderSide.none,
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color:
                              colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          counterText: '',
                        ),
                        validator: (value) {
                          final String name =
                              value?.trim() ?? '';

                          if (name.isEmpty) {
                            return 'Enter a community name.';
                          }

                          if (name.length < 2) {
                            return 'Name must be at least 2 characters.';
                          }

                          if (name.length >
                              _maxNameLength) {
                            return 'Name is too long.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment:
                        Alignment.centerRight,
                        child: ValueListenableBuilder<
                            TextEditingValue>(
                          valueListenable:
                          _nameController,
                          builder:
                              (context, value, child) {
                            return Text(
                              '${value.text.length}/$_maxNameLength',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: colorScheme
                                    .onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // --------------------------------------------------
                      // DESCRIPTION
                      // --------------------------------------------------

                      Text(
                        'Description',
                        style: theme
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      const SizedBox(height: 8),

                      TextFormField(
                        controller:
                        _descriptionController,
                        enabled: !_isLoading,
                        maxLength:
                        _maxDescriptionLength,
                        maxLines: 5,
                        minLines: 3,
                        textCapitalization:
                        TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText:
                          'What is this community about?',
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(
                              bottom: 72,
                            ),
                            child: Icon(
                              Icons.description_outlined,
                            ),
                          ),
                          alignLabelWithHint: true,
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                            borderSide:
                            BorderSide.none,
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                            borderSide:
                            BorderSide.none,
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color:
                              colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          counterText: '',
                        ),
                        validator: (value) {
                          final String description =
                              value?.trim() ?? '';

                          if (description.length >
                              _maxDescriptionLength) {
                            return 'Description is too long.';
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment:
                        Alignment.centerRight,
                        child: ValueListenableBuilder<
                            TextEditingValue>(
                          valueListenable:
                          _descriptionController,
                          builder:
                              (context, value, child) {
                            return Text(
                              '${value.text.length}/$_maxDescriptionLength',
                              style: theme
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                color: colorScheme
                                    .onSurfaceVariant,
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // --------------------------------------------------
                      // INFORMATION BOX
                      // --------------------------------------------------

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme
                              .surfaceContainerHighest,
                          borderRadius:
                          BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color:
                              colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Your community will be created '
                                    'as public by default. You can '
                                    'manage its settings later.',
                                style: theme
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ----------------------------------------------------------
              // CREATE BUTTON
              // ----------------------------------------------------------

              Container(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  16,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                      color:
                      Colors.black.withOpacity(0.06),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed:
                    _isLoading
                        ? null
                        : _createCommunity,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_rounded,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Create Community',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

