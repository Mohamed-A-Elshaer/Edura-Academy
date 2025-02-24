import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../widgets/customElevatedBtn.dart';
import '../widgets/customTextField.dart';
import 'InstructorNavigatorScreen.dart';
import 'StudentNavigatorScreen.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController nickNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  String selectedGender = 'Gender';
  DateTime dateTime = DateTime.now();
  String? emailError, phoneError;
  String? verificationId;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  void _navigateBasedOnUserType(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      // ✅ Fetch user by UID instead of email
      var studentSnapshot =
          await firestore.collection('students').doc(user.uid).get();
      if (studentSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NavigatorScreen()),
        );
        return;
      }

      var instructorSnapshot =
          await firestore.collection('instructors').doc(user.uid).get();
      if (instructorSnapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => InstructorNavigatorScreen()),
        );
        return;
      }
    } catch (e) {
      print("❌ Error checking user role: $e");
    }
  }

  Future<void> _verifyAndUpdatePhoneNumber(String formattedPhone,
      String collection, String docId, String newEmail) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Waiting for phone verification...'),
            duration: Duration(seconds: 7)),
      );

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _auth.currentUser!.updatePhoneNumber(credential);
            await _updateFirestoreAndAuth(
                collection, docId, newEmail, formattedPhone);
          } catch (e) {
            print('Error auto-verifying phone number: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Phone verification failed: $e');
          setState(() {
            phoneError = '*Phone verification failed. Please try again.';
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          _showOtpDialog(
              verificationId, formattedPhone, collection, docId, newEmail);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            this.verificationId = verificationId;
          });
        },
      );
    } catch (e) {
      print('Error during phone verification: $e');
      setState(() {
        phoneError = '*Failed to verify phone number.';
      });
    }
  }

  void _showOtpDialog(String verificationId, String formattedPhone,
      String collection, String docId, String newEmail) {
    final TextEditingController otpController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter OTP'),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'OTP'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                final PhoneAuthCredential phoneCredential =
                    PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: otpController.text,
                );

                await _auth.currentUser!.updatePhoneNumber(phoneCredential);
                Navigator.of(context).pop();

                await _updateFirestoreAndAuth(
                    collection, docId, newEmail, formattedPhone);
              } catch (e) {
                print('OTP verification failed: $e');
                setState(() {
                  phoneError = '*Failed to verify OTP. Try again.';
                });
                Navigator.of(context).pop();
              }
            },
            child: const Text('Verify'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateFirestoreAndAuth(
      String collection, String docId, String newEmail, String newPhone) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    Map<String, dynamic> updatedData = {};
    if (fullNameController.text.isNotEmpty)
      updatedData['fullName'] = fullNameController.text;
    if (nickNameController.text.isNotEmpty)
      updatedData['nickName'] = nickNameController.text;
    if (dobController.text.isNotEmpty) updatedData['dob'] = dobController.text;
    if (newEmail.isNotEmpty && newEmail != user.email)
      updatedData['email'] = newEmail;
    if (newPhone.isNotEmpty) {
      updatedData['phone'] =
          newPhone.startsWith('+2') ? newPhone.substring(2) : newPhone;
    }
    if (selectedGender != 'Gender') updatedData['gender'] = selectedGender;

    try {
      if (updatedData.isNotEmpty) {
        await firestore.collection(collection).doc(docId).update(updatedData);

        // Update email in Firebase Authentication
        if (newEmail.isNotEmpty && newEmail != user.email) {
          try {
            await user.updateEmail(newEmail);
            print("✅ Firebase Auth email updated successfully!");
          } on FirebaseAuthException catch (e) {
            if (e.code == 'requires-recent-login') {
              print("⚠️ User needs to re-authenticate to update email.");
            } else {
              print("❌ Error updating email in Firebase Auth: $e");
            }
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Waiting for update...'),
              duration: Duration(seconds: 2)),
        );

        setState(() {
          fullNameController.clear();
          nickNameController.clear();
          dobController.clear();
          emailController.clear();
          phoneController.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Profile updated successfully!'),
              duration: Duration(seconds: 2)),
        );

        // ✅ Force FirebaseAuth to refresh the user
        await FirebaseAuth.instance.currentUser?.reload();
        user = FirebaseAuth.instance.currentUser; // Refresh user session
        print("🔄 Updated email: ${user?.email}"); // Debugging log

        // ✅ Navigate after updating the user
        Future.delayed(const Duration(seconds: 1), () {
          _navigateBasedOnUserType(context);
        });
      }
    } catch (e) {
      print("❌ Error updating profile: $e");
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user == null) return;

    String newEmail = emailController.text.trim();
    String newPhone = phoneController.text.trim();
    String formattedPhone = newPhone.isNotEmpty ? '+2$newPhone' : "";
    bool isDataEntered = fullNameController.text.isNotEmpty ||
        nickNameController.text.isNotEmpty ||
        dobController.text.isNotEmpty ||
        newEmail.isNotEmpty ||
        newPhone.isNotEmpty ||
        selectedGender != 'Gender';

    if (!isDataEntered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter data to update your profile!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    String userId = user.uid;
    String? collection;
    DocumentSnapshot? userDoc;

    try {
      // Determine if the user is a student or instructor
      String userId = user.uid; // ✅ استخدم الـ UID لأنه ثابت
      DocumentSnapshot? userDoc;
      String? collection;

// ✅ جلب الوثيقة مباشرة باستخدام الـ UID
      DocumentSnapshot studentDoc =
          await firestore.collection('students').doc(userId).get();
      if (studentDoc.exists) {
        collection = 'students';
        userDoc = studentDoc;
      }

      DocumentSnapshot instructorDoc =
          await firestore.collection('instructors').doc(userId).get();
      if (instructorDoc.exists) {
        collection = 'instructors';
        userDoc = instructorDoc;
      }

      if (collection == null || userDoc == null) {
        print("User not found in either collection.");
        return;
      }

      // Prevent updating to an already existing email
      if (newEmail.isNotEmpty && newEmail != user.email) {
        QuerySnapshot existingEmail = await firestore
            .collection('students')
            .where('email', isEqualTo: newEmail)
            .get();
        existingEmail = existingEmail.docs.isEmpty
            ? await firestore
                .collection('instructors')
                .where('email', isEqualTo: newEmail)
                .get()
            : existingEmail;

        if (existingEmail.docs.isNotEmpty) {
          setState(() {
            emailError = '*Email already exists!';
          });
          return;
        }
      }

      // Prevent updating to an already existing phone number
      if (newPhone.isNotEmpty && newPhone != userDoc.get('phone')) {
        QuerySnapshot existingPhone = await firestore
            .collection('students')
            .where('phone', isEqualTo: newPhone)
            .get();
        existingPhone = existingPhone.docs.isEmpty
            ? await firestore
                .collection('instructors')
                .where('phone', isEqualTo: newPhone)
                .get()
            : existingPhone;

        if (existingPhone.docs.isNotEmpty) {
          setState(() {
            phoneError = '*Phone number already exists!';
          });
          return;
        }

        // Trigger phone verification before updating the phone number
        await _verifyAndUpdatePhoneNumber(
            formattedPhone, collection, userDoc.id, newEmail);
        return; // Stop execution until phone is verified
      }

      // Update only modified fields
      await _updateFirestoreAndAuth(collection, userDoc.id, newEmail,
          newPhone.isNotEmpty ? newPhone : userDoc.get('phone'));
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  Future<Null> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: dateTime,
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(1920),
        lastDate: DateTime(2101));
    if (picked != null && picked != dateTime) {
      setState(() {
        dateTime = picked;
        dobController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F9FF),
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => _navigateBasedOnUserType(context)),
        title: const Text('Edit Profile'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Transform(
            transform: Matrix4.translationValues(0, -10, 0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  child: Image.asset(
                    'assets/images/ProfilePic.png',
                    height: 65,
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                CustomTextField(
                  hintText: 'Full Name',
                  isPrefix: false,
                  hpad: 20,
                  isSuffix: false,
                  controller: fullNameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: 'Nick Name',
                  isPrefix: false,
                  hpad: 20,
                  isSuffix: false,
                  controller: nickNameController,
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: 'Date of Birth',
                  isPrefix: true,
                  prefix: const Icon(Icons.calendar_month_outlined),
                  isSuffix: false,
                  onTap: () => _selectDate(context),
                  controller: dobController,
                  readOnly: true,
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      hintText: 'Email',
                      isPrefix: true,
                      prefix: const Icon(Icons.email_outlined),
                      isSuffix: false,
                      controller: emailController,
                    ),
                    if (emailError != null) // 🔹 Show email error message
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5),
                        child: Text(
                          emailError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      hintText: 'Phone',
                      isPrefix: true,
                      prefix: const Icon(Icons.phone_android),
                      isSuffix: false,
                      cursorHeight: 15,
                      controller: phoneController,
                    ),
                    if (phoneError != null) // 🔹 Show phone error message
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, top: 5),
                        child: Text(
                          phoneError!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomTextField(
                  hintText: selectedGender,
                  isPrefix: false,
                  readOnly: true,
                  hpad: 20,
                  isSuffix: true,
                  dropdownItems: const ['Male', 'Female'],
                  onDropdownChanged: (value) {
                    setState(() {
                      if (value != null) {
                        selectedGender = value;
                      }
                    });
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                CustomElevatedBtn(
                    btnDesc: 'Update',
                    horizontalPad: 75,
                    onPressed: () => _updateProfile())
              ],
            ),
          ),
        ),
      ),
    );
  }
}
