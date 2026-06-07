import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/discover_service.dart';

class DiscoverScreen extends ConsumerWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Discover'),
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.picture_as_pdf), text: 'Public PDFs'),
              Tab(icon: Icon(Icons.quiz), text: 'Global Quizzes'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            PublicPdfsTab(),
            PublicQuizzesTab(),
          ],
        ),
      ),
    );
  }
}

class PublicPdfsTab extends ConsumerWidget {
  const PublicPdfsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pdfsAsync = ref.watch(publicPdfsProvider);

    return pdfsAsync.when(
      data: (pdfs) {
        if (pdfs.isEmpty) return const Center(child: Text('No public PDFs available.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pdfs.length,
          itemBuilder: (context, index) {
            final pdf = pdfs[index];
            final author = pdf['user']['name'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: Text(pdf['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Published by: $author\n${pdf['summary'] ?? ''}'),
                isThreeLine: true,
                trailing: const Icon(Icons.download),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading...')));
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

class PublicQuizzesTab extends ConsumerWidget {
  const PublicQuizzesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizzesAsync = ref.watch(publicQuizzesProvider);

    return quizzesAsync.when(
      data: (quizzes) {
        if (quizzes.isEmpty) return const Center(child: Text('No global quizzes available.'));
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final author = quiz['user']['name'];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.quiz, color: Colors.orange),
                title: Text(quiz['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Topic: ${quiz['topic']} • By: $author'),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting quiz...')));
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
