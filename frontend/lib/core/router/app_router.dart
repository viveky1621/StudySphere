import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/welcome/screens/welcome_screen.dart';

import '../../features/pdf/screens/pdf_dashboard_screen.dart';
import '../../features/chat/screens/chat_screen.dart';
import '../../features/discover/screens/discover_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/admin_upload_screen.dart';
import '../../features/study_tools/screens/study_tools_screen.dart';
import '../../features/pdf/screens/pdf_viewer_screen.dart';
import '../../features/puc/screens/puc_screen.dart';
import '../../features/engineering/screens/engineering_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const PdfDashboardScreen(),
      ),
      GoRoute(
        path: '/chat',
        name: 'chat',
        builder: (context, state) {
          final pdfId = state.uri.queryParameters['pdfId'];
          final pdfTitle = state.uri.queryParameters['title'] ?? 'AI Tutor';
          return ChatScreen(pdfId: pdfId, pdfTitle: pdfTitle);
        },
      ),
      GoRoute(
        path: '/study-tools',
        name: 'study-tools',
        builder: (context, state) => const StudyToolsScreen(),
      ),
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/upload',
        name: 'admin_upload',
        builder: (context, state) => const AdminUploadScreen(),
      ),
      GoRoute(
        path: '/discover',
        name: 'discover',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/pdf_viewer',
        name: 'pdf_viewer',
        builder: (context, state) {
          final pdfUrl = state.uri.queryParameters['pdfUrl'] ?? '';
          final title = state.uri.queryParameters['title'] ?? 'PDF Document';
          return PdfViewerScreen(pdfUrl: pdfUrl, title: title);
        },
      ),
      GoRoute(
        path: '/puc',
        name: 'puc',
        builder: (context, state) => const PucScreen(),
      ),
      GoRoute(
        path: '/engineering',
        name: 'engineering',
        builder: (context, state) => const EngineeringScreen(),
      ),
    ],
  );
});
