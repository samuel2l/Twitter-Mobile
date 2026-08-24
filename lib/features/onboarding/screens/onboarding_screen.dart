import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../utils/widgets/app_error_view.dart';
import '../../../utils/widgets/app_loading.dart';
import '../providers/onboarding_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final Set<String> _selectedTopicIds = {};
  String? _error;

  Future<void> _submit() async {
    if (_selectedTopicIds.isEmpty || _selectedTopicIds.length > 5) {
      setState(() => _error = 'Pick 1 to 5 topics');
      return;
    }

    setState(() => _error = null);

    await ref
        .read(onboardingSubmitProvider.notifier)
        .submit(_selectedTopicIds.toList());

    final state = ref.read(onboardingSubmitProvider);
    if (state.hasError && mounted) {
      setState(() {
        _error = state.error is AppException
            ? (state.error! as AppException).message
            : 'Could not save interests';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topics = ref.watch(topicsProvider);
    final submitting = ref.watch(onboardingSubmitProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Pick your interests')),
      body: topics.when(
        loading: () => const AppLoading(message: 'Loading topics…'),
        error: (_, __) => AppErrorView(
          message: 'Could not load topics',
          onRetry: () => ref.invalidate(topicsProvider),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('No topics available yet'));
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Choose up to 5 topics to personalize your Explore feed.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final topic in items)
                          FilterChip(
                            label: Text(topic.name),
                            selected: _selectedTopicIds.contains(topic.id),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  if (_selectedTopicIds.length >= 5) return;
                                  _selectedTopicIds.add(topic.id);
                                } else {
                                  _selectedTopicIds.remove(topic.id);
                                }
                                _error = null;
                              });
                            },
                          ),
                      ],
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: submitting ? null : _submit,
                      child: submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Continue (${_selectedTopicIds.length}/5)',
                            ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
