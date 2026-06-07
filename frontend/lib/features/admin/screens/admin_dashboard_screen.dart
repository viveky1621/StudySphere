import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/admin_service.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(platformStatsProvider);
    final usersAsync = ref.watch(usersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: statsAsync.when(
                data: (stats) => _buildStatsCards(stats),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error loading stats: $e', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recent Users',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          usersAsync.when(
            data: (users) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = users[index];
                  final isPremium = user['subscription'] == 'PREMIUM';
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isPremium ? Colors.amber : Colors.grey,
                      child: Icon(isPremium ? Icons.star : Icons.person, color: Colors.white),
                    ),
                    title: Text(user['name']),
                    subtitle: Text('${user['email']} • Role: ${user['role']}'),
                    trailing: isPremium
                        ? const Text('PRO', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
                        : IconButton(
                            icon: const Icon(Icons.arrow_upward),
                            tooltip: 'Upgrade to Premium',
                            onPressed: () async {
                              await ref.read(adminServiceProvider).upgradeUser(user['id']);
                              ref.invalidate(usersListProvider);
                              ref.invalidate(platformStatsProvider);
                            },
                          ),
                  );
                },
                childCount: users.length,
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error loading users: $e')),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/admin/upload'),
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildStatsCards(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(child: _StatCard(title: 'Total Users', value: stats['totalUsers'].toString(), icon: Icons.group)),
        const SizedBox(width: 16),
        Expanded(child: _StatCard(title: 'Premium', value: stats['premiumUsers'].toString(), icon: Icons.workspace_premium)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _StatCard({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
