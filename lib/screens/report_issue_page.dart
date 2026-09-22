import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../services/location_service.dart';
import '../services/report_store.dart';
import '../models/report.dart';
import 'success_page.dart';
class ReportIssuePage extends StatefulWidget {
  const ReportIssuePage({super.key});

  @override
  State<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController locationController =
      TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  final List<XFile> selectedImages = [];

  final List<String> categories = [
    'Sanitation & Waste Management',
    'Roads & Infrastructure',
    'Water Supply',
    'Electricity',
    'Street Lights',
    'Public Safety',
    'Other',
  ];

  String selectedCategory =
      'Sanitation & Waste Management';

  bool isGettingLocation = false;
  bool isSubmitting = false;

  double? latitude;
  double? longitude;

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------
  // SHOW MESSAGE
  // ------------------------------------------------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ------------------------------------------------------------
  // GET CURRENT LOCATION
  // ------------------------------------------------------------

  Future<void> getCurrentLocation() async {
    if (isGettingLocation) return;

    setState(() {
      isGettingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Please enable location services.',
        );
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        _showMessage(
          'Location permission was denied.',
        );
        return;
      }

      final Position position =
          await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      latitude = position.latitude;
      longitude = position.longitude;

      final String? address =
          await LocationService
              .getAddressFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;

      setState(() {
        locationController.text =
            address ??
                '${position.latitude.toStringAsFixed(6)}, '
                    '${position.longitude.toStringAsFixed(6)}';
      });

      _showMessage(
        'Current location detected.',
      );
    } catch (e) {
      _showMessage(
        'Unable to get your location.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isGettingLocation = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // PICK IMAGES FROM GALLERY
  // ------------------------------------------------------------

  Future<void> pickImagesFromGallery() async {
    if (selectedImages.length >= 5) {
      _showMessage(
        'You can select a maximum of 5 images.',
      );
      return;
    }

    try {
      final List<XFile> images =
          await imagePicker.pickMultiImage();

      if (images.isEmpty) return;

      final int remaining =
          5 - selectedImages.length;

      final List<XFile> imagesToAdd =
          images.take(remaining).toList();

      setState(() {
        selectedImages.addAll(imagesToAdd);
      });

      if (images.length > remaining) {
        _showMessage(
          'Only 5 images can be selected.',
        );
      }
    } catch (e) {
      _showMessage(
        'Unable to select images.',
      );
    }
  }

  // ------------------------------------------------------------
  // PICK IMAGE FROM CAMERA
  // ------------------------------------------------------------

  Future<void> takePhoto() async {
    if (selectedImages.length >= 5) {
      _showMessage(
        'You can select a maximum of 5 images.',
      );
      return;
    }

    try {
      final XFile? image =
          await imagePicker.pickImage(
        source: ImageSource.camera,
      );

      if (image == null) return;

      setState(() {
        selectedImages.add(image);
      });
    } catch (e) {
      _showMessage(
        'Unable to take photo.',
      );
    }
  }

  // ------------------------------------------------------------
  // PICK IMAGE FROM COMPUTER / FILES
  // ------------------------------------------------------------

  Future<void> pickImagesFromFiles() async {
    if (selectedImages.length >= 5) {
      _showMessage(
        'You can select a maximum of 5 images.',
      );
      return;
    }

    try {
      const XTypeGroup imageTypeGroup =
          XTypeGroup(
        label: 'images',
        extensions: [
          'jpg',
          'jpeg',
          'png',
          'webp',
          'gif',
        ],
        mimeTypes: [
          'image/jpeg',
          'image/png',
          'image/webp',
          'image/gif',
        ],
      );

      final List<XFile> files =
          await openFiles(
        acceptedTypeGroups: [
          imageTypeGroup,
        ],
      );

      if (files.isEmpty) return;

      final int remaining =
          5 - selectedImages.length;

      final List<XFile> filesToAdd =
          files.take(remaining).toList();

      setState(() {
        selectedImages.addAll(filesToAdd);
      });

      if (files.length > remaining) {
        _showMessage(
          'Only 5 images can be selected.',
        );
      }
    } catch (e) {
      _showMessage(
        'Unable to select files.',
      );
    }
  }

  // ------------------------------------------------------------
  // IMAGE SOURCE SELECTION
  // ------------------------------------------------------------

  void showImageSourceOptions() {
    if (selectedImages.length >= 5) {
      _showMessage(
        'You can select a maximum of 5 images.',
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Add Images',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text(
                  'Choose from Gallery',
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImagesFromGallery();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text(
                  'Take a Photo',
                ),
                onTap: () {
                  Navigator.pop(context);
                  takePhoto();
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.folder_outlined,
                ),
                title: const Text(
                  'Choose from Files',
                ),
                onTap: () {
                  Navigator.pop(context);
                  pickImagesFromFiles();
                },
              ),

              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // REMOVE IMAGE
  // ------------------------------------------------------------

  void removeImage(int index) {
    setState(() {
      selectedImages.removeAt(index);
    });
  }

  // ------------------------------------------------------------
  // GENERATE TRACKING ID
  // ------------------------------------------------------------

  String generateTrackingId() {
    final DateTime now = DateTime.now();

    final String datePart =
        '${now.year}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';

    final String timePart =
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';

    return 'SAH-$datePart-$timePart';
  }

  // ------------------------------------------------------------
  // SUBMIT REPORT
  // ------------------------------------------------------------

  Future<void> submitReport() async {
    if (isSubmitting) return;

    final String title =
        titleController.text.trim();

    final String description =
        descriptionController.text.trim();

    final String location =
        locationController.text.trim();

    if (title.isEmpty) {
      _showMessage(
        'Please enter a problem title.',
      );
      return;
    }

    if (description.isEmpty) {
      _showMessage(
        'Please enter a description.',
      );
      return;
    }

    if (location.isEmpty) {
      _showMessage(
        'Please enter the location.',
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // ----------------------------------------------------------
      // SAVE REPORT + UPLOAD PHOTOS TO SUPABASE
      // ----------------------------------------------------------

      final Report savedReport =
          await ReportStore.instance.addReport(
        title: title,
        description: description,
        location: location,
        category: selectedCategory,
        priority: 'Medium',
        images: selectedImages,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // OPEN SUCCESS PAGE
      // ----------------------------------------------------------

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SuccessPage(
            trackingId: savedReport.id,
            title: title,
            category: selectedCategory,
            description: description,
            location: location,
          ),
        ),
      );
    } catch (e) {
      debugPrint(
        'Report submission error: $e',
      );

      if (!mounted) return;

      _showMessage(
        'Unable to submit report. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  // ------------------------------------------------------------
  // BUILD
  // ------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: const Text(
          'Report an Issue',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 700,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  // ------------------------------------------------
                  // HEADER
                  // ------------------------------------------------

                  const Text(
                    'Report a Civic Issue',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Help your community by reporting '
                    'a problem that needs attention.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ------------------------------------------------
                  // PROBLEM TITLE
                  // ------------------------------------------------

                  const Text(
                    'Problem Title',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: titleController,
                    textInputAction:
                        TextInputAction.next,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter the problem title',
                      prefixIcon: const Icon(
                        Icons.report_problem_outlined,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // CATEGORY
                  // ------------------------------------------------

                  const Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    initialValue: selectedCategory,
                    decoration:
                        InputDecoration(
                      prefixIcon: const Icon(
                        Icons.category_outlined,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                    items: categories
                        .map(
                          (String category) =>
                              DropdownMenuItem<
                                  String>(
                            value: category,
                            child: Text(
                              category,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged:
                        (String? value) {
                      if (value == null) return;

                      setState(() {
                        selectedCategory =
                            value;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // DESCRIPTION
                  // ------------------------------------------------

                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        descriptionController,
                    maxLines: 5,
                    textInputAction:
                        TextInputAction.newline,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Describe the issue in detail',
                      alignLabelWithHint: true,
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // LOCATION
                  // ------------------------------------------------

                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller:
                        locationController,
                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter the issue location',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                      ),
                      suffixIcon:
                          isGettingLocation
                              ? const Padding(
                                  padding:
                                      EdgeInsets.all(
                                    12,
                                  ),
                                  child:
                                      SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth:
                                          2,
                                    ),
                                  ),
                                )
                              : IconButton(
                                  tooltip:
                                      'Use current location',
                                  icon: const Icon(
                                    Icons
                                        .my_location,
                                  ),
                                  onPressed:
                                      getCurrentLocation,
                                ),
                      filled: true,
                      fillColor: Colors.white,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'You can enter the location manually '
                    'or use your current location.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ------------------------------------------------
                  // IMAGES
                  // ------------------------------------------------

                  const Text(
                    'Photos',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap:
                        showImageSourceOptions,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 16,
                      ),
                      decoration:
                          BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(
                          12,
                        ),
                        border: Border.all(
                          color:
                              Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons
                                .add_photo_alternate_outlined,
                            size: 42,
                            color:
                                Colors.blue.shade600,
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'Add Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Upload up to 5 images',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors
                                  .grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------------------------------------------------
                  // SELECTED IMAGES
                  // ------------------------------------------------

                  if (selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.separated(
                        scrollDirection:
                            Axis.horizontal,
                        itemCount:
                            selectedImages.length,
                        separatorBuilder:
                            (_, __) =>
                                const SizedBox(
                          width: 12,
                        ),
                        itemBuilder:
                            (context, index) {
                          final XFile image =
                              selectedImages[
                                  index];

                          return Stack(
                            children: [
                              FutureBuilder<
                                  Uint8List>(
                                future:
                                    image.readAsBytes(),
                                builder:
                                    (context,
                                        snapshot) {
                                  if (!snapshot
                                      .hasData) {
                                    return Container(
                                      width: 120,
                                      height: 120,
                                      decoration:
                                          BoxDecoration(
                                        color: Colors
                                            .grey
                                            .shade200,
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                      ),
                                      child:
                                          const Center(
                                        child:
                                            CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  return ClipRRect(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    child:
                                        Image.memory(
                                      snapshot
                                          .data!,
                                      width: 120,
                                      height: 120,
                                      fit: BoxFit.cover,
                                    ),
                                  );
                                },
                              ),

                              Positioned(
                                top: 6,
                                right: 6,
                                child:
                                    GestureDetector(
                                  onTap: () =>
                                      removeImage(
                                    index,
                                  ),
                                  child:
                                      Container(
                                    width: 28,
                                    height: 28,
                                    decoration:
                                        const BoxDecoration(
                                      color:
                                          Colors.black54,
                                      shape:
                                          BoxShape.circle,
                                    ),
                                    child:
                                        const Icon(
                                      Icons.close,
                                      size: 18,
                                      color:
                                          Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),

                  if (selectedImages.isNotEmpty)
                    const SizedBox(height: 8),

                  if (selectedImages.isNotEmpty)
                    Text(
                      '${selectedImages.length}/5 photos selected',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.grey.shade600,
                      ),
                    ),

                  const SizedBox(height: 32),

                  // ------------------------------------------------
                  // SUBMIT BUTTON
                  // ------------------------------------------------

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                          isSubmitting
                              ? null
                              : submitReport,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.blue.shade700,
                        foregroundColor:
                            Colors.white,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                      ),
                      child: isSubmitting
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .center,
                              children: [
                                Icon(
                                  Icons.send_outlined,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Submit Report',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ------------------------------------------------
                  // PROTOTYPE NOTE
                  // ------------------------------------------------

                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),
                    decoration:
                        BoxDecoration(
                      color:
                          Colors.blue.shade50,
                      borderRadius:
                          BorderRadius.circular(
                        12,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color:
                              Colors.blue.shade700,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Prototype mode: submitted '
                            'reports are displayed through '
                            'the success screen only. '
                            'Backend storage will be added later.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors
                                  .blue.shade900,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}