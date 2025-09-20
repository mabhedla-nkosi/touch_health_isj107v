import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touchhealth/core/cache/cache.dart';
import 'package:touchhealth/data/model/medical_aid_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meta/meta.dart';

part 'medical_aid_state.dart';

class MedicalAidCubit extends Cubit<AccountState> {
  MedicalAidCubit() : super(AccountInitial());
  final _firestore = FirebaseFirestore.instance;

  Future<void> getMedicalAidData() async {
    emit(AccountLoading());
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      // Check if user is authenticated
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        // Create demo user data for unauthenticated users
        final demoUserData = MedicalAidDataModel(
          //name: 'Demo',
          userId: 'demo_user',
          medicalaidname: 'User',
          medicaliadid: 'password123',
          medicalaidnumber: 'ID123456',
        );

        //await CacheData.setData(key: "medicalaidname", value: demoUserData.medicalaidname);
        await CacheData.setMapData(key: "medicalAidData", value: demoUserData.toJson());
        emit(AccountSuccess(medicalAidDataModel: demoUserData));
        return;
      }
      
      MedicalAidDataModel? medicalAidDataModel;
      final doc = await _firestore
          .collection('medicalaid')
          .doc(currentUser.uid)
          .get();

          print("Medical Aid Doc: $doc");

      // _firestore
      //     .collection('medicalaid')
      //     .doc(currentUser.uid)
      //     .snapshots()
      //     .listen((event) {
      //   if (event.exists && event.data() != null) {
      //     medicalAidDataModel = MedicalAidDataModel.fromJson(event.data()!);
      //     //CacheData.setData(key: "name", value: medicalAidDataModel!.name);
      //     CacheData.setMapData(key: "medicalAidData", value: medicalAidDataModel!.toJson());
      //     emit(AccountSuccess(medicalAidDataModel: medicalAidDataModel!));
      //   }
      //    else {
      //     // Create fallback user data if document doesn't exist
      //     final fallbackUserData = MedicalAidDataModel(
      //       //name: currentUser.displayName ?? 'User',
      //       userId: currentUser.uid,
      //       medicalaidname: '',
      //       medicalaidnumber: '',
      //       medicaliadid: '',
      //     );
      //     //CacheData.setData(key: "name", value: fallbackUserData.name);
      //     CacheData.setMapData(key: "medicalAidData", value: fallbackUserData.toJson());
      //     emit(AccountSuccess(medicalAidDataModel: fallbackUserData));
      //   }
      // });
      if (doc.exists && doc.data() != null) {
          medicalAidDataModel = MedicalAidDataModel.fromJson(doc.data()!);

          await CacheData.setMapData(
            key: "medicalAidData",
            value: medicalAidDataModel.toJson(),
          );

          emit(AccountSuccess(medicalAidDataModel: medicalAidDataModel));
        } else {
          // Create fallback user data if document doesn't exist
          final fallbackUserData = MedicalAidDataModel(
            userId: currentUser.uid,
            medicalaidname: '',
            medicalaidnumber: '',
            medicaliadid: '',
          );

          await CacheData.setMapData(
            key: "medicalAidData",
            value: fallbackUserData.toJson(),
          );

          emit(AccountSuccess(medicalAidDataModel: fallbackUserData));
        }
    } on FirebaseException catch (err) {
      emit(AccountFailure(message: err.toString()));
    } catch (err) {
      emit(AccountFailure(message: err.toString()));
    }
  }

 

  Future<void> updateMedicalAid({
    String? medicalaidname,
    String? medicalaidnumber,
    String? userId,
    String? medicaliadid,
  }) async {
    emit(ProfileUpdateLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 400));
      // await _firestore
      //     .collection('medicalaid')
      //     .doc(FirebaseAuth.instance.currentUser!.uid)
      //     .update({
      //       'medicalaidname': medicalaidname,
      //       'userId': FirebaseAuth.instance.currentUser!.uid,
      //       'medicalaidnumber': medicalaidnumber,
      //       'medicaliadid': medicaliadid,
      //     })
      //     .whenComplete(() => emit(ProfileUpdateSuccess()))
      //     .timeout(const Duration(seconds: 5),
      //         onTimeout: () => emit(ProfileUpdateFailure(
      //             message: "There was an error, please try again")));

      await _firestore
        .collection('medicalaid')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
          'medicalaidname': medicalaidname,
          'userId': FirebaseAuth.instance.currentUser!.uid,
          'medicalaidnumber': medicalaidnumber,
          'medicaliadid': medicaliadid,
        }, SetOptions(merge: true)) // <--- important
        .whenComplete(() => emit(ProfileUpdateSuccess()))
        .timeout(
          const Duration(seconds: 5),
          onTimeout: () => emit(ProfileUpdateFailure(
            message: "There was an error, please try again",
          )),
        );
    } on FirebaseException catch (err) {
      emit(ProfileUpdateFailure(message: err.toString()));
    }
  }


}
