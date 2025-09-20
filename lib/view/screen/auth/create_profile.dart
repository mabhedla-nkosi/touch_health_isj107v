import 'package:touchhealth/core/utils/helper/scaffold_snakbar.dart';
import 'package:touchhealth/controller/auth/sign_up/sign_up_cubit.dart';
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

class CreateProfile extends StatefulWidget {
  const CreateProfile({super.key, required this.userCredential});

  final List<String?> userCredential;

  @override
  State<CreateProfile> createState() => _CreateProfileState();
}

class _CreateProfileState extends State<CreateProfile> {
  late GlobalKey<FormState> formKey;

  @override
  void initState() {
    super.initState();
    formKey = GlobalKey<FormState>();
  }

  bool _isLoading = false;
  String? _name;
  //String? _userId;
  String? _surname;
  String? _contactInfo;
  //final String? _dateofrecording = DateTime.now().toIso8601String();
  String? _email;
  String? _password;
  String? _id_passportnumber;
  String? _gender;
  String? _dob;
  String? _nationality;
  List<Item> genderList = const [
    Item("Male"),
    Item("Female"),
    Item("Non-Binary"),
  ];

  List<Item> nationalityList = const [
  Item("Afghan"),
  Item("Albanian"),
  Item("Algerian"),
  Item("American"),
  Item("Argentinian"),
  Item("Australian"),
  Item("Austrian"),
  Item("Bangladeshi"),
  Item("Belgian"),
  Item("Brazilian"),
  Item("British"),
  Item("Bulgarian"),
  Item("Canadian"),
  Item("Chilean"),
  Item("Chinese"),
  Item("Colombian"),
  Item("Croatian"),
  Item("Cuban"),
  Item("Czech"),
  Item("Danish"),
  Item("Dutch"),
  Item("Egyptian"),
  Item("Filipino"),
  Item("Finnish"),
  Item("French"),
  Item("German"),
  Item("Greek"),
  Item("Hungarian"),
  Item("Indian"),
  Item("Indonesian"),
  Item("Iranian"),
  Item("Iraqi"),
  Item("Irish"),
  Item("Israeli"),
  Item("Italian"),
  Item("Japanese"),
  Item("Kenyan"),
  Item("Korean"),
  Item("Malaysian"),
  Item("Mexican"),
  Item("Nigerian"),
  Item("Norwegian"),
  Item("Pakistani"),
  Item("Peruvian"),
  Item("Polish"),
  Item("Portuguese"),
  Item("Romanian"),
  Item("Russian"),
  Item("Saudi"),
  Item("South African"),
  Item("Spanish"),
  Item("Swedish"),
  Item("Swiss"),
  Item("Thai"),
  Item("Turkish"),
  Item("Ukrainian"),
  Item("Venezuelan"),
  Item("Vietnamese")
];

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Column(
            children: [
              Gap(context.height * 0.03),
              const Backbutton(),
              Gap(context.height * 0.032),
              CustomTextSpan(
                  textOne: "Create ", textTwo: "Profile", fontSize: 24.spMin),
              Gap(8.h),
              Text(
                "Please enter your data and you can be changed it again from within the settings",
                textAlign: TextAlign.center,
                style:
                    context.textTheme.bodySmall?.copyWith(fontSize: 16.spMin),
              ),
              Gap(26.h),
              const SignInStepperForm(stepReachedNumber: 2),
              _buildCreateProfileFields(),
              Gap(18.h),
              BlocConsumer<SignUpCubit, SignUpState>(
                listener: (context, state) {
                  if (state is SignUpLoading) {
                    _isLoading = true;
                  }
                  if (state is CreateProfileSuccess) {
                    FocusScope.of(context).unfocus();
                  }
                  if (state is VerifyEmailSuccess) {
                    FocusScope.of(context).unfocus();
                    _isLoading = false;
                    customDialogWithAnimation(context,
                        dismiss: false, screen: const LoginDialog());
                  }
                  if (state is CreateProfileFailure) {
                    customSnackBar(context, state.errorMessage);
                    _isLoading = false;
                  }
                  if (state is VerifyEmailFailure) {
                    customSnackBar(context, state.errorMessage);
                    _isLoading = false;
                  }
                  if (state is CreateProfileFailure) {
                    customSnackBar(context, state.errorMessage);
                    _isLoading = false;
                  }
                },
                builder: (context, state) {
                  final cubit = context.bloc<SignUpCubit>();
                  return CustomButton(
                    isDisabled: _isLoading,
                    widget: _isLoading == true
                        ? const ButtonLoadingIndicator()
                        : null,
                    title: "Submit",
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        await cubit.createEmailAndPassword(
                          email: widget.userCredential[0]!,
                          password: widget.userCredential[1]!,
                        );
                        await cubit.createProfile(
                          name: _name ?? '',
                          surname: _surname ?? '',
                          contactInfo: _contactInfo ?? '',
                          email: widget.userCredential[0] ?? '',
                          password: widget.userCredential[1] ?? '',
                          id_passportnumber: _id_passportnumber ?? '',
                          gender: _gender ?? '',
                          dob: _dob ?? '',
                          nationality: _nationality ?? '',
                        );
                        await cubit.verifyEmail();
                      }
                    },
                  );
                },
              ),
              Gap(18.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateProfileFields() {
    final cubit = context.bloc<ValidationCubit>();
    return Form(
      key: formKey,
      child: Column(
        children: [
          CustomTextFormField(
            keyboardType: TextInputType.name,
            title: "Name",
            hintText: "Enter your Name",
            onSaved: (data) {
              _name = data;
            },
            validator: cubit.nameValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.name,
            title: "Surname",
            hintText: "Enter your Surname",
            onSaved: (data) {
              _surname = data;
            },
            validator: cubit.nameValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.text,
            title: "Id / passport number",
            hintText: "Enter your ID or Passport Number",
            onSaved: (data) {
              _id_passportnumber = data;
            },
            validator: cubit.valueValidator,
          ),
          CustomTextFormField(
            keyboardType: TextInputType.phone,
            title: "Phone Number",
            hintText: "Enter your phone Number",
            onSaved: (data) {
              _contactInfo = data!;
            },
            validator: cubit.phoneNumberValidator,
          ),
          CustomTextFormField(
            initialValue: "dd/mm/yyyy",
            keyboardType: TextInputType.datetime,
            title: "Date of birth",
            hintText: "Enter your Date of birth",
            onSaved: (data) {
              _dob = data;
            },
            validator: cubit.validateDateOfBirth,
          ),
          CustomDropDownField(
            hintText: "Enter your Gender",
            title: "Gender",
            items: genderList,
            onSaved: (data) {
              _gender = data!.name.toString();
            },
          ),
          CustomDropDownField(
              hintText: "Enter your nationality",
              title: "Nationlity",
              items: nationalityList,
              onSaved: (data) {
                _nationality = data!.name.toString();
              }),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextFormField(
          //         keyboardType: TextInputType.number,
          //         title: "Height ( CM )",
          //         hintText: "Enter your height",
          //         onSaved: (data) {
          //           _height = data!;
          //         },
          //         validator: cubit.heightValidator,
          //       ),
          //     ),
          //     Gap(18),
          //     Expanded(
          //       child: CustomTextFormField(
          //         keyboardType: TextInputType.number,
          //         title: "Weight ( KG )",
          //         hintText: "Enter your weight",
          //         onSaved: (data) {
          //           _weight = data!;
          //         },
          //         validator: cubit.weightValidator,
          //       ),
          //     ),
          //   ],
          // ),
          // CustomTextFormField(
          //   keyboardType: TextInputType.multiline,
          //   maxLines: 4,
          //   closeWhenTapOutside: true,
          //   title: "chronic diseases",
          //   hintText: "Enter your chronic diseases",
          //   onSaved: (data) {
          //     _chronicDiseases = data;
          //   },
          // ),
          // CustomTextFormField(
          //   keyboardType: TextInputType.multiline,
          //   maxLines: 4,
          //   closeWhenTapOutside: true,
          //   title: "Family history of chronic diseases",
          //   hintText: "Enter your Family history of chronic diseases",
          //   onSaved: (data) {
          //     _familyHistoryOfChronicDiseases = data;
          //   },
          // ),
        ],
      ),
    );
  }
}
