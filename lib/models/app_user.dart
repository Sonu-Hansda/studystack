class AppUser {
  final String fullName;
  final String email;
  String? uid;
  String? firstName;
  String? lastName;
  String? branch;
  int? admissionYear;
  int? graduationYear;
  String? college;
  String? gender;
  DateTime? dateOfBirth;
  bool isCR;

  AppUser({
    required this.fullName,
    required this.email,
    this.uid,
    this.firstName,
    this.lastName,
    this.branch,
    this.admissionYear,
    this.graduationYear,
    this.college,
    this.gender,
    this.dateOfBirth,
    this.isCR = false,
  }) {
    _extractDetailsFromEmail();
    _splitName();
  }

  void _extractDetailsFromEmail() {
    try {
      final parts = email.split('@');
      if (parts.length > 1 && parts[1] == 'nitjsr.ac.in') {
        college = 'National Institute of Technology, Jamshedpur';

        final prefix = parts[0];
        final yearCode = int.tryParse(prefix.substring(0, 4));
        if (yearCode != null) {
          admissionYear = yearCode;
          graduationYear = yearCode + 4;
        }

        final branchCode = prefix.substring(6, 8).toLowerCase();
        branch = _getBranchName(branchCode);
      }
    } catch (e) {
      college = null;
      admissionYear = null;
      graduationYear = null;
      branch = null;
    }
  }

  void _splitName() {
    final nameParts = fullName.split(' ');
    if (nameParts.length > 1) {
      firstName = nameParts.first;
      lastName = nameParts.sublist(1).join(' ');
    } else {
      firstName = fullName;
      lastName = null;
    }
  }

  String? _getBranchName(String branchCode) {
    const branchMapping = {
      'cm': 'Engineering and Computational Mechanics',
      'cs': 'Computer Science and Engineering',
      'me': 'Mechanical Engineering',
      'ee': 'Electrical Engineering',
      'ec': 'Electronics and Communication Engineering',
      'mm': 'Materials and Metallurgical Engineering',
      'pi': 'Production and Industrial Engineering',
      'ce': 'Civil Engineering',
    };
    return branchMapping[branchCode];
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'uid': uid,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'branch': branch,
      'admissionYear': admissionYear,
      'graduationYear': graduationYear,
      'college': college,
      'gender': gender,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'isCR': isCR,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      fullName: map['fullName'],
      email: map['email'],
      uid: map['uid'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      branch: map['branch'],
      admissionYear: map['admissionYear'],
      graduationYear: map['graduationYear'],
      college: map['college'],
      gender: map['gender'],
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'])
          : null,
      isCR: map['isCR'] ?? false,
    );
  }
}
