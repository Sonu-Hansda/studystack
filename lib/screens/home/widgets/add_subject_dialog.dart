import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studystack/blocs/authentication/auth_bloc.dart';
import 'package:studystack/blocs/authentication/auth_state.dart';
import 'package:studystack/models/subject.dart';
import 'package:studystack/widgets/custom_snackbar.dart';
import 'package:uuid/uuid.dart';

class AddSubjectDialog extends StatefulWidget {
  final Function(Subject) onSubjectAdded;

  const AddSubjectDialog({
    super.key,
    required this.onSubjectAdded,
  });

  @override
  State<AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends State<AddSubjectDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _label, _professor;
  late int _credit;
  late Color _selectedColor;
  late IconData _selectedIcon;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedColor = Colors.blue;
    _selectedIcon = Icons.book;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add New Subject',
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSubjectNameField(),
              const SizedBox(height: 16),
              _buildProfessorField(),
              const SizedBox(height: 16),
              _buildCreditField(),
              const SizedBox(height: 16),
              _buildColorPicker(),
              const SizedBox(height: 16),
              _buildIconPicker(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _handleSubmit,
          child: _buildSubmitButtonChild(),
        ),
      ],
    );
  }

  Widget _buildSubjectNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Subject Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter subject name' : null,
      onSaved: (value) => _label = value!,
    );
  }

  Widget _buildProfessorField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Professor Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) =>
          value?.isEmpty ?? true ? 'Please enter professor name' : null,
      onSaved: (value) => _professor = value!,
    );
  }

  Widget _buildCreditField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Credits',
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value?.isEmpty ?? true) return 'Please enter credits';
        if (int.tryParse(value!) == null) return 'Please enter a valid number';
        return null;
      },
      onSaved: (value) => _credit = int.parse(value!),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Color:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildColorOptions(),
        ),
      ],
    );
  }

  List<Widget> _buildColorOptions() {
    final colors = [
      [Colors.blue, Colors.blue.shade700],
      [Colors.red, Colors.red.shade700],
      [Colors.green, Colors.green.shade700],
      [Colors.orange, Colors.orange.shade700],
      [Colors.purple, Colors.purple.shade700],
      [Colors.teal, Colors.teal.shade700],
      [Colors.indigo, Colors.indigo.shade700],
      [Colors.pink, Colors.pink.shade700],
      [Colors.amber, Colors.amber.shade700],
      [Colors.cyan, Colors.cyan.shade700],
      [Colors.deepPurple, Colors.deepPurple.shade700],
      [Colors.lightBlue, Colors.lightBlue.shade700],
    ];

    return colors.map((gradient) {
      return GestureDetector(
        onTap: () => setState(() => _selectedColor = gradient.first),
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
              color: _selectedColor == gradient.first
                  ? Colors.white
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildIconPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Icon:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _buildIconOptions(),
        ),
      ],
    );
  }

  List<Widget> _buildIconOptions() {
    final icons = [
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
    ];

    return icons.map((icon) {
      return GestureDetector(
        onTap: () => setState(() => _selectedIcon = icon),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: _selectedIcon == icon ? Colors.blue : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon),
        ),
      );
    }).toList();
  }

  Widget _buildSubmitButtonChild() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Add Subject'),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _isLoading = true);

      try {
        final branchCode = _getBranchCode();
        final newSubject = Subject(
          id: const Uuid().v4(),
          label: _label,
          professor: _professor,
          credit: _credit,
          branchCode: branchCode,
          color: _selectedColor,
          icon: _selectedIcon,
        );

        widget.onSubjectAdded(newSubject);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.success(
            message: 'Subject "$_label" added successfully!',
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackBar.error(
            message: 'Failed to add subject. Please try again.',
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getBranchCode() {
    final state = context.read<AuthenticationBloc>().state;
    if (state is AuthenticationAuthenticated) {
      final user = state.appUser;
      if (user.branch != null && user.admissionYear != null) {
        final branchWords = user.branch!.split(' ');
        var code = branchWords.map((word) => word[0]).join('').toUpperCase();
        return '$code${user.admissionYear}';
      }
    }
    return '';
  }
}
