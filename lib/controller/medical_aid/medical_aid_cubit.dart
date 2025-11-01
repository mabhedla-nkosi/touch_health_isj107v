
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

part 'medical_aid_state.dart';

class MedicalAidCubit extends Cubit<MedicalAidSearchState> {
  //MedicalAidCubit() : super(AccountInitial());
  MedicalAidCubit() : super(MedicalAidSearchInitial());
  final _firestore = FirebaseFirestore.instance;

  static final PatientDataService dataService = PatientDataService();

  Future<void> searchMedicalAidByUserId(int medicalAidId) async {
    if (medicalAidId==0) {      
      return;
    }

    try {
      dev.log('Searching medical aid details by id: $medicalAidId');      
      List<MedicalAidDataModel> actualData =await dataService.getMedicalAidByUserId(medicalAidId);
      Map<String, dynamic> medicalAidMap= {};

        for (var medical in actualData) {
            medicalAidMap = medical.toJson();
            await CacheData.setMapData(
                key: "medicalAidData",
                value: {'medicalAidData': medical}, // wrap in a map if needed
              );
            
        }
      return;

    } catch (e) {
      dev.log('Error finding patient: $e');
      return null;
    }
  }

  Future<void> updateMedicalAid({
    required String medicalAidName,
    required String medicalAidNumber,
    required int userId,
    required int medicalAidId,
  }) async {
    emit(MedicalAidDetailsLoading());

    try {
      await Future.delayed(const Duration(milliseconds: 300));

      await dataService.updateMedicalAid(
        medicalAidName: medicalAidName,
        medicalAidNumber: medicalAidNumber,
        userId: userId,
        medicalAidId: medicalAidId,
      );

      await CacheData.setMapData(
        key: "medicalAidData",
        value: {
          "medicalAidData": {
            "medicalaidname": medicalAidName,
            "medicalnumber": medicalAidNumber,
            "userid": userId,
            "medicalaidid": medicalAidId,
          },
        },
      );


      emit(MedicalAidDetailsSuccess({
          "medicalaidname": medicalAidName,
          "medicalnumber": medicalAidNumber,
          "userid": userId,
          "medicalaidid": medicalAidId,
        }));
        
    } catch (e) {
      emit(MedicalAidSearchError(e.toString()));
    }
  }

}
