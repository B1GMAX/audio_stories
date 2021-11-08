import 'dart:io';

class UserInformation {
  String? userPhoto;
  String? userName;
  String? userNumber;

  @override
  String toString() {
    return 'UserInformation{userName: $userName}';
  }

  UserInformation({
    required this.userName,
    required this.userNumber,
    required this.userPhoto,
  });

  factory UserInformation.fromJson(Map<String, dynamic> json) {
    return UserInformation(
      userNumber: json['userNumber'],
      userPhoto: json['userPhoto'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() => {
        'userNumber': userNumber,
        'userPhoto': userPhoto,
        'userName': userName,
      };
}
