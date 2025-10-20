part of 'conditions_cubit.dart';

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
  final Condition conditionsDataModel;

  AccountSuccess({required this.conditionsDataModel});
}

class AccountFailure extends AccountState {
  final String message;

  AccountFailure({required this.message});
}