import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/blocs/authentication/auth_bloc.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/screens/home/widgets/add_new_subject_card.dart';
import 'package:studystack/screens/home/widgets/add_subject_dialog.dart';
import 'package:studystack/screens/home/widgets/resources_bottomsheet.dart';
import 'package:studystack/screens/home/widgets/subject_card.dart';

import 'package:studystack/screens/profile/profile_screen.dart';

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
                              return buildAddNewSubjectCard(
                                  context: context,
                                  onTap: () => _showAddSubjectDialog(context));
                            }
                            final subjectIndex = isCR ? index - 1 : index;
                            return buildSubjectCard(
                              context: context,
                              subject: _subjects[subjectIndex],
                              onTap: (context, subject) {
                                showModalBottomSheet(
                                  context: context,
                                  builder: (context) =>
                                      ResourcesBottomSheet(subject: subject),
                                );
                              },
                            );
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

  void _showAddSubjectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AddSubjectDialog(
        onSubjectAdded: (newSubject) {
          setState(() {
            _subjects.add(newSubject);
          });
        },
      ),
    );
  }
}
