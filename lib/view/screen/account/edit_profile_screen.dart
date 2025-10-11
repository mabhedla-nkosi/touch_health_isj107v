import 'package:touchhealth/core/utils/helper/extention.dart';
import 'package:touchhealth/core/utils/helper/scaffold_snakbar.dart';
import 'package:touchhealth/controller/account/account_cubit.dart';
import 'package:touchhealth/view/widget/button_loading_indicator.dart';
import 'package:touchhealth/view/widget/custom_button.dart';
import 'package:touchhealth/view/widget/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../core/cache/cache.dart';
import '../../../core/utils/theme/color.dart';
import '../../../controller/validation/formvalidation_cubit.dart';
import '../../widget/custom_drop_down_field.dart';
import '../../widget/custom_scrollable_appbar.dart';
import 'package:touchhealth/core/service/user_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  final userService = UserService();
  late Future<User?> futureUser;

  @override
  void initState() {
    super.initState();
    context.read<AccountCubit>().fetchUserById(1);
  }

  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _name;
  String? _userId;
  String? _surname;
  String? _phone;
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

  final Map<String, dynamic> _userData = CacheData.getMapData(key: "userData");
  bool _isloading = false;

  void _updateUserData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_name == _userData['name'] &&
      _surname == _userData['surname'] &&
      _phone == _userData['phone'] &&
      _email == _userData['email'] &&
      _id_passportnumber == _userData['id_passportnumber'] &&
      _gender == _userData['gender'] &&
      _dob == _userData['dob'] &&
      _nationality == _userData['nationality']) {
        context.pop();
      } else {
        context
            .bloc<AccountCubit>()
            .updateProfile(
              name: _name ?? _userData['name'],
              surname: _surname ?? _userData['surname'],
              phone: _phone ?? _userData['phone'],
              email: _email ?? _userData['email'],
              id_passportnumber: _id_passportnumber ?? _userData['id_passportnumber'],
              gender: _gender ?? _userData['gender'],
              dob: _dob ?? _userData['dob'],
              nationality: _nationality ?? _userData['nationality'],
            )
            .then((_) => context.pop());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = User(userid: 1);
    
    return BlocConsumer<AccountCubit, AccountState>(
      listener: (context, state) {
        if (state is ProfileUpdateLoading) {
          _isloading = true;
        }
        if (state is ProfileUpdateSuccess) {
          _isloading = false;
          customSnackBar(
              context, "Profile Updated Successfully", ColorManager.green);
        }
        if (state is ProfileUpdateFailure) {
          _isloading = false;
          customSnackBar(context, state.message, ColorManager.error);
        }
      },
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AccountError) {
          return Center(child: Text("Error: ${state.message}"));
        }
        if (state is AccountLoaded)
        {
          user = state.user;
          //print("UserData in EditProfileScreen: $user");
        }
        return Scaffold(
          body: SingleChildScrollView(
            child: Column(
              children: [
                Gap(32.h),
                const CustomTitleBackButton(
                  title: "Edit Profile",
                ),
                Gap(20.h),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    children: [
                      _buildUserCard(context,
                          //char: _userData['name'][0], name: _userData['name']),
                          char: (user.name?.isNotEmpty ?? false)
                                ? user.name!.substring(0, 1)
                                : "?",
                            name: user.name ?? "Unknown",
                          ),
                      _buildUserProfileDataFields(
                        context,
                        _userData,
                        user
                      ),
                      Gap(28.h),
                      CustomButton(
                          widget: _isloading
                              ? const ButtonLoadingIndicator()
                              : null,
                          isDisabled: _isloading,
                          title: "Update",
                          onPressed: _updateUserData),
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
              ],
            ),
          ),
        );
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

  Widget _buildUserProfileDataFields(
      BuildContext context, Map<String, dynamic> userData, User user) {
    final cubit = context.bloc<ValidationCubit>();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            //initialValue: userData['name'],
            initialValue: user.name,
            keyboardType: TextInputType.name,
            title: "Name",
            hintText: "Enter your Name",
            onSaved: (data) {
              _name = data;
            },
            validator: cubit.nameValidator,
          ),
          CustomTextFormField(
            //initialValue: userData['surname'],
            initialValue: user.surname,
            keyboardType: TextInputType.name,
            title: "Surname",
            hintText: "Enter your Surname",
            onSaved: (data) {
              _surname = data;
            },
            validator: cubit.nameValidator,
          ),
          CustomTextFormField(
            //initialValue: userData['id_passportnumber'],
            initialValue: user.id_passportnumber,
            keyboardType: TextInputType.text,
            title: "Id / passport number",
            hintText: "Enter your ID or Passport Number",
            onSaved: (data) {
              _id_passportnumber = data;
            },
            //validator: cubit.nameValidator,
          ),
          CustomTextFormField(
            //initialValue: userData['contactinfo'],
            initialValue: user.contactinfo,
            keyboardType: TextInputType.phone,
            title: "Phone Number",
            hintText: "Enter your phone Number",
            onSaved: (data) {
              _phone = data!;
            },
            validator: cubit.phoneNumberValidator,
          ),
          CustomTextFormField(
            //initialValue: userData['dob'],
            initialValue: user.dob,
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
            // value: userData['gender'] != null
            //   ? genderList.firstWhere(
            //       (c) => c.name == userData['gender'],
            //       orElse: () => genderList.first, // fallback
            //     )
            //   : null,
            value: user.gender != null
              ? genderList.firstWhere(
                  (c) => c.name == user.gender,
                  orElse: () => genderList.first, // fallback
                )
              : null,
          ),
          CustomDropDownField(
              hintText: "Enter your nationality",
              title: "Nationality",
              items: nationalityList,
              // value: userData['nationality'] != null
              // ? nationalityList.firstWhere(
              //     (c) => c.name == userData['nationality'],
              //     orElse: () => nationalityList.first, // fallback
              //   )
              // : null,
              value: user.nationality != null
              ? nationalityList.firstWhere(
                  (c) => c.name == user.nationality,
                  orElse: () => nationalityList.first, // fallback
                )
              : null,
              onSaved: (data) {
                _nationality = data!.name.toString();
              }),
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextFormField(
          //         initialValue: userData['height'],
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
          //         initialValue: userData['weight'],
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
          //   maxLines: 4,
          //   closeWhenTapOutside: true,
          //   initialValue: userData['chronicDiseases'],
          //   keyboardType: TextInputType.multiline,
          //   title: "chronic diseases",
          //   hintText: "Enter your chronic diseases",
          //   onSaved: (data) {
          //     _chronicDiseases = data;
          //   },
          // ),
          // CustomTextFormField(
          //   maxLines: 4,
          //   closeWhenTapOutside: true,
          //   initialValue: userData['familyHistoryOfChronicDiseases'],
          //   keyboardType: TextInputType.multiline,
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
