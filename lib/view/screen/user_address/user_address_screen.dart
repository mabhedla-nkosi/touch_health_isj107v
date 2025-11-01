import 'dart:io';

import 'package:touchhealth/controller/user_address/user_address_cubit.dart';
import 'package:touchhealth/core/utils/helper/scaffold_snakbar.dart';
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

class UserAddress extends StatefulWidget {
  const UserAddress({super.key});

  @override
  State<UserAddress> createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {

  Map<String, dynamic> userAddress = {};

  @override
  void initState() {
    super.initState();
    _loadUserAddressData();
  }

  final TextEditingController _postalAddressController = TextEditingController();
  final TextEditingController _postalAddressCodeController = TextEditingController();
  final TextEditingController _physicalAddressController = TextEditingController();
  final TextEditingController _physicalAddressCodeController = TextEditingController();

  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  String? _postalAddress;
  String? _postalCode;
  String? _physicalAddress;
  String? _physicalCode; 

Future<void> _loadUserAddressData() async {
    final data = await CacheData.getMapData(key: "userAddressData");
    if (data != null) {
      setState(() {
        userAddress= data['userAddressData'] ?? {};
        _postalAddressController.text = userAddress['postaladdress'] ?? '';
        _postalAddressCodeController.text = userAddress['postalcode'] ?? '';
        _physicalAddressController.text = userAddress['physicaladdress'] ?? '';
        _physicalAddressCodeController.text = userAddress['physicalcode'] ?? '';
      });
    }
  }

  void _updateUserAddressData() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Load cached data (already saved as { "userAddressData": {...} })
      final cachedData = CacheData.getMapData(key: "userAddressData");
      final addressMap = cachedData['userAddressData'] ?? {};

      // Retrieve cached IDs
      final cachedAddressId = addressMap['addressid'] ?? 0;
      final cachedUserId = addressMap['userid'] ?? 0;

      // Convert to int if needed (avoid type mismatch)
      final int addressId = int.tryParse('$cachedAddressId') ?? 0;
      final int userId = int.tryParse('$cachedUserId') ?? 0;

      if (addressId == 0 || userId == 0) {
        debugPrint('Missing userId or addressId');
        return;
      }

      // Check if nothing changed (optional optimization)
      if ((_postalAddress == addressMap['postaladdress']) &&
          (_postalCode == addressMap['postalcode']) &&
          (_physicalAddress == addressMap['physicaladdress']) &&
          (_physicalCode == addressMap['physicalcode'])) {
        debugPrint('ℹ️ No changes detected');
        context.pop();
        return;
      }

      // Perform the update
      context
          .bloc<UserAddressCubit>()
          .updateUserAddress(
            addressId: addressId,
            userId: userId,
            postalAddress: _postalAddress ?? addressMap['postaladdress'],
            postalCode: _postalCode ?? addressMap['postalcode'],
            physicalAddress: _physicalAddress ?? addressMap['physicaladdress'],
            physicalCode: _physicalCode ?? addressMap['physicalcode'],
          )
          .then((_) => context.pop());
    }
  }


  @override
  Widget build(BuildContext context) {
    //print("Medical Aid Data in Create Medical Aid: $_userData");
    return BlocConsumer<UserAddressCubit, UserAddressSearchState>(
    listener: (context, state) {
      if (state is UserAddressSearchLoading) {
        _isLoading = true;
      } else if (state is UserAddressDetailsSuccess) {
        _isLoading = false;
        customSnackBar(context, "User Address Details Updated Successfully", ColorManager.green);
      } else if (state is UserAddressSearchError) {
        _isLoading = false;
        customSnackBar(context, state.message, ColorManager.error);
      }
      if (state is UserAddressSearchSuccess) {
      // update local data
        _loadUserAddressData();
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
                  const CustomTitleBackButton(title: "User Address"),
                   Gap(20.h),
                  _buildUserAddressDataFields(context, userAddress),
                  Gap(28.h),
                  CustomButton(
                    widget: _isLoading ? const ButtonLoadingIndicator() : null,
                    isDisabled: _isLoading,
                    title: "Update",
                    onPressed: _updateUserAddressData,
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

  Widget _buildUserAddressDataFields(
    BuildContext context, Map<String, dynamic> userData) {
    final cubit = context.bloc<ValidationCubit>();
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: _postalAddressController,
            //keyboardType: TextInputType.text,
            title: "Postal Address",
            hintText: "Enter your Postal Address",
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onSaved: (data) {
              _postalAddress = data;
            },
            validator: cubit.normalValueValidator,
          ),
          CustomTextFormField(
            controller: _postalAddressCodeController,
            keyboardType: TextInputType.text,
            title: "Postal Address Code",
            hintText: "Enter your Postal Address Code",
            onSaved: (data) {
              _postalCode = data;
            },
            validator: cubit.normalValueValidator,
          ),
          CustomTextFormField(
            controller: _physicalAddressController,
            //keyboardType: TextInputType.text,
            title: "Physical Address",
            hintText: "Enter your Physical Address Code",
            keyboardType: TextInputType.multiline,
            maxLines: null,
            onSaved: (data) {
              _physicalAddress = data;
            },
            validator: cubit.normalValueValidator,
          ),
          CustomTextFormField(
            controller: _physicalAddressCodeController,
            keyboardType: TextInputType.text,
            title: "Physical Address Code",
            hintText: "Enter your Physical Address Code",
            onSaved: (data) {
              _physicalCode = data;
            },
            validator: cubit.normalValueValidator,
          ),
         
        ],
      ),
    );
  }

}

