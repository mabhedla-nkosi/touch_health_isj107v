
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touchhealth/core/cache/cache.dart';
import 'package:touchhealth/core/service/new_patient_data_service.dart';
import 'package:touchhealth/data/model/medical_aid_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';
import 'dart:developer' as dev;
import 'package:equatable/equatable.dart';
import 'package:touchhealth/data/model/user_address_model.dart';

part 'user_address_state.dart';

class UserAddressCubit extends Cubit<UserAddressSearchState> {
  UserAddressCubit() : super(UserAddressSearchInitial());

  static final PatientDataService dataService = PatientDataService();

  Future<void> searchUserAddressByUserId(int userId) async {
    if (userId==0) {      
      return;
    }

    try {
      dev.log('Searching medical aid details by id: $userId');      
      List<UserAddressDataModel> actualData =await dataService.getUserAddressByUserId(userId);
      Map<String, dynamic> userAddressMap= {};

        for (var address in actualData) {
            userAddressMap = address.toJson();
            await CacheData.setMapData(
                key: "userAddressData",
                value: {'userAddressData': userAddressMap}, // wrap in a map if needed
              );
            
        }
      return;

    } catch (e) {
      dev.log('Error finding patient: $e');
      return null;
    }
  }


}
