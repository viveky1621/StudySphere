import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PucScreen extends StatefulWidget {
  const PucScreen({super.key});

  @override
  State<PucScreen> createState() => _PucScreenState();
}

class _PucScreenState extends State<PucScreen> {
  String? selectedPuc;
  String? selectedSemester;

  final Map<String, Map<String, List<String>>> pucData = {
    'PUC 1': {
      'Semester 1': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Telugu', 'Information Technology', 'Chemistry Lab', 'Physics Lab', 'Information Technology Lab'],
      'Semester 2': ['Mathematics', 'Physics', 'Chemistry', 'Elementary Biology', 'Biology', 'English', 'Telugu', 'Information Technology', 'Chemistry Lab', 'Physics Lab', 'Information Technology Lab'],
    },
    'PUC 2': {
      'Semester 1': ['Mathematics', 'Physics', 'Chemistry', 'Elementary Biology', 'Biology', 'English', 'Telugu', 'Information Technology', 'Chemistry Lab', 'Physics Lab', 'Information Technology Lab'],
      'Semester 2': ['Mathematics', 'Physics', 'Chemistry', 'Biology', 'English', 'Telugu', 'Information Technology', 'Chemistry Lab', 'Physics Lab', 'Information Technology Lab'],
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PUC Content', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.background,
            ],
          ),
        ),
        child: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (selectedPuc == null) {
      return _buildPucSelection();
    } else if (selectedSemester == null) {
      return _buildSemesterSelection();
    } else {
      return _buildSubjectsList();
    }
  }

  Widget _buildPucSelection() {
    final pucs = pucData.keys.toList();
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pucs.length,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school, color: Colors.orange),
            ),
            title: Text(pucs[index], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
            onTap: () {
              setState(() {
                selectedPuc = pucs[index];
              });
            },
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(begin: 0.1, end: 0);
      },
    );
  }

  Widget _buildSemesterSelection() {
    final semesters = pucData[selectedPuc!]!.keys.toList();
    return Column(
      children: [
        _buildHeader(selectedPuc!, () => setState(() => selectedPuc = null)),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.2,
            ),
            itemCount: semesters.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedSemester = semesters[index];
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.withOpacity(0.2),
                        Colors.orange.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_month, size: 36, color: Colors.orange),
                      const SizedBox(height: 12),
                      Text(semesters[index], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ).animate().scale(delay: Duration(milliseconds: 50 * index));
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsList() {
    final subjects = pucData[selectedPuc!]![selectedSemester!]!;
    return Column(
      children: [
        _buildHeader('$selectedPuc - $selectedSemester', () => setState(() => selectedSemester = null)),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.menu_book, color: Theme.of(context).colorScheme.primary),
                  ),
                  title: Text(subject, style: const TextStyle(fontSize: 18)),
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white70),
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Loading $subject...')));
                  },
                ).animate().fadeIn().slideX(begin: 0.1, end: 0),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String title, VoidCallback onBack) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }
}
