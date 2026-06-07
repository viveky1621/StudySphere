import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/study_tools_service.dart';

final oneDayBattingProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(studyToolsServiceProvider).getStudyPlans();
});

class StudyToolsScreen extends ConsumerWidget {
  const StudyToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Study Tools'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.flash_on), text: '1-Day Batting'),
              Tab(icon: Icon(Icons.style), text: 'Flashcards'),
              Tab(icon: Icon(Icons.quiz), text: 'Quizzes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OneDayBattingTab(),
            FlashcardsTab(),
            QuizzesTab(),
          ],
        ),
      ),
    );
  }
}

class OneDayBattingTab extends ConsumerWidget {
  const OneDayBattingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(oneDayBattingProvider);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Generate high-weightage notes & plans based on previous year questions.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Mock generation
                  await ref.read(studyToolsServiceProvider).generateOneDayBatting("Physics");
                  ref.invalidate(oneDayBattingProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Generated One Day Batting plan!')),
                    );
                  }
                },
                child: const Text('Generate'),
              ),
            ],
          ),
        ),
        Expanded(
          child: plansAsync.when(
            data: (plans) {
              if (plans.isEmpty) return const Center(child: Text('No plans yet.'));
              return ListView.builder(
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  final tasks = plan['tasks'] as List<dynamic>;
                  return ExpansionTile(
                    title: Text(plan['title']),
                    leading: const Icon(Icons.sports_cricket, color: Colors.deepPurple),
                    children: tasks.map((t) => CheckboxListTile(
                      value: t['isCompleted'],
                      onChanged: (val) {},
                      title: Text(t['title']),
                    )).toList(),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

class FlashcardsTab extends ConsumerWidget {
  const FlashcardsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flashcardsAsync = ref.watch(flashcardsProvider);

    return flashcardsAsync.when(
      data: (flashcards) {
        if (flashcards.isEmpty) {
          return const Center(child: Text('No flashcards due for review right now! 🎉'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: flashcards.length,
          itemBuilder: (context, index) {
            final card = flashcards[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(card['front']),
                subtitle: const Text('Tap to review'),
                trailing: const Icon(Icons.flip),
                onTap: () {
                  // Navigate to flashcard review screen
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class QuizzesTab extends ConsumerWidget {
  const QuizzesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(quizzesProvider);

    return quizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) {
          return const Center(child: Text('Generate a quiz from a PDF first!'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(quiz['title']),
                subtitle: Text('Topic: ${quiz['topic']} | Score: ${quiz['score'] ?? 'Not attempted'}'),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  // Navigate to taking the quiz
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
