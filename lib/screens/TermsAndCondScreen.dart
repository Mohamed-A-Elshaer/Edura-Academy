import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mashrooa_takharog/screens/SignUpScreen.dart';

class TermsAndCondScreen extends StatelessWidget{
  final String termsAndConditions = '''
Terms and Conditions
Effective Date: 11/01/2025
Welcome to Edura! These Terms and Conditions (“Terms”) govern your access to and use of our mobile application, website, and services (collectively, the “Services”). By using the Edura platform, you agree to these Terms. If you do not agree, you may not use the Services.

1. Acceptance of Terms
By creating an account, accessing, or using the Services, you confirm that you:

Are at least 18 years old or have the permission of a parent or legal guardian if under 18.
Agree to abide by these Terms and all applicable laws and regulations.

2. User Accounts
2.1 Account Creation
You must provide accurate and complete information during the registration process.
You are responsible for maintaining the confidentiality of your account credentials.

2.2 Prohibited Activities
You agree not to:

Use false information during registration.
Share or transfer your account to any other person.
Use the Services for any unlawful purpose.

2.3 Termination of Accounts
We reserve the right to suspend or terminate your account for violating these Terms or engaging in fraudulent or harmful activities.

3. Services Offered
3.1 Students and Instructors
Students: Access courses, educational materials, and other resources.
Instructors: Provide and manage educational content.

3.2 Features
Secure account creation with email and OTP verification.
Profile completion for tailored educational experiences.
Access to content based on your selected role (student or instructor).

4. Payment and Subscriptions


4.1 Fees and Payments
Any applicable fees will be clearly displayed before purchase.
All payments are non-refundable unless stated otherwise.

4.2 Subscription Cancellation
Users may cancel subscriptions through their account settings.

5. Privacy Policy
Your use of the Services is governed by our Privacy Policy. We are committed to protecting your personal information and using it only as outlined in the policy.

6. User-Generated Content
Users are responsible for any content they upload or share on the platform, including but not limited to text, images, and videos. Edura does not endorse or take responsibility for user-generated content.

6.1 Prohibited Content
Harassment, hate speech, or discrimination.
Inappropriate or illegal material.

6.2 Content Moderation
We reserve the right to remove content that violates these Terms or is deemed inappropriate.

7. Intellectual Property
Edura and its related materials are protected by intellectual property laws. You may not copy, distribute, or modify our content without explicit permission.

8. Limitation of Liability
Edura is provided “as is” without any guarantees or warranties. We are not responsible for:

Any data loss or unauthorized access.
Errors, interruptions, or technical issues.
Damages resulting from the use or inability to use the Services.

9. Changes to Terms
We may update these Terms periodically. Users will be notified of significant changes through the app or via email. Continued use of the Services after changes indicates acceptance of the revised Terms.


11. Contact Us
For questions or concerns about these Terms, please contact us:

Email: ....

Acknowledgment
By using Edura, you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions.
''';
  @override
  Widget build(BuildContext context) {
   return Scaffold(
  backgroundColor: Color(0xffF5F9FF),
       appBar: AppBar(
         leading: IconButton(onPressed: (){Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>SignUpScreen()));},
             icon: Icon(CupertinoIcons.arrow_left,color: Colors.black,)),
         title: Text('Terms & conditions',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 21,fontWeight: FontWeight.w600),),
         backgroundColor:Color(0xffF5F9FF) ,

       ),
     body: SingleChildScrollView(child: Padding(
       padding: const EdgeInsets.all(12.0),
       child: Text(termsAndConditions,style: TextStyle(fontSize: 13,color:Color(0xff545454),fontWeight: FontWeight.w700),),
     )),

   );
  }


}