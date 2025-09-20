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

Map<String, dynamic> _userData = CacheData.getMapData(key: "medicalAidData");

void _updateMedicalAidData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_medicalAidName == _userData['medicalaidname'] &&
      _medicalAidNumber == _userData['medicalaidnumber'] &&
      _patientId == _userData['userId'] &&
      _medicalAidId == _userData['medicalaidnumber']) {
        context.pop();
      } else {
        context
            .bloc<MedicalAidCubit>()
            .updateMedicalAid(
              medicalaidname: _medicalAidName ?? _userData['medicalaidname'],
              medicalaidnumber: _medicalAidNumber ?? _userData['medicalaidnumber'],
              medicaliadid: _medicalAidId ?? _userData['medicalaidid'],
              userId: _patientId ?? _userData['userId'],
            )
            .then((_) => context.pop());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //print("Medical Aid Data in Create Medical Aid: $_userData");
    return BlocConsumer<MedicalAidCubit, AccountState>(
    listener: (context, state) {
      if (state is ProfileUpdateLoading) {
        _isLoading = true;
      } else if (state is ProfileUpdateSuccess) {
        _isLoading = false;
        customSnackBar(context, "Medical Aid Details Updated Successfully", ColorManager.green);
      } else if (state is ProfileUpdateFailure) {
        _isLoading = false;
        customSnackBar(context, state.message, ColorManager.error);
      }
      if (state is AccountSuccess) {
      // update local data
        _userData = state.medicalAidDataModel.toJson();
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
                  const CustomTitleBackButton(title: "Create Medical Aid"),
                  Gap(20.h),
                  _buildUserCard(
                    context,
                    char: (_userData['name']?.isNotEmpty ?? false) ? _userData['name'][0] : "?",
                    name: _userData['name'] ?? "Unknown",
                  ),
                  _buildMedicalAidDataFields(context, _userData),
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
            initialValue: userData['medicalaidnumber'],
            keyboardType: TextInputType.name,
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
