import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/blocs/authentication/auth_bloc.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/screens/profile/profile_screen.dart';
import 'package:studystack/widgets/custom_snackbar.dart';
import 'package:studystack/widgets/add_note_dialog.dart';
import 'package:uuid/uuid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Subject> _subjects = [];

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthenticationUnauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'StudyStack',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: _buildBody(),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationAuthenticated) {
          if (_selectedIndex == 0) {
            return _buildHomeScreen();
          } else {
            return const ProfileScreen();
          }
        }
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _buildHomeScreen() {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationAuthenticated) {
          final isCR = state.appUser.isCR;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Subjects',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _subjects.isEmpty && !isCR
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No Subjects Available',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Subjects will appear here once added by your Class Representative',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _subjects.length + (isCR ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (isCR && index == 0) {
                              return _buildAddNewSubjectCard(context);
                            }
                            final subjectIndex = isCR ? index - 1 : index;
                            return _buildSubjectCard(_subjects[subjectIndex]);
                          },
                        ),
                ),
              ],
            ),
          );
        }
        return const Center(
          child: Text('Please log in to view subjects'),
        );
      },
    );
  }

  Widget _buildSubjectCard(Subject subject) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          _showResources(context, subject);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                subject.color.withOpacity(0.8),
                subject.color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                subject.icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                subject.label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddNewSubjectCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _showAddSubjectDialog(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[400]!,
                Colors.grey[600]!,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 8),
              Text(
                'Add New Subject',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String label = '';
    String professor = '';
    int credit = 0;
    Color selectedColor = Colors.blue;
    IconData selectedIcon = Icons.book;
    bool isLoading = false;

    final state = context.read<AuthenticationBloc>().state;
    String branchCode = '';
    if (state is AuthenticationAuthenticated) {
      final user = state.appUser;
      if (user.branch != null && user.admissionYear != null) {
        final branchWords = user.branch!.split(' ');
        branchCode = branchWords.map((word) => word[0]).join('').toUpperCase();
        branchCode = '$branchCode${user.admissionYear}';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Add New Subject',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter subject name';
                      }
                      return null;
                    },
                    onSaved: (value) => label = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Professor Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter professor name';
                      }
                      return null;
                    },
                    onSaved: (value) => professor = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Credits',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter credits';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                    onSaved: (value) => credit = int.parse(value!),
                  ),
                  const SizedBox(height: 16),
                  // Color picker with gradients
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildColorOption(Colors.blue, Colors.blue.shade700),
                      _buildColorOption(Colors.red, Colors.red.shade700),
                      _buildColorOption(Colors.green, Colors.green.shade700),
                      _buildColorOption(Colors.orange, Colors.orange.shade700),
                      _buildColorOption(Colors.purple, Colors.purple.shade700),
                      _buildColorOption(Colors.teal, Colors.teal.shade700),
                      _buildColorOption(Colors.indigo, Colors.indigo.shade700),
                      _buildColorOption(Colors.pink, Colors.pink.shade700),
                      _buildColorOption(Colors.amber, Colors.amber.shade700),
                      _buildColorOption(Colors.cyan, Colors.cyan.shade700),
                      _buildColorOption(
                          Colors.deepPurple, Colors.deepPurple.shade700),
                      _buildColorOption(
                          Colors.lightBlue, Colors.lightBlue.shade700),
                    ].map((gradient) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedColor = gradient.first;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradient,
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedColor == gradient.first
                                  ? Colors.white
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Icon picker with more options
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Icons.book,
                      Icons.calculate,
                      Icons.science,
                      Icons.biotech,
                      Icons.engineering,
                      Icons.computer,
                      Icons.memory,
                      Icons.architecture,
                      Icons.psychology,
                      Icons.analytics,
                      Icons.data_object,
                      Icons.code,
                      Icons.terminal,
                      Icons.auto_graph,
                      Icons.timeline,
                      Icons.functions,
                      Icons.integration_instructions,
                      Icons.linear_scale,
                      Icons.pattern,
                      Icons.construction,
                      Icons.build,
                    ].map((IconData icon) {
                      return GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedIcon == icon
                                  ? Colors.blue
                                  : Colors.transparent,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        setDialogState(() {
                          isLoading = true;
                        });

                        try {
                          // Simulate API call
                          await Future.delayed(const Duration(seconds: 1));
                          final newSubject = Subject(
                            id: const Uuid().v4(),
                            label: label,
                            professor: professor,
                            credit: credit,
                            branchCode: branchCode,
                            color: selectedColor,
                            icon: selectedIcon,
                          );
                          // Update the parent widget's state
                          setState(() {
                            _subjects.add(newSubject);
                          });
                          Navigator.pop(context);
                          // Show success message with animation
                          ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackBar.success(
                              message: 'Subject "${label}" added successfully!',
                            ),
                          );
                        } catch (e) {
                          // Show error message with animation
                          ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackBar.error(
                              message:
                                  'Failed to add subject. Please try again.',
                            ),
                          );
                        } finally {
                          setDialogState(() {
                            isLoading = false;
                          });
                        }
                      }
                    },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Add Subject'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Color> _buildColorOption(Color primary, Color secondary) {
    return [primary, secondary];
  }

  void _showResources(BuildContext context, Subject subject) {
    final isCR = context.read<AuthenticationBloc>().state
            is AuthenticationAuthenticated &&
        (context.read<AuthenticationBloc>().state
                as AuthenticationAuthenticated)
            .appUser
            .isCR;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
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
                          color: subject.color.withOpacity(0.1),
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
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AddNoteDialog(
                                subjectId: subject.id,
                                subjectLabel: subject.label,
                              ),
                            ).then((note) {
                              if (note != null) {
                                setState(() {
                                  subject.notes.add(note);
                                });
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
          },
        );
      },
    );
  }
}
