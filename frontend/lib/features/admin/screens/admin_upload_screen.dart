import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../pdf/services/pdf_service.dart';

class AdminUploadScreen extends ConsumerStatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  ConsumerState<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends ConsumerState<AdminUploadScreen> {
  String? selectedCategory;
  String? selectedPucLevel;
  String? selectedBranch;
  String? selectedSemester;
  String? selectedSubject;
  String? pdfPath;
  String? pdfName;

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

  final List<String> engineeringBranches = [
    'Chemical Engineering',
    'Civil Engineering',
    'Computer Science',
    'Electrical Engineering',
    'Electronics Engineering',
    'Mechanical Engineering',
    'Metallurgical Engineering'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload PDF')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.attach_file),
              label: Text(pdfName ?? 'Select PDF File'),
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                if (result != null) {
                  setState(() {
                    pdfPath = result.files.single.path;
                    pdfName = result.files.single.name;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              value: selectedCategory,
              items: const [
                DropdownMenuItem(value: 'PUC', child: Text('PUC')),
                DropdownMenuItem(value: 'Engineering', child: Text('Engineering')),
              ],
              onChanged: (val) => setState(() {
                selectedCategory = val;
                selectedPucLevel = null;
                selectedBranch = null;
                selectedSemester = null;
                selectedSubject = null;
              }),
            ),
            const SizedBox(height: 16),

            // PUC SPECIFIC FIELDS
            if (selectedCategory == 'PUC') ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'PUC Level', border: OutlineInputBorder()),
                value: selectedPucLevel,
                items: pucData.keys.map((puc) => DropdownMenuItem(value: puc, child: Text(puc))).toList(),
                onChanged: (val) => setState(() {
                  selectedPucLevel = val;
                  selectedSemester = null;
                  selectedSubject = null;
                }),
              ),
              const SizedBox(height: 16),
              if (selectedPucLevel != null) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Semester', border: OutlineInputBorder()),
                  value: selectedSemester,
                  items: pucData[selectedPucLevel!]!.keys.map((sem) => DropdownMenuItem(value: sem, child: Text(sem))).toList(),
                  onChanged: (val) => setState(() {
                    selectedSemester = val;
                    selectedSubject = null;
                  }),
                ),
                const SizedBox(height: 16),
              ],
              if (selectedPucLevel != null && selectedSemester != null) ...[
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
                  value: selectedSubject,
                  items: pucData[selectedPucLevel!]![selectedSemester!]!.map((sub) => DropdownMenuItem(value: sub, child: Text(sub))).toList(),
                  onChanged: (val) => setState(() => selectedSubject = val),
                ),
                const SizedBox(height: 16),
              ],
            ],

            // ENGINEERING SPECIFIC FIELDS
            if (selectedCategory == 'Engineering') ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Branch', border: OutlineInputBorder()),
                value: selectedBranch,
                items: engineeringBranches.map((b) => DropdownMenuItem(value: b, child: Text(b))).toList(),
                onChanged: (val) => setState(() => selectedBranch = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Semester', border: OutlineInputBorder()),
                value: selectedSemester,
                items: List.generate(8, (i) => DropdownMenuItem(value: 'Semester ${i + 1}', child: Text('Semester ${i + 1}'))),
                onChanged: (val) => setState(() => selectedSemester = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Subject Name', border: OutlineInputBorder()),
                initialValue: selectedSubject,
                onChanged: (val) => selectedSubject = val,
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _upload,
              child: const Text('Upload to Hub'),
            ),
          ],
        ),
      ),
    );
  }

  void _upload() async {
    if (pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a PDF first')));
      return;
    }
    if (selectedCategory == null || selectedSemester == null || selectedSubject == null || selectedSubject!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploading...')));
      await ref.read(pdfServiceProvider).uploadPdf(pdfPath!, pdfName!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload successful!')));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }
}
