import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:studystack/blocs/subject_notes/subject_notes_bloc.dart';
import 'package:studystack/blocs/subject_notes/subject_notes_event.dart';
import 'package:studystack/blocs/subject_notes/subject_notes_state.dart';
import 'package:uuid/uuid.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/models/note.dart';
import 'package:studystack/widgets/custom_snackbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AddNoteDialog extends StatefulWidget {
  final String subjectId;
  final String subjectLabel;

  const AddNoteDialog({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _labelController = TextEditingController();
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar.error(
          message: 'Error picking file: $e',
        ),
      );
    }
  }

  String _getFileExtension(String filePath) {
    final parts = filePath.split('.');
    return parts.length > 1 ? parts.last.toLowerCase() : '';
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create subject directory if it doesn't exist
      final subjectDir = Directory('notes/${widget.subjectId}');
      if (!await subjectDir.exists()) {
        await subjectDir.create(recursive: true);
      }

      // Generate unique filename
      final extension = _getFileExtension(_selectedFile!.path);
      final uniqueFilename = '${const Uuid().v4()}.$extension';
      final targetPath = '${subjectDir.path}/$uniqueFilename';

      // Copy file to subject directory
      await _selectedFile!.copy(targetPath);

      // Create note object
      final note = Note(
        label: _labelController.text,
        filePath: targetPath,
        uploadedBy: 'Current User',
        uploadedAt: DateTime.now(),
      );
      context.read<SubjectsNotesBloc>().add(
            AddNote(note, widget.subjectId),
          );

      if (mounted) {
        Navigator.pop(context, note);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.error(
            message: 'Error saving note: $e',
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubjectsNotesBloc, SubjectsNotesState>(
      listener: (context, state) {
        if (state is NotesLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is NotesLoaded) {
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
        } else if (state is OperationError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            CustomSnackBar.error(
              message: state.error,
            ),
          );
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.add_circle_outline,
                        color: Colors.blue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Add Resource',
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.subjectLabel,
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
                TextFormField(
                  controller: _labelController,
                  decoration: InputDecoration(
                    labelText: 'Label',
                    hintText: 'Enter a descriptive label for this resource',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a label';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Center(
                  child: InkWell(
                    onTap: _pickFile,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _selectedFile != null
                                ? Icons.file_present
                                : Icons.upload_file,
                            size: 48,
                            color: _selectedFile != null
                                ? Colors.green
                                : Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile != null
                                ? _selectedFile!.path.split('/').last
                                : 'Select PDF File',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: _selectedFile != null
                                  ? Colors.grey[800]
                                  : Colors.grey[600],
                            ),
                          ),
                          if (_selectedFile == null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Only PDF files are allowed',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[900],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Text(
                                'Add Note',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
