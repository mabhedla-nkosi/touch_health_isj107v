import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:touchhealth/core/utils/helper/scaffold_snakbar.dart';
import 'package:touchhealth/controller/medication/medication_cubit.dart';
import 'package:touchhealth/controller/validation/formvalidation_cubit.dart';
import 'package:touchhealth/view/widget/button_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:touchhealth/core/utils/helper/extention.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/utils/helper/custom_dialog.dart';
import '../../widget/black_button.dart';
import '../../widget/custom_button.dart';
import '../../widget/custom_drop_down_field.dart';
import '../../widget/custom_text_field.dart';
import '../../widget/custom_text_span.dart';
import '../../widget/my_stepper_form.dart';
import '../../../core/utils/theme/color.dart';
import '../../widget/custom_scrollable_appbar.dart';
import '../../../core/cache/cache.dart';

class ViewConditions extends StatefulWidget {
  const ViewConditions({super.key});

  @override
  State<ViewConditions> createState() => _ViewConditionsState();
}

class _ViewConditionsState extends State<ViewConditions> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? conditionname;
  String? diagnosisdate;
  String? userId;

  

Map<String, dynamic> _userData = CacheData.getMapData(key: "conditionsData");

// void _updateMedicalAidData() {
//     if (_formKey.currentState!.validate()) {
//       _formKey.currentState!.save();
//       if (_medicalAidName == _userData['medicalaidname'] &&
//       _medicalAidNumber == _userData['medicalaidnumber'] &&
//       _patientId == _userData['userId'] &&
//       _medicalAidId == _userData['medicalaidnumber']) {
//         context.pop();
//       } else {
//         context
//             .bloc<MedicalAidCubit>()
//             .updateMedicalAid(
//               medicalaidname: _medicalAidName ?? _userData['medicalaidname'],
//               medicalaidnumber: _medicalAidNumber ?? _userData['medicalaidnumber'],
//               medicaliadid: _medicalAidId ?? _userData['medicalaidid'],
//               userId: _patientId ?? _userData['userId'],
//             )
//             .then((_) => context.pop());
//       }
//     }
//   }

  @override
  Widget build(BuildContext context) {
    //print("Medical Aid Data in Create Medical Aid: $_userData");
    return BlocConsumer<MedicationCubit, AccountState>(
    listener: (context, state) {
      if (state is ProfileUpdateLoading) {
        _isLoading = true;
      } else if (state is ProfileUpdateSuccess) {
        _isLoading = false;
        customSnackBar(context, "Conditions Updated Successfully", ColorManager.green);
      } else if (state is ProfileUpdateFailure) {
        _isLoading = false;
        customSnackBar(context, state.message, ColorManager.error);
      }
      if (state is AccountSuccess) {
      // update local data
        _userData = state.medicationDataModel.toJson();
    }
    //print("Medical Aid Data in Create Medical Aid: $_userData");
    },
    builder: (context, state) {
        //print("Medical Aid Data in Create Medical Aid: $_userData");
        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                children: [
                  Gap(32.h),
                  const CustomTitleBackButton(title: "View Condition"),
                  Gap(20.h),
                  _buildUserCard(
                    context,
                    char: (_userData['name']?.isNotEmpty ?? false) ? _userData['name'][0] : "?",
                    name: _userData['name'] ?? "Unknown",
                  ),
                  _buildMedicalConditionsDataFields(context, _userData),
                  Gap(14.h),
                  CustomButton(
                    title: "Cancel",
                    backgroundColor: ColorManager.error,
                    onPressed: () => context.pop(),
                  ),
                  Gap(22.h),
                ],
              ),
            ),
          ),
        );
       // fallback
    },
  );
  
  }

  Widget _buildUserCard(BuildContext context,
      {required String char, required String name}) {
    final divider = Divider(
      color: ColorManager.green.withOpacity(0.4),
      thickness: 1.w,
      endIndent: 5,
      indent: 5,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: divider),
            Container(
              alignment: Alignment.center,
              width: context.width / 3.8,
              height: context.width / 3.8,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ColorManager.green.withOpacity(0.1),
                  border: Border.all(width: 2.w, color: ColorManager.green)),
              child: Text(
                char.toUpperCase(),
                style: context.textTheme.displayLarge
                    ?.copyWith(fontSize: 32.spMin),
              ),
            ),
            Expanded(child: divider),
          ],
        ),
        Gap(10.h),
        Text(
          name,
          style: context.textTheme.bodyLarge?.copyWith(fontSize: 18.spMin),
        ),
      ],
    );
  }


  Widget _buildMedicalConditionsDataFields(
    BuildContext context, Map<String, dynamic> userData) {
    final cubit = context.bloc<ValidationCubit>();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            initialValue: userData['conditionname'],
            keyboardType: TextInputType.name,
            title: "Condition Name",
          ),
          CustomTextFormField(
            initialValue: userData['diagnosisdate'],
            keyboardType: TextInputType.name,
            title: "Diagnosis Date",
          ),
         
        ],
      ),
    );
  }
}

