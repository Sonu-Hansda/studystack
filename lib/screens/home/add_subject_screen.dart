import 'package:flutter/material.dart';

class AddSubjectScreen extends StatefulWidget {
  const AddSubjectScreen({super.key});

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final TextEditingController _labelController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  String? _selectedImageUrl;
  String? _selectedBranch;

  final List<String> _branches = [
    'Computer Science',
    'Mechanical Engineering',
    'Electrical Engineering',
    'Civil Engineering',
    'Electronics and Communication',
    'Other',
  ];

  void _openImageSearch() async {
    final String? imageUrl = await Navigator.pushNamed(
      context,
      '/image-search',
    ) as String?;

    if (imageUrl != null) {
      setState(() {
        _selectedImageUrl = imageUrl;
      });
    }
  }

  void _saveSubject() {
    if (_labelController.text.isEmpty ||
        _professorController.text.isEmpty ||
        _creditController.text.isEmpty ||
        _selectedImageUrl == null ||
        _selectedBranch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    // Save subject logic here
    final subject = {
      'label': _labelController.text,
      'imageUrl': _selectedImageUrl!,
      'professor': _professorController.text,
      'credit': int.parse(_creditController.text),
      'branch': _selectedBranch!,
    };

    Navigator.pop(context, subject);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Subject'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16.0),
              InkWell(
                onTap: _openImageSearch,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: _selectedImageUrl == null
                      ? const Center(child: Text('Tap to select an image'))
                      : Image.network(
                          _selectedImageUrl!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Subject Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _professorController,
                decoration: const InputDecoration(
                  labelText: 'Professor',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _creditController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Credits',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: _selectedBranch,
                items: _branches.map((branch) {
                  return DropdownMenuItem<String>(
                    value: branch,
                    child: Text(branch),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranch = value;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Select Branch',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _saveSubject,
                child: const Text('Save Subject'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
