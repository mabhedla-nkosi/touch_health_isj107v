import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:touchhealth/core/router/routes.dart';
import 'package:touchhealth/core/utils/constant/api_url.dart';
import 'package:touchhealth/core/utils/helper/scaffold_snakbar.dart';
import 'package:touchhealth/core/utils/helper/download_dialog.dart';
import 'package:touchhealth/data/model/conditions_model.dart';
import 'package:touchhealth/data/model/labscreening_model.dart';
import 'package:touchhealth/data/model/medical_aid_model.dart';
import 'package:touchhealth/data/model/medication_model.dart';
import 'package:touchhealth/data/model/user_data_model.dart';
import 'package:touchhealth/view/screen/account/edit_user_card_buttom_sheet.dart';
import 'package:touchhealth/view/widget/build_profile_card.dart';
import 'package:touchhealth/view/widget/button_loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:touchhealth/core/service/nfc_service.dart';
import 'package:touchhealth/core/service/qr_service.dart';
import 'package:touchhealth/core/service/text_input_service.dart';
import 'package:touchhealth/core/utils/helper/extention.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:developer';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';

import '../../../controller/medical_record/medical_record_cubit.dart';
import '../../../core/utils/theme/color.dart';
import '../../../core/utils/helper/permission_manager.dart';
import '../../../core/utils/helper/custom_dialog.dart';
import '../../../core/utils/constant/image.dart';
import '../../widget/custom_tooltip.dart';

import 'package:touchhealth/controller/medical_aid/medical_aid_cubit.dart' as medicalaid;
import 'package:touchhealth/controller/medication/medication_cubit.dart' as medication;
import 'package:touchhealth/controller/labscreening/labscreening_cubit.dart' as labscreening;
import 'package:touchhealth/controller/conditions/conditions_cubit.dart' as conditions;
import 'package:touchhealth/controller/account/account_cubit.dart' as account;
import 'package:touchhealth/controller/practitioner/patient_search_cubit.dart' as patientCubit;

class NFCScreen extends StatefulWidget {
  final String? id;

  const NFCScreen({super.key, this.id});

  @override
  State<NFCScreen> createState() => _NFCScreenState();
}

class _NFCScreenState extends State<NFCScreen> {
  late WebViewController _controller;
  late final MedicalRecordCubit _cubit;
  bool _isLoading = true;
  final NfcService _nfcService = NfcService();
  final QrService _qrService = QrService();
  final TextInputService _textInputService = TextInputService();
  bool _isScanning = false;
  bool _isQrScanning = false;
  bool _isTextInputting = false;
  MobileScannerController? _qrController;
  final TextEditingController _textController = TextEditingController();
  String? _downloadedFilePath;
  bool _isFileDownloaded = false;

  @override
  void initState() {
    super.initState();
    context.bloc<account.AccountCubit>().getprofileData();
    context.bloc<medicalaid.MedicalAidCubit>().getMedicalAidData();
    context.bloc<conditions.ConditionsCubit>().getConditionsData();
    context.bloc<labscreening.LabScreeningCubit>().getLabScreeningData();
    context.bloc<medication.MedicationCubit>().getMedicationData();
    _cubit = MedicalRecordCubit();
    //context.bloc<patientCubit.PatientSearchCubit>().searchPatientsByName('');

    if (widget.id != null) {
      _cubit.updateWebViewId(widget.id!);
    } else {
      _cubit.initWebView();
    }

    _setupWebViewController();
    _qrController = MobileScannerController();

    
  }

  void _setupWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            log('WebView error: ${error.description}');
          },
        ),
      );

    // Load initial URL after cubit initialization
    _loadInitialUrl();
  }

  Future<void> _loadInitialUrl() async {
    try {
      String initialUrl;
      if (widget.id != null) {
        // Wait for the cubit to process the ID and generate URL
        await Future.delayed(const Duration(milliseconds: 100));
        await _cubit.loadMedicalRecord(widget.id!);
        initialUrl = _cubit.state.url;
      } else {
        await _cubit.initWebView();
        initialUrl = _cubit.state.url;
      }
      
      if (initialUrl.isNotEmpty) {
        await _controller.loadRequest(Uri.parse(initialUrl));
      }
    } catch (e) {
      log('Error loading initial URL: $e');
    }
  }

  @override
  void dispose() {
    _qrController?.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _scanNFC() async {
    setState(() {
      _isScanning = true;
    });

    bool isAvailable = await _nfcService.isNfcAvailable();

    if (!isAvailable) {
      customSnackBar(context, 'NFC is not available on this device');
      setState(() {
        _isScanning = false;
      });
      return;
    }

    await _nfcService.readNfcData(
      onTagDiscovered: (data) {
        setState(() {
          _isScanning = false;
        });

        String? nfcId = data['tagId'];
        log('NFC Tag ID from service: $nfcId');

        if (nfcId != null && nfcId.isNotEmpty) {
          // Use the async loadMedicalRecord method instead of direct URL loading
          _cubit.loadMedicalRecord(nfcId).then((_) {
            // After loading, update the WebView with the generated URL
            _controller.loadRequest(Uri.parse(_cubit.state.url));
            setState(() {});
            customSnackBar(context, 'NFC tag read successfully: ID $nfcId');
          }).catchError((error) {
            log('Error loading medical record: $error');
            customSnackBar(context, 'Error loading medical record: $error', ColorManager.error);
          });
          _cubit.nfcID = nfcId; // Store the ID for PDF download
        } else {
          customSnackBar(context, 'Could not find ID in NFC tag');
        }
      },
      onError: (error) {
        setState(() {
          _isScanning = false;
        });
        customSnackBar(context, 'Error: $error', ColorManager.error);
      },
      onTimeout: () {
        setState(() {
          _isScanning = false;
        });
        customSnackBar(context, 'NFC scan timed out');
      },
    );
  }

  Future<void> _scanQRCode() async {
    setState(() {
      _isQrScanning = true;
    });

    bool isAvailable = await _qrService.isCameraAvailable();

    if (!isAvailable) {
      customSnackBar(context, 'Camera is not available on this device');
      setState(() {
        _isQrScanning = false;
      });
      return;
    }

    await _qrService.scanQrCode(
      onQrCodeScanned: (data) {
        setState(() {
          _isQrScanning = false;
        });

        String? qrId = data['tagId'];
        log('QR Code ID from service: $qrId');

        if (qrId != null && qrId.isNotEmpty) {
          // Use the async loadMedicalRecord method instead of direct URL loading
          _cubit.loadMedicalRecord(qrId).then((_) {
            // After loading, update the WebView with the generated URL
            _controller.loadRequest(Uri.parse(_cubit.state.url));
            setState(() {});
            customSnackBar(context, 'QR code scanned successfully: ID $qrId');
          }).catchError((error) {
            log('Error loading medical record: $error');
            customSnackBar(context, 'Error loading medical record: $error', ColorManager.error);
          });
          _cubit.nfcID = qrId; // Use same variable for compatibility
        } else {
          customSnackBar(context, 'Could not find ID in QR code');
        }
      },
      onError: (error) {
        setState(() {
          _isQrScanning = false;
        });
        customSnackBar(context, 'Error: $error', ColorManager.error);
      },
      onTimeout: () {
        setState(() {
          _isQrScanning = false;
        });
        customSnackBar(context, 'QR code scan timed out');
      },
    );
  }

  void _showQRScanner() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.black,
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorManager.green,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isQrScanning = false;
                          });
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: MobileScanner(
                    controller: _qrController,
                    onDetect: (capture) {
                      final List<Barcode> barcodes = capture.barcodes;
                      for (final barcode in barcodes) {
                        if (barcode.rawValue != null) {
                          Navigator.of(context).pop();
                          _qrService.processQrData(
                            barcode.rawValue!,
                            (data) {
                              setState(() {
                                _isQrScanning = false;
                              });

                              String? qrId = data['tagId'];
                              log('QR Code ID from scanner: $qrId');

                              if (qrId != null && qrId.isNotEmpty) {
                                _cubit.updateWebViewId(qrId);
                                final url = '${_cubit.baseUrl}$qrId';
                                log('Loading WebView URL: $url');
                                _controller.loadRequest(Uri.parse(url));
                                _cubit.nfcID = qrId;
                                setState(() {});
                                customSnackBar(context, 'QR code scanned successfully: ID $qrId');
                              } else {
                                customSnackBar(context, 'Could not find ID in QR code');
                              }
                            },
                          );
                          break;
                        }
                      }
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ColorManager.green.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Position the QR code within the frame to scan',
                    style: TextStyle(
                      color: ColorManager.green,
                      fontSize: 14.sp,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _scanTextInput() async {
    setState(() {
      _isTextInputting = true;
    });

    bool isAvailable = await _textInputService.isTextInputAvailable();

    if (!isAvailable) {
      customSnackBar(context, 'Text input is not available');
      setState(() {
        _isTextInputting = false;
      });
      return;
    }

    await _textInputService.processTextInput(
      onTextInputProcessed: (data) {
        setState(() {
          _isTextInputting = false;
        });

        String? textId = data['tagId'];
        log('Text Input ID from service: $textId');

        if (textId != null && textId.isNotEmpty) {
          // Use the async loadMedicalRecord method instead of direct URL loading
          _cubit.loadMedicalRecord(textId).then((_) {
            // After loading, update the WebView with the generated URL
            _controller.loadRequest(Uri.parse(_cubit.state.url));
            setState(() {});
            customSnackBar(context, 'Medical ID entered successfully: ID $textId');
          }).catchError((error) {
            log('Error loading medical record: $error');
            customSnackBar(context, 'Error loading medical record: $error', ColorManager.error);
          });
          _cubit.nfcID = textId; // Use same variable for compatibility
        } else {
          customSnackBar(context, 'Could not process medical ID');
        }
      },
      onError: (error) {
        setState(() {
          _isTextInputting = false;
        });
        customSnackBar(context, 'Error: $error', ColorManager.error);
      },
      onTimeout: () {
        setState(() {
          _isTextInputting = false;
        });
        customSnackBar(context, 'Text input timed out');
      },
    );
  }

  void _showTextInputDialog() {
    _textController.clear();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Enter Medical Record ID',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.green,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _isTextInputting = false;
                        });
                      },
                      icon: Icon(
                        Icons.close,
                        color: ColorManager.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Please enter the medical record ID manually:',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorManager.grey,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Enter medical record ID...',
                    hintStyle: TextStyle(
                      color: ColorManager.grey.withOpacity(0.6),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorManager.green.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorManager.green,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: ColorManager.green.withOpacity(0.3),
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.medical_information,
                      color: ColorManager.green,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: ColorManager.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Examples: 12345, MED-001, REC123456',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorManager.grey.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isTextInputting = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.grey.withOpacity(0.2),
                          foregroundColor: ColorManager.grey,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () {
                          final inputText = _textController.text.trim();
                          if (inputText.isNotEmpty) {
                            Navigator.of(context).pop();
                            _textInputService.processTextData(
                              inputText,
                              (data) {
                                setState(() {
                                  _isTextInputting = false;
                                });

                                String? textId = data['tagId'];
                                log('Text Input ID from dialog: $textId');

                                if (textId != null && textId.isNotEmpty) {
                                  _cubit.updateWebViewId(textId);
                                  final url = '${_cubit.baseUrl}$textId';
                                  log('Loading WebView URL: $url');
                                  _controller.loadRequest(Uri.parse(url));
                                  _cubit.nfcID = textId;
                                  setState(() {});
                                  customSnackBar(context, 'Medical ID entered successfully: ID $textId');
                                } else {
                                  customSnackBar(context, 'Invalid medical ID format');
                                }
                              },
                            );
                          } else {
                            customSnackBar(context, 'Please enter a medical record ID');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorManager.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Load Record',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _downloadPDF(String url) async {
    setState(() {
      _isLoading = true;
    });

    bool isCancelled = false;
    CancelToken cancelToken = CancelToken();

    Function? updateDialog;

    try {
      showDownloadProgressDialog(
        context: context,
        initialMessage: 'Preparing to download PDF...',
        onControllerReady: (updateFn) {
          updateDialog = updateFn;
        },
        onCancel: () {
          isCancelled = true;
          cancelToken.cancel('Download cancelled by user');
          Navigator.of(context, rootNavigator: true).pop();
          _showMessageDialog(
              context, 'Download Cancelled', 'Download operation was cancelled',
              isError: true);
        },
        onOpen: () {
          Navigator.of(context, rootNavigator: true).pop();
          _openDownloadedFile();
        },
      );

      await Future.delayed(Duration(milliseconds: 200));

      final permissionManager = PermissionManager();
      bool permissionGranted = await permissionManager.requestPermission();

      if (permissionGranted) {
        Directory? directory;
        if (Platform.isAndroid) {
          try {
            directory = Directory('/storage/emulated/0/Download');
            if (!await directory.exists()) {
              await directory.create(recursive: true);
            }
          } catch (e) {
            log('Error accessing Download directory: $e');
            directory = await getExternalStorageDirectory();
            if (directory == null) {
              throw Exception('Could not access external storage');
            }
          }
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        String fileName =
            'medical_record_${DateTime.now().millisecondsSinceEpoch}.pdf';
        String filePath = '${directory.path}/$fileName';

        log('Downloading PDF to: $filePath');
        updateDialog?.call(0.05, 'Establishing connection...', false);

        final dio = Dio();

        try {
          final response = await dio.get(
            url,
            options: Options(
              responseType: ResponseType.bytes,
              followRedirects: true,
              validateStatus: (status) => status != null && status < 500,
              headers: {
                'Accept': '*/*',
                'User-Agent':
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36',
              },
            ),
            cancelToken: cancelToken,
            onReceiveProgress: (received, total) {
              if (total != -1 && !isCancelled) {
                final progress = received / total;
                updateDialog?.call(
                    progress,
                    'Downloading PDF... ${(progress * 100).toStringAsFixed(0)}%',
                    false);
              }
            },
          );

          if (response.statusCode == 200) {
            final file = File(filePath);
            updateDialog?.call(0.95, 'Saving file...', false);
            await file.writeAsBytes(response.data);

            if (await file.exists() && await file.length() > 0) {
              log('File downloaded successfully to: ${file.path} with size: ${await file.length()} bytes');

              _downloadedFilePath = file.path;
              _isFileDownloaded = true;

              updateDialog?.call(
                  1.0, 'PDF downloaded successfully to Downloads folder', true);

              setState(() {});
            } else {
              throw Exception('File was created but is empty or invalid');
            }
          } else {
            throw Exception('Failed to download file: ${response.statusCode}');
          }
        } catch (dioError) {
          if (isCancelled) {
            return;
          }

          log('Initial download method failed: $dioError');
          log('Trying alternative download method...');

          updateDialog?.call(
              0.1, 'Trying alternative download method...', false);

          try {
            await dio.download(
              url,
              filePath,
              options: Options(
                followRedirects: true,
                validateStatus: (status) => status != null && status < 500,
              ),
              cancelToken: cancelToken,
              onReceiveProgress: (received, total) {
                if (total != -1 && !isCancelled) {
                  final progress = received / total;
                  updateDialog?.call(
                      progress,
                      'Downloading PDF... ${(progress * 100).toStringAsFixed(0)}%',
                      false);
                }
              },
            );

            final file = File(filePath);
            if (await file.exists() && await file.length() > 0) {
              log('File downloaded successfully with alternative method. Size: ${await file.length()} bytes');

              _downloadedFilePath = file.path;
              _isFileDownloaded = true;

              updateDialog?.call(
                  1.0, 'PDF downloaded successfully to Downloads folder', true);

              setState(() {});
            } else {
              throw Exception(
                  'Alternative download failed: File is empty or invalid');
            }
          } catch (alternativeError) {
            if (isCancelled) {
              return;
            }
            throw Exception('All download attempts failed: $alternativeError');
          }
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop();
        _showMessageDialog(context, 'Permission Error',
            'Storage permission denied. Please enable in settings.',
            isError: true);
        openAppSettings();
      }
    } catch (e) {
      if (!isCancelled) {
        log('Error downloading PDF: $e');
        Navigator.of(context, rootNavigator: true).pop();
        _showMessageDialog(
            context, 'Download Error', 'Error downloading PDF: ${e.toString()}',
            isError: true);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openDownloadedFile() async {
    final path = _downloadedFilePath;
    if (path == null) return;
    final file = File(path);
    if (!await file.exists()) {
      _showMessageDialog(context, 'Error', 'File does not exist anymore', isError: true);
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Downloaded'),
        content: const Text('Your medical record PDF is ready. What would you like to do?'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Share.shareXFiles([XFile(file.path)], text: 'Medical Record', subject: 'Medical Record PDF');
            },
            child: const Text('Share'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              _openFileWithOptions(file);
            },
            child: const Text('Open'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openFileWithOptions(File file) async {
    try {
      await OpenFilex.open(
        file.path,
        type: 'application/pdf',
      );
    } catch (e) {
      log('Error opening file with options: $e');
      _showMessageDialog(
          context, 'Error', 'Error opening file: ${e.toString()}',
          isError: true);
    }
  }

  void _showMessageDialog(BuildContext context, String title, String message,
      {bool isError = false}) {
    customDialog(
      context,
      title: title,
      errorMessage: message,
      subtitle: '',
      buttonTitle: 'Cancel',
      onPressed: () => Navigator.of(context).pop(),
      image: isError ? ImageManager.errorIcon : ImageManager.trueIcon,
      dismiss: true,
    );
  }

  Widget _buildUserCard(BuildContext context,
      {required String char, required String email, required String name}) {
    return Card(
      margin: EdgeInsets.zero,
      color: ColorManager.trasnsparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: ColorManager.grey, width: 1),
      ),
      child: ListTile(
        leading: Container(
            alignment: Alignment.center,
            height: 50.w,
            width: 50.w,
            decoration: BoxDecoration(
              color: ColorManager.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                width: 1.5.w,
                color: ColorManager.green,
              ),
            ),
            child: Text(
              char,
              style: context.textTheme.displayLarge,
            )),
        title: Text(
          name,
          style: context.textTheme.bodyMedium,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          email,
          style: context.textTheme.bodySmall,
          overflow: TextOverflow.ellipsis,
        ),
        contentPadding:
            const EdgeInsets.only(left: 14, right: 6, bottom: 6, top: 6),
        trailing: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () => showEditProfileBottomSheet(context),
            icon: SvgPicture.asset(
              ImageManager.editIcon,
              width: 20.w,
              height: 20.w,
            )),
      ),
    );
  }

  UserDataModel? _userData;
  MedicalAidDataModel? _medicalAidData;
  MedicationDataModel? _medicationData;
  LabScreeningDataModel? _labscreeningData;
  ConditionsDataModel? _conditionsData;
  late Map<String, dynamic> patient= {};

  @override
  Widget build(BuildContext context) {
    final divider = Divider(color: ColorManager.grey, thickness: 1.w);
    return MultiBlocListener(
    listeners: [
      BlocListener<account.AccountCubit, account.AccountState>(
        listener: (context, state) {
          if (state is account.AccountSuccess) {
            _userData = state.userDataModel;

            final String? fullEmail = _userData?.email;

            context.read<patientCubit.PatientSearchCubit>()
              .searchPatientsByEmail(fullEmail.toString());

              // context.read<patientCubit.PatientSearchCubit>()
              // .searchPatientsByName('Demo');
          }
        },
      ),
      BlocListener<medicalaid.MedicalAidCubit, medicalaid.AccountState>(
        listener: (context, state) {
          if (state is medicalaid.AccountSuccess) {
            // handle medical aid data here
            _medicalAidData = state.medicalAidDataModel;
          }
        },
      ),
      BlocListener<medication.MedicationCubit, medication.AccountState>(
        listener: (context, state) {
          if (state is medication.AccountSuccess) {
            // handle medical aid data here
            _medicationData = state.medicationDataModel;
          }
        },
      ),
      BlocListener<labscreening.LabScreeningCubit, labscreening.AccountState>(
        listener: (context, state) {
          if (state is labscreening.AccountSuccess) {
            // handle medical aid data here
            _labscreeningData = state.labDataModel;
          }
        },
      ),
      BlocListener<conditions.ConditionsCubit, conditions.AccountState>(
        listener: (context, state) {
          if (state is conditions.AccountSuccess) {
            // handle medical aid data here
            _conditionsData = state.conditionsDataModel;
          }
        },
      ),
      BlocListener<patientCubit.PatientSearchCubit, patientCubit.PatientSearchState>(
        listener: (context, state) {
          if (state is patientCubit.PatientSearchSuccess) {
            patient = state.patients.first;

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Patient data loaded successfully")),
            );
          }

          if (state is patientCubit.PatientSearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to load patient data")),
            );
          }
        },
      ),
    ],
    child: BlocBuilder<account.AccountCubit, account.AccountState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18, vertical: 18.h),
              child: Column(
                children: [
                  Gap(15.h),
                  // TouchHealth Logo
                  SvgPicture.asset(
                    ImageManager.splashLogo,
                    height: 80.h,
                    width: 80.w,
                  ),
                  Gap(20.h),
                  _buildUserCard(
                    context,
                    char: "",
                    email: _userData?.email ?? "",
                    name: _userData?.name ?? "",
                  ),
                  Gap(20.h),
                  BuildProfileCard(
                    title: "Medical Aid",
                    image: ImageManager.termsIcon,
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteManager.editMedicalAid),
                  ),
                  divider,
                  BuildProfileCard(
                    title: "Medication",
                    image: ImageManager.termsIcon,
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteManager.viewMedication),
                  ),
                  divider,
                  BuildProfileCard(
                    title: "Lab Screening",
                    image: ImageManager.termsIcon,
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteManager.viewLabScreening),
                  ),
                  divider,
                  BuildProfileCard(
                    title: "Conditions",
                    image: ImageManager.termsIcon,
                    onPressed: () =>
                        Navigator.pushNamed(context, RouteManager.viewConditions),
                  ),
                  divider,
                  BuildProfileCard(
                    title: "Medical Record",
                    image: ImageManager.termsIcon,
                    onPressed: () =>
                        //Navigator.pushNamed(context, RouteManager.editMedicalAid),
                        // Navigator.pushNamed(
                        //   context,
                        //   RouteManager.patientDetails,
                        //   arguments: patient,
                        // ),
                        {
                          if (patient.isNotEmpty) {
                            Navigator.pushNamed(
                              context,
                              RouteManager.patientDetails,
                              arguments: patient,
                            )
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please wait, patient data is still loading")),
                            )
                          }
                        }
                  ),
                  divider,
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
  }
}