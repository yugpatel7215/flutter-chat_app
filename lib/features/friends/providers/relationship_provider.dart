import 'package:chat_app/features/friends/controllers/relationship_controller.dart';
import 'package:chat_app/features/friends/data/models/relationship_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final relationshipControllerProvider =
    AsyncNotifierProvider<RelationshipController, void>(
      () => RelationshipController(),
    );

final getRelationship = StreamProvider.family<RelationshipModel?, String>((
  ref,
  otherUserId,
) {
  final controller = ref.watch(relationshipControllerProvider.notifier);

  return controller.getRelationship(otherUserId);
});

final getIncomingRequests = StreamProvider((ref) {
  final controller = ref.watch(relationshipControllerProvider.notifier);

  return controller.getIncomingRequests();
});

final getOutgoingRequests = StreamProvider((ref) {
  final controller = ref.watch(relationshipControllerProvider.notifier);

  return controller.getOutgoingRequests();
});

final getFriends = StreamProvider((ref) {
  final controller = ref.watch(relationshipControllerProvider.notifier);

  return controller.getFriends();
});
