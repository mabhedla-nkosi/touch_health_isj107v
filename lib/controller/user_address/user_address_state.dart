part of 'user_address_cubit.dart';


abstract class UserAddressSearchState extends Equatable {
  const UserAddressSearchState();

  @override
  List<Object> get props => [];
}

class UserAddressSearchInitial extends UserAddressSearchState {}

class UserAddressSearchLoading extends UserAddressSearchState {}

class UserAddressSearchSuccess extends UserAddressSearchState {
  final List<Map<String, dynamic>> UserAddress;

  const UserAddressSearchSuccess(this.UserAddress);

  @override
  List<Object> get props => [UserAddress];
}

class UserAddressSearchError extends UserAddressSearchState {
  final String message;

  const UserAddressSearchError(this.message);

  @override
  List<Object> get props => [message];
}

class UserAddressDetailsLoading extends UserAddressSearchState {}

class UserAddressDetailsSuccess extends UserAddressSearchState {
  final Map<String, dynamic> UserAddressRecord;

  const UserAddressDetailsSuccess(this.UserAddressRecord);

  @override
  List<Object> get props => [UserAddressRecord];
}