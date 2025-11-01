part of 'medical_aid_cubit.dart';

@immutable
abstract class AccountState {}


// class AccountInitial extends AccountState {}

// //? Update profile
class ProfileUpdateLoading extends AccountState {}

class ProfileUpdateSuccess extends AccountState {}

class ProfileUpdateFailure extends AccountState {
  final String message;

  ProfileUpdateFailure({required this.message});
}

// //? user data
// class AccountLoading extends AccountState {}

// class AccountSuccess extends AccountState {
//   final MedicalAidDataModel medicalAidDataModel;

//   AccountSuccess({required this.medicalAidDataModel});
  
// }


// class AccountFailure extends AccountState {
//   final String message;

//   AccountFailure({required this.message});
// }

abstract class MedicalAidSearchState extends Equatable {
  const MedicalAidSearchState();

  @override
  List<Object> get props => [];
}

class MedicalAidSearchInitial extends MedicalAidSearchState {}

class MedicalAidSearchLoading extends MedicalAidSearchState {}

class MedicalAidSearchSuccess extends MedicalAidSearchState {
  final List<Map<String, dynamic>> MedicalAids;

  const MedicalAidSearchSuccess(this.MedicalAids);

  @override
  List<Object> get props => [MedicalAids];
}

class MedicalAidSearchError extends MedicalAidSearchState {
  final String message;

  const MedicalAidSearchError(this.message);

  @override
  List<Object> get props => [message];
}

class MedicalAidDetailsLoading extends MedicalAidSearchState {}

class MedicalAidDetailsSuccess extends MedicalAidSearchState {
  final Map<String, dynamic> MedicalAidRecord;

  const MedicalAidDetailsSuccess(this.MedicalAidRecord);

  @override
  List<Object> get props => [MedicalAidRecord];
}