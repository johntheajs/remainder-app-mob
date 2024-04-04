class User {
  int? id; // Make id nullable

  final String username;
  final String password;

  User({
    this.id, // Make id optional
    required this.username,
    required this.password,
  });

  // Add a method to convert User object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id, // Include id in the map
      'username': username,
      'password': password,
    };
  }
}
