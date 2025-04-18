import 'dart:io';
import 'package:appwrite/models.dart' as models;

import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/DisplayCourseLessons.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
//import 'package:flutter_credit_card/flutter_credit_card.dart';

import '../auth/Appwrite_service.dart';
import 'SpecificCategoryPage.dart';

class Coursedetailscreen extends StatefulWidget {
  const Coursedetailscreen(
      {super.key,
      required this.category,
      required this.imagePath,
      required this.title,
      required this.courseId,
      required this.price,
      required this.instructorName});
  final String category;
  final String imagePath;
  final String title;
  final String courseId;
  final String price;
  final String instructorName;

  @override
  State<Coursedetailscreen> createState() => _CoursedetailscreenState();
}

class _CoursedetailscreenState extends State<Coursedetailscreen> {
  int videoCount = 0;
  int courseDuration = 0;
  bool _showCuric = false;
  bool _showFullText = false;
  String courseDescription = '';
  bool _isDescriptionOverflowing = false;
  String _trimmedDescription = '';
  String instructorMajor = '';
  String? avatarUrl;
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> sections = [];
  bool _isPurchased = false;
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  String? cardNumberError;
  String? expiryDateError;
  String? cvvError;
  String? cardHolderNameError;

  @override
  void initState() {
    super.initState();
    _fetchVideoCount();
    _fetchCourseDuration();
    _fetchCourseDescription();
    _fetchInstructorMajor();
    fetchInstructorProfAvatar();
    fetchSectionsAndVideos();
    _checkPurchaseStatus();
  }

  Future<void> fetchSectionsAndVideos() async {
    try {
      // ✅ Fetch course details from Appwrite database
      final course = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      List<String> sectionNames = List<String>.from(course.data['sections']);
      List<String> sectionDurations =
          List<String>.from(course.data['section_durations']);
      List<String> videoTitlesFromDb =
          List<String>.from(course.data['videos'] ?? []);

      List<Map<String, dynamic>> fetchedSections = [];

      for (int i = 0; i < sectionNames.length; i++) {
        String rawSection = sectionNames[i];
        String sectionTitle = rawSection.replaceFirst(RegExp(r'^\d+-\s*'), '');
        String duration =
            (i < sectionDurations.length) ? sectionDurations[i] : "0 Mins";

        // ✅ Fetch all files from Appwrite Storage for this section
        final files = await Appwrite_service.storage.listFiles(
          bucketId: '67ac838900066b15fc99',
          queries: [
            Query.startsWith(
              'name',
              '${widget.title.replaceAll(' ', '')}/${rawSection.replaceAll(' ', '')}',
            ),
          ],
        );

        List<Map<String, dynamic>> lessons = [];
        int lessonNumber = 1;

        for (String dbVideoTitle in videoTitlesFromDb) {
          // ✅ Extract filename (e.g., '01- Introduction to Flutter')
          String dbVideoNameOnly = dbVideoTitle
              .trim()
              .split('/')
              .last
              .replaceAll('.mp4', '')
              .toLowerCase();

          // ✅ Try to find matching file in storage
          models.File? matchedFile;
          for (var file in files.files) {
            if (!file.name.endsWith('.mp4')) continue;

            String storageFileName =
                file.name.split('/').last.replaceAll('.mp4', '');
            String normalizedStorage =
                storageFileName.replaceAll('_', ' ').toLowerCase().trim();

            if (normalizedStorage == dbVideoNameOnly) {
              matchedFile = file;
              break;
            }
          }

          if (matchedFile != null) {
            String videoUrl =
                'https://cloud.appwrite.io/v1/storage/buckets/67ac838900066b15fc99/files/${matchedFile.$id}/view?project=67ac8356002648e5b7e9';

            lessons.add({
              'number': lessonNumber.toString().padLeft(2, '0'),
              'title': dbVideoTitle.replaceAll('.mp4', ''),
              'videoId': matchedFile.$id,
              'videoUrl': videoUrl,
              'filePath': matchedFile.name,
            });

            lessonNumber++;
          }
        }

        fetchedSections.add({
          'title': sectionTitle,
          'duration': duration,
          'lessons': lessons,
        });
      }

      setState(() {
        sections = fetchedSections;
      });
    } catch (e) {
      print('❌ Error fetching sections and videos: $e');
    }
  }

  Future<void> fetchInstructorProfAvatar() async {
    try {
      // Step 1: Get course data from Appwrite
      final courseDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046', // replace
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      final instructorId = courseDoc.data['instructor_id'];

      // Step 2: Get instructor data using instructorId
      final instructorDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: instructorId,
      );

      final email = instructorDoc.data['email'];
      instructorMajor = instructorDoc.data['major'] ?? '';

      // Step 3: Search for instructor in Supabase using email
      final response = await supabase
          .from('users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (response == null) throw Exception('Instructor not found in Supabase');

      final supabaseId = response['id'];
      final imagePath = '$supabaseId/profile';

      // Step 4: Get the public URL of the image
      String url = supabase.storage.from('profiles').getPublicUrl(imagePath);

      // Step 5: Add a timestamp to force refresh
      url = Uri.parse(url).replace(queryParameters: {
        't': DateTime.now().millisecondsSinceEpoch.toString()
      }).toString();

      setState(() {
        avatarUrl = url;
      });
    } catch (e) {
      print('❌ Error: $e');
      setState(() {
        avatarUrl = null;
      });
    }
  }

  Future<void> _fetchVideoCount() async {
    try {
      final courseDocument = await Appwrite_service.databases.getDocument(
        databaseId:
            '67c029ce002c2d1ce046', // Replace with your actual database ID
        collectionId:
            '67c1c87c00009d84c6ff', // Replace with your actual collection ID
        documentId:
            widget.courseId, // Use the courseId to fetch the specific course
      );

      List<dynamic> videos = courseDocument.data['videos'] ?? [];
      setState(() {
        videoCount = videos.length;
      });
    } catch (e) {
      print('Error fetching video count: $e');
    }
  }

  Future<void> _fetchCourseDuration() async {
    try {
      final courseDocument = await Appwrite_service.databases.getDocument(
        databaseId:
            '67c029ce002c2d1ce046', // Replace with your actual database ID
        collectionId:
            '67c1c87c00009d84c6ff', // Replace with your actual collection ID
        documentId:
            widget.courseId, // Use the courseId to fetch the specific course
      );

      setState(() {
        courseDuration = courseDocument.data['courseDuration_inMins'] ?? 0;
      });
    } catch (e) {
      print('Error fetching course duration: $e');
    }
  }

  Future<void> _fetchCourseDescription() async {
    try {
      final courseDocument = await Appwrite_service.databases.getDocument(
        databaseId:
            '67c029ce002c2d1ce046', // Replace with your actual database ID
        collectionId:
            '67c1c87c00009d84c6ff', // Replace with your actual collection ID
        documentId:
            widget.courseId, // Use the courseId to fetch the specific course
      );

      setState(() {
        courseDescription = courseDocument.data['description'] ??
            ''; // Retrieve the course description
        _checkDescriptionOverflow();
      });
    } catch (e) {
      print('Error fetching course description: $e');
    }
  }

  void _checkDescriptionOverflow() {
    final span = TextSpan(
      text: courseDescription,
      style: const TextStyle(fontSize: 14),
    );

    final tp = TextPainter(
      maxLines: 2,
      textAlign: TextAlign.start,
      textDirection: TextDirection.ltr,
      text: span,
    );

    tp.layout(
        maxWidth:
            MediaQuery.of(context).size.width - 64); // padding 16 * 2 + margin

    if (tp.didExceedMaxLines) {
      _isDescriptionOverflowing = true;

      // نختصر الوصف:
      if (courseDescription.length > 50) {
        _trimmedDescription = courseDescription.substring(0, 188) + '...';
      } else {
        _trimmedDescription = courseDescription;
      }
    } else {
      _isDescriptionOverflowing = false;
      _trimmedDescription = courseDescription;
    }
  }

  Future<void> _fetchInstructorMajor() async {
    try {
      // Step 1: Get course document using courseId
      final courseDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c1c87c00009d84c6ff',
        documentId: widget.courseId,
      );

      final String instructorId = courseDoc.data['instructor_id'];

      // Step 2: Get instructor's user document using instructor_id
      final instructorDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: instructorId,
      );

      setState(() {
        instructorMajor = instructorDoc.data['major'] ?? '';
      });
    } catch (e) {
      print('Error fetching instructor major: $e');
      setState(() {
        instructorMajor = '';
      });
    }
  }

  Future<void> _checkPurchaseStatus() async {
    try {
      // Get current user
      final currentUser = await Appwrite_service.account.get();

      // Get user's document from database
      final userDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
      );

      // Check if course is in purchased_courses array
      List<String> purchasedCourses =
          List<String>.from(userDoc.data['purchased_courses'] ?? []);

      setState(() {
        _isPurchased = purchasedCourses.contains(widget.title);
      });
    } catch (e) {
      print('Error checking purchase status: $e');
    }
  }

  Future<void> _processPurchase() async {
    try {
      // Get current user
      final currentUser = await Appwrite_service.account.get();

      // Get user's document
      final userDoc = await Appwrite_service.databases.getDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
      );

      // Get existing purchased courses or initialize empty list
      List<String> purchasedCourses =
          List<String>.from(userDoc.data['purchased_courses'] ?? []);

      // Add new course to the list
      purchasedCourses.add(widget.title);

      // Update user document with new purchased courses list
      await Appwrite_service.databases.updateDocument(
        databaseId: '67c029ce002c2d1ce046',
        collectionId: '67c0cc3600114e71d658',
        documentId: currentUser.$id,
        data: {
          'purchased_courses': purchasedCourses,
          'ongoing_courses': purchasedCourses
        },
      );

      setState(() {
        _isPurchased = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course purchased successfully!')),
      );
    } catch (e) {
      print('Error processing purchase: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error processing purchase. Please try again.')),
      );
    }
  }

  bool _validateCardNumber(String value) {
    if (value.isEmpty) {
      return false;
    }
    // Remove any spaces from the card number
    String cleanNumber = value.replaceAll(' ', '');
    // Check if it's all digits and 16 characters long
    return RegExp(r'^\d{16}$').hasMatch(cleanNumber);
  }

  bool _validateExpiryDate(String value) {
    if (value.isEmpty) {
      return false;
    }
    // Check format MM/YY
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return false;
    }

    // Extract month and year
    List<String> parts = value.split('/');
    int month = int.parse(parts[0]);
    int year = int.parse(parts[1]);

    // Get current date
    DateTime now = DateTime.now();
    int currentYear = now.year % 100;
    int currentMonth = now.month;

    // Validate month (1-12)
    if (month < 1 || month > 12) {
      return false;
    }

    // Validate year (not expired)
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return false;
    }

    return true;
  }

  bool _validateCVV(String value) {
    return RegExp(r'^\d{3}$').hasMatch(value);
  }

  bool _validateCardHolderName(String value) {
    return value.isNotEmpty && RegExp(r'^[a-zA-Z\s]+$').hasMatch(value);
  }

  void _validateForm() {
    setState(() {
      cardNumberError = _validateCardNumber(cardNumber)
          ? null
          : 'Please enter a valid 16-digit card number';
      expiryDateError = _validateExpiryDate(expiryDate)
          ? null
          : 'Please enter a valid expiry date (MM/YY)';
      cvvError =
          _validateCVV(cvvCode) ? null : 'Please enter a valid 3-digit CVV';
      cardHolderNameError = _validateCardHolderName(cardHolderName)
          ? null
          : 'Please enter a valid name (letters only)';
    });
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Card Number Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Number',
                      hintText: 'XXXX XXXX XXXX XXXX',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.credit_card),
                      errorText: cardNumberError,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 16,
                    onChanged: (value) {
                      setState(() {
                        cardNumber = value.replaceAll(' ', '');
                        _validateForm();
                      });
                    },
                    validator: (value) {
                      if (!_validateCardNumber(value ?? '')) {
                        return 'Please enter a valid 16-digit card number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Expiry Date and CVV Row
                  Row(
                    children: [
                      // Expiry Date Field
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Expiry Date',
                            hintText: 'MM/YY',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today),
                            errorText: expiryDateError,
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          onChanged: (value) {
                            if (value.length == 2 && !value.contains('/')) {
                              setState(() {
                                expiryDate = value + '/';
                                _validateForm();
                              });
                            } else {
                              setState(() {
                                expiryDate = value;
                                _validateForm();
                              });
                            }
                          },
                          validator: (value) {
                            if (!_validateExpiryDate(value ?? '')) {
                              return 'Please enter a valid expiry date (MM/YY)';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      // CVV Field
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'CVV',
                            hintText: 'XXX',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.security),
                            errorText: cvvError,
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Colors.red),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          maxLength: 3,
                          obscureText: true,
                          onChanged: (value) {
                            setState(() {
                              cvvCode = value;
                              _validateForm();
                            });
                          },
                          validator: (value) {
                            if (!_validateCVV(value ?? '')) {
                              return 'Please enter a valid 3-digit CVV';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card Holder Name Field
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Card Holder Name',
                      hintText: 'Name as shown on card',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.person),
                      errorText: cardHolderNameError,
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) {
                      setState(() {
                        cardHolderName = value;
                        _validateForm();
                      });
                    },
                    validator: (value) {
                      if (!_validateCardHolderName(value ?? '')) {
                        return 'Please enter a valid name (letters only)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Payment Summary
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Summary',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Course Price:'),
                            Text('EGP ${widget.price}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Pay Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        _validateForm();
                        if (formKey.currentState?.validate() ?? false) {
                          Navigator.pop(context);
                          _processPurchase();
                        }
                      },
                      child: Text(
                        'Pay EGP ${widget.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Course Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to SpecificCategoryPage with the category
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    SpecificCategoryPage(category: widget.category),
              ),
            );
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Image.network(
                widget.imagePath,
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
              ),
              Positioned(
                bottom: -20,
                right: 16,
                child: CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF167F71),
                  child: _isPurchased
                      ? IconButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => DisplayCourseLessons(
                                        title: widget.title,
                                        courseId: widget.courseId)));
                          },
                          icon:
                              const Icon(Icons.play_arrow, color: Colors.white))
                      : IconButton(
                          onPressed: null,
                          icon: const Icon(Icons.lock, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Container(
            margin: const EdgeInsets.only(top: 25),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 18,
                        ),
                        Text(
                          '4.2',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.class_rounded,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$videoCount Class',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '|',
                      style: TextStyle(fontSize: 14),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$courseDuration Minutes',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'EGP ${widget.price}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showCuric = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !_showCuric ? Colors.teal : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('About',
                              style: TextStyle(
                                  color: !_showCuric
                                      ? Colors.white
                                      : Colors.black)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _showCuric = true;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                _showCuric ? Colors.teal : Colors.grey[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Curriculum',
                              style: TextStyle(
                                  color: _showCuric
                                      ? Colors.white
                                      : Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!_showCuric) ...[
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _showFullText ? courseDescription : _trimmedDescription,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                if (_isDescriptionOverflowing)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showFullText = !_showFullText;
                      });
                    },
                    child: Text(
                      _showFullText ? 'Read less' : 'Read more',
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 13),
            const Text(
              "Instructor",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? Icon(Icons.person_outline,
                          color: Colors.grey[400], size: 30)
                      : null,
                ),
                const SizedBox(
                    width: 12), // Gives space between avatar and text
                Expanded(
                  // Ensures text takes only available space
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Keeps text aligned left
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.instructorName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        instructorMajor,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(
              thickness: 0.3,
              color: Colors.grey,
              height: 36,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What You\'ll Get',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.book, size: 24, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('$videoCount Lessons'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.devices, size: 24, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Access Mobile, Desktop & TV'),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 24, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Lifetime Access'),
                    ],
                  ),
                  SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Reviews',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ReviewCard(
              name: 'Will',
              review:
                  'This course has been very useful. Mentor was well spoken totally tuned.',
              timeAgo: '2 Weeks Ago',
              rating: 4.3,
            ),
            const SizedBox(height: 8),
            ReviewCard(
              name: 'Martha E. Thompson',
              review:
                  'This course has been very useful. Mentor was well spoken totally tuned in for live sessions.',
              timeAgo: '2 Weeks Ago',
              rating: 4.8,
            ),
          ],
          if (_showCuric) ...[
            const SizedBox(height: 16),
            Container(
              height: 400,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = sections[sectionIndex];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            section['title'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            section['duration'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: (section['lessons'] as List).length,
                        itemBuilder: (context, lessonIndex) {
                          final lesson = section['lessons'][lessonIndex];
                          return _buildLessonTile(
                            lesson['number'],
                            lesson['title'].toString().substring(4),
                            isPurchased: _isPurchased,
                            onTap: _isPurchased
                                ? () {
                                    // Handle video playback when purchased
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DisplayCourseLessons(
                                          title: widget.title,
                                          courseId: widget.courseId,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isPurchased ? null : _showPaymentSheet,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
              backgroundColor: Colors.blue,
            ),
            child: Text(
              _isPurchased ? 'Enrolled' : 'Enroll Course EGP ${widget.price}',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  final String name;
  final String review;
  final String timeAgo;
  final double rating;

  ReviewCard({
    required this.name,
    required this.review,
    required this.timeAgo,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage("assets/images/mentor.jpg"),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  review,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.yellow, size: 20),
                    Text(' $rating', style: const TextStyle(fontSize: 16)),
                    const Spacer(),
                    Text(timeAgo, style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildLessonTile(String lessonNumber, String lessonTitle,
    {bool isPurchased = false, VoidCallback? onTap}) {
  String displayTitle = lessonTitle;
  if (lessonTitle.length > 30) {
    displayTitle = lessonTitle.substring(0, 27) + '...';
  }
  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    elevation: 2,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isPurchased ? Colors.blue : Colors.grey,
                  child: Text(
                    lessonNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  displayTitle,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isPurchased ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            if (!isPurchased)
              const Icon(
                Icons.lock,
                color: Colors.grey,
                size: 20,
              ),
          ],
        ),
      ),
    ),
  );
}
