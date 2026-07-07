import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/trainer_profile.dart';
import '../../auth/application/auth_providers.dart';
import '../data/trainers_repository.dart';

final trainersRepositoryProvider = Provider<TrainersRepository>((ref) {
  return TrainersRepository(ref.watch(firestoreProvider));
});

final trainersListProvider = StreamProvider<List<TrainerProfile>>((ref) {
  return ref.watch(trainersRepositoryProvider).watchTrainers();
});

final trainerProvider =
    StreamProvider.family<TrainerProfile?, String>((ref, uid) {
  return ref.watch(trainersRepositoryProvider).watchTrainer(uid);
});
