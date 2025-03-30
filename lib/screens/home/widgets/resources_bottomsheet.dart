import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/blocs/authentication/auth_bloc.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/models/note.dart';
import 'package:studystack/widgets/add_note_dialog.dart';

class ResourcesBottomSheet extends StatelessWidget {
  final Subject subject;

  const ResourcesBottomSheet({
    super.key,
    required this.subject,
  });

  @override
  Widget build(BuildContext context) {
    final isCR = context.read<AuthenticationBloc>().state
            is AuthenticationAuthenticated &&
        (context.read<AuthenticationBloc>().state
                as AuthenticationAuthenticated)
            .appUser
            .isCR;

    return DraggableScrollableSheet(
      initialChildSize: 0.95,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: subject.color.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      subject.icon,
                      color: subject.color,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject.label,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Professor: ${subject.professor}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        Text(
                          'Credits: ${subject.credit}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Resources',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (isCR)
                    TextButton.icon(
                      onPressed: () => _addNewResource(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Resource'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: subject.notes.isEmpty
                    ? _buildEmptyState(isCR)
                    : _buildResourcesList(scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isCR) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Resources Available',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isCR
                ? 'Add resources to help your classmates'
                : 'Resources will be added by your Class Representative',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResourcesList(ScrollController scrollController) {
    return ListView.builder(
      controller: scrollController,
      itemCount: subject.notes.length,
      itemBuilder: (context, index) {
        final note = subject.notes[index];
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.only(bottom: 8),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: subject.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.link,
                  color: subject.color,
                  size: 24,
                ),
              ),
              title: Text(
                note.label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                'Added by ${note.uploadedBy}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.download),
                onPressed: () => _downloadResource(note),
              ),
              onTap: () => _openResource(note),
            ),
          ),
        );
      },
    );
  }

  void _addNewResource(BuildContext context) async {
    final note = await showDialog<Note>(
      context: context,
      builder: (context) => AddNoteDialog(
        subjectId: subject.id,
        subjectLabel: subject.label,
      ),
    );
  }

  void _downloadResource(Note note) {
    // Implement download functionality
  }

  void _openResource(Note note) {
    // Implement resource opening functionality
  }
}
