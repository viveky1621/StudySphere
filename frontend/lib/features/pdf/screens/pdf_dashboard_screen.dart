import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../auth/services/auth_service.dart';
import '../services/pdf_service.dart';

class PdfDashboardScreen extends ConsumerWidget {
  const PdfDashboardScreen({super.key});

  void _handleLogout(BuildContext context, WidgetRef ref) {
    ref.read(authServiceProvider).logout();
    context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StudySphere Hub', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ).animate().fadeIn(delay: 200.ms).scale(),
        ],
      ),
      drawer: _buildDrawer(context, ref),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Categories'),
            _buildCategories(context),
            const SizedBox(height: 24),
            _buildSectionTitle('Recently Added'),
            _buildRecentUploads(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Master Your Studies',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'Access PUC and Engineering study materials anytime, anywhere.',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildCategories(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _buildCategoryCard(
              context,
              title: 'PUC',
              icon: Icons.school,
              color: Colors.orange,
              onTap: () => context.push('/puc'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildCategoryCard(
              context,
              title: 'Engineering',
              icon: Icons.engineering,
              color: Colors.blue,
              onTap: () => context.push('/engineering'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withOpacity(0.2),
              color.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
          ],
        ),
      ),
    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
     .shimmer(duration: 3.seconds, color: Colors.white24)
     .animate().scale(delay: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildRecentUploads(BuildContext context, WidgetRef ref) {
    final pdfsAsync = ref.watch(pdfServiceProvider).fetchPdfs();
    
    return FutureBuilder(
      future: pdfsAsync,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Failed to load recent PDFs.'));
        }
        
        final pdfs = snapshot.data as List<dynamic>;
        if (pdfs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('No PDFs uploaded yet.')),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pdfs.length > 5 ? 5 : pdfs.length,
          itemBuilder: (context, index) {
            final pdf = pdfs[index];
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                ),
                title: Text(pdf['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(pdf['category']?['name'] ?? 'Uncategorized', style: TextStyle(color: Colors.white.withOpacity(0.6))),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.arrow_forward_ios, size: 14, color: Theme.of(context).colorScheme.primary),
                ),
                onTap: () {
                  context.push('/pdf_viewer?pdfUrl=${Uri.encodeComponent(pdf['fileUrl'])}&title=${Uri.encodeComponent(pdf['title'])}');
                },
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
          },
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context, WidgetRef ref) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Text('StudySphere Hub', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.white),
            title: const Text('Home'),
            onTap: () => context.pop(),
          ),
          ListTile(
            leading: const Icon(Icons.school, color: Colors.white),
            title: const Text('PUC'),
            onTap: () {
              context.pop();
              context.push('/puc');
            },
          ),
          ListTile(
            leading: const Icon(Icons.engineering, color: Colors.white),
            title: const Text('Engineering'),
            onTap: () {
              context.pop();
              context.push('/engineering');
            },
          ),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Colors.white),
            title: const Text('Admin Panel'),
            onTap: () {
              context.pop();
              context.push('/admin');
            },
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text('Logout', style: TextStyle(color: Colors.redAccent)),
            onTap: () => _handleLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
