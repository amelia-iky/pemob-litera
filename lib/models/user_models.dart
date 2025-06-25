class UserProfile {
  final String id;
  final String name;
  final String username;
  final String email;
  final List<ProfileImage> profileImages;

  UserProfile({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.profileImages,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      username: json['username'],
      email: json['email'],
      profileImages: (json['profileImages'] as List<dynamic>)
          .map((img) => ProfileImage.fromJson(img))
          .toList(),
    );
  }
}

class ProfileImage {
  final String url;

  ProfileImage({required this.url});

  factory ProfileImage.fromJson(Map<String, dynamic> json) {
    return ProfileImage(url: json['url']);
  }
}
