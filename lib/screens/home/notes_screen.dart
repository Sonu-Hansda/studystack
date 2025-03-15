import 'package:flutter/material.dart';

class NotesScreen extends StatelessWidget {
  final String subject;

  const NotesScreen({required this.subject, super.key});

  @override
  Widget build(BuildContext context) {
    final notes = notesBySubject[subject] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('$subject Notes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: Text(note),
              onTap: () {
                // Handle opening PDF file
              },
            ),
          );
        },
      ),
    );
  }
}

List<Map<String, String>> subjects = [
  {
    'label': 'Add New',
  },
  {
    'label': 'Bio Mechanics',
    'image':
        'https://plus.unsplash.com/premium_photo-1677269465314-d5d2247a0b0c?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
  {
    'label': 'Thermodynamics',
    'image':
        'https://images.unsplash.com/photo-1593642634443-44adaa06623a?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
  {
    'label': 'Fluid Mechanics',
    'image':
        'https://images.unsplash.com/photo-1604936405863-05dd547b78a1?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
  },
];

const notesBySubject = {
  'Bio Mechanics': [
    'Kinematics and Dynamics.pdf',
    'Musculoskeletal System.pdf',
    'Human Gait Analysis.pdf',
  ],
  'Thermodynamics': [
    'First Law of Thermodynamics.pdf',
    'Entropy and Disorder.pdf',
    'Thermodynamic Cycles.pdf',
  ],
  'Fluid Mechanics': [
    'Flow Dynamics.pdf',
    'Hydraulic Machines.pdf',
    'Boundary Layers.pdf',
  ],
};
