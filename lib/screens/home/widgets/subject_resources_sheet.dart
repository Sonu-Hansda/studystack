import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/widgets/add_note_dialog.dart';

class SubjectResourcesSheet extends StatelessWidget {
  final Subject subject;
  final bool isCR;
  final ScrollController scrollController;

  const SubjectResourcesSheet({
    super.key,
    required this.subject,
    required this.isCR,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AddNoteDialog(
                        subjectId: subject.id,
                        subjectLabel: subject.label,
                      ),
                    ).then((note) {
                      if (note != null) {
                        // TODO: Update subject's notes list
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Resource'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: subject.notes.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
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
                                color: subject.color.withOpacity(0.1),
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
                              onPressed: () {
                                // TODO: Implement download functionality
                              },
                            ),
                            onTap: () {
                              // TODO: Implement resource link opening
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
