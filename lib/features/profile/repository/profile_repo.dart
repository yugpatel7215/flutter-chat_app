import 'package:chat_app/features/auth/data/models/user_model.dart';

abstract class ProfileRepository {
  Stream<UserModel> getMyProfileData(String uid);
}
