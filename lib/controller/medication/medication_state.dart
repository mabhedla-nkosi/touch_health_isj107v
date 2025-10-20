part of 'medication_cubit.dart';

@immutable
abstract class AccountState {}

class AccountInitial extends AccountState {}

//? Update profile
class ProfileUpdateLoading extends AccountState {}

class ProfileUpdateSuccess extends AccountState {}

class ProfileUpdateFailure extends AccountState {
  final String message;

  ProfileUpdateFailure({required this.message});
}

//? user data
class AccountLoading extends AccountState {}

class AccountSuccess extends AccountState {
  final Medication medicationDataModel;

  AccountSuccess({required this.medicationDataModel});
}

class AccountFailure extends AccountState {
  final String message;

  AccountFailure({required this.message});
}