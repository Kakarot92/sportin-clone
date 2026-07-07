/// Public trainer profile stored at `trainers/{uid}` — readable by any signed-in
/// user so clients can browse and choose a trainer. Separate from the private
/// `users/{uid}` document.
class TrainerProfile {
  const TrainerProfile({
    required this.uid,
    this.displayName = '',
    this.bio = '',
    this.photoUrl = '',
  });

  final String uid;
  final String displayName;
  final String bio;
  final String photoUrl;

  factory TrainerProfile.fromMap(String uid, Map<String, dynamic> map) {
    return TrainerProfile(
      uid: uid,
      displayName: (map['displayName'] as String?) ?? '',
      bio: (map['bio'] as String?) ?? '',
      photoUrl: (map['photoUrl'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'displayName': displayName,
        'bio': bio,
        'photoUrl': photoUrl,
      };

  TrainerProfile copyWith({String? displayName, String? bio, String? photoUrl}) {
    return TrainerProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
