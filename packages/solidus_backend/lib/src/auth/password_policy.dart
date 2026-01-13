class PasswordPolicy {
  PasswordPolicy({required this.minLength});

  final int minLength;

  String? validate(String password) {
    if (password.length < minLength) {
      return 'password must be at least $minLength characters';
    }
    return null;
  }
}

