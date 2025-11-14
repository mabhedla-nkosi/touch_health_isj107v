import 'dart:io';

import 'package:touchhealth/core/utils/helper/scaffold_snakbar.dart';
import 'package:touchhealth/controller/medical_aid/medical_aid_cubit.dart';
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

class CreateMedicalAid extends StatefulWidget {
  const CreateMedicalAid({super.key});

  @override
  State<CreateMedicalAid> createState() => _CreateMedicalAidState();
}

class _CreateMedicalAidState extends State<CreateMedicalAid> {

  Map<String, dynamic> patientMedicalAid = {};

  @override
  void initState() {
    super.initState();
    _loadMedicalAidData();
  }

  final TextEditingController _medicalAidNumberController = TextEditingController();

  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _medicalAidName;
  String? _medicalAidNumber;
  String? _patientId;
  String? _medicalAidId; 

  List<Item> medicalAidList = const [
  Item("Discovery Health"),
  Item("Bonitas"),
  Item("Momentum Health"),
  Item("Bestmed"),
  Item("Fedhealth"),
  Item("Medihelp"),
  Item("Profmed"),
  Item("Bankmed"),
  Item("KeyHealth"),
  Item("Resolution Health"),
  Item("Sizwe"),
  Item("CompCare"),
  Item("Thebemed"),
  Item("Hosmed"),
  Item("Samwumed"),
  Item("Polmed"),
  Item("GEMS (Government Employees Medical Scheme)"),
  Item("LMPS (Liberty Medical Plan)"),
];

Future<void> _loadMedicalAidData() async {
    final data = await CacheData.getMapData(key: "medicalAidData");
    if (data != null) {
      setState(() {
        patientMedicalAid = data['medicalAidData'] ?? {};
        _medicalAidNumberController.text = patientMedicalAid['medicalnumber'] ?? '';
      });
    }
  }

  Map<String, dynamic> _userData = CacheData.getMapData(key: "medicalAidData");
  //final medicalAidData = CacheData.getMapData(key: "medicalAidData");
  //late Map<String, dynamic> patientMedicalAid= {};
  void _updateMedicalAidData() {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        final medicalAidMap = _userData['medicalAidData'] ?? {};
    final cachedMedicalAidId = medicalAidMap['medicalaidid'] ?? 0;
    final cachedUserId = medicalAidMap['userid'] ?? 0;

    // avoid type mismatch (convert to int if coming as String)
    int medicalAidId = int.tryParse('$cachedMedicalAidId') ?? 0;
    int userId = int.tryParse('$cachedUserId') ?? 0;

    // print('medicalAidId $medicalAidId');
    // print('userID $userId');

    if (medicalAidId == 0 || userId == 0) {
      debugPrint('Missing userId or medicalAidId');
      return;
    }

    
        if (_medicalAidName == _userData['medicalaidname'] &&
        _medicalAidNumber == _userData['medicalnumber'] &&
        _patientId == _userData['userId'] &&
        _medicalAidId == _userData['medicalnumber']) {
          context.pop();
        } else {
          context
              .bloc<MedicalAidCubit>()
              .updateMedicalAid(
                medicalAidName: _medicalAidName ?? _userData['medicalaidname'],
                medicalAidNumber: _medicalAidNumber ?? _userData['medicalnumber'],
                medicalAidId: medicalAidId,
                userId: userId,
              )
              .then((_) => context.pop());
        }
      }
  }

  @override
  Widget build(BuildContext context) {
    //print("Medical Aid Data in Create Medical Aid: $_userData");
    return BlocConsumer<MedicalAidCubit, MedicalAidSearchState>(
    listener: (context, state) {
      if (state is MedicalAidDetailsLoading) {
        _isLoading = true;
      } else if (state is MedicalAidDetailsSuccess) {
        _isLoading = false;
        customSnackBar(context, "Medical Aid Details Updated Successfully", ColorManager.green);
      } else if (state is MedicalAidSearchError) {
        _isLoading = false;
        customSnackBar(context, state.message, ColorManager.error);
      }
      if (state is MedicalAidSearchSuccess) {
      // update local data
        _loadMedicalAidData();
      }
    },
    builder: (context, state) {
        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: Column(
                children: [
                  Gap(32.h),
                  const CustomTitleBackButton(title: "Medical Aid"),
                   Gap(20.h),
                  _buildMedicalAidDataFields(context, patientMedicalAid),
                  Gap(28.h),
                  CustomButton(
                    widget: _isLoading ? const ButtonLoadingIndicator() : null,
                    isDisabled: _isLoading,
                    title: "Update",
                    onPressed: _updateMedicalAidData,
                  ),
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

  Widget _buildMedicalAidDataFields(
    BuildContext context, Map<String, dynamic> userData) {
    final cubit = context.bloc<ValidationCubit>();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomDropDownField(
            hintText: "Enter your Medical Aid Name",
            title: "Medical Aid Name",
            items: medicalAidList,
            onSaved: (data) {
              _medicalAidName = data!.name.toString();
            },
            value: userData['medicalaidname'] != null
              ? medicalAidList.firstWhere(
                  (c) => c.name == userData['medicalaidname'],
                  orElse: () => medicalAidList.first, // fallback
                )
              : null,
          ),
          CustomTextFormField(
            controller: _medicalAidNumberController,
            keyboardType: TextInputType.text,
            title: "Medical Aid Number",
            hintText: "Enter your Medical Aid Number",
            onSaved: (data) {
              _medicalAidNumber = data;
            },
            validator: cubit.normalValueValidator,
          ),
         
        ],
      ),
    );
  }

}

