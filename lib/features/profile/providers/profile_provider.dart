import 'package:chat_app/features/auth/data/models/user_model.dart';
import 'package:chat_app/features/profile/controllers/profile_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileControllerProvider =
    AsyncNotifierProvider<ProfileController, void>(() => ProfileController());

final getProfileData = StreamProvider.family<UserModel, String>((ref, uid) {
  final controller = ref.watch(profileControllerProvider.notifier);

  return controller.getMyProfileData(uid);
});
