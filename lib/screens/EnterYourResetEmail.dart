import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mashrooa_takharog/auth/controllers/forget_password_controller.dart';
import 'package:mashrooa_takharog/screens/ForgotPasswordScreen.dart';
import 'package:mashrooa_takharog/widgets/customTextField.dart';

import '../widgets/customElevatedBtn.dart';

class EnterYourResetEmail extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    final controller=Get.put(ForgetPasswordController());
   return Scaffold(
     backgroundColor: Color(0xffF5F9FF),
     appBar: AppBar(
       leading: IconButton(onPressed: (){
         Navigator.pushReplacement(
           context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));},
           icon: Icon(CupertinoIcons.arrow_left,color: Colors.black,)),
       title: Text('Forgot Password',style: TextStyle(color: Color(0xff202244),fontFamily: 'Jost',fontSize: 21,fontWeight: FontWeight.w600),),
       backgroundColor:Color(0xffF5F9FF) ,

     ),
     body:
     Center(
       child: Column(
         children: [
           SizedBox(height: 30,),
           Padding(
             padding: const EdgeInsets.all(15.0),
             child: Text('Don\'t worry, sometimes people can forget too. Enter your email and we will send you a password reset link.',style: TextStyle(color: Color(0xff545454),fontSize: 14,fontFamily: 'Mulish',fontWeight: FontWeight.w800)
               ,),

           ),
           SizedBox(height: 30,),
Form(
  key: controller.forgetPasswordFormKey,
  child: TextFormField(
    controller: controller.email,
  validator: validateEmail,
  decoration: InputDecoration(labelText: 'Email',prefixIcon: Icon(Icons.email_outlined, color: Color(0xff545454))),

  ),
),
           SizedBox(height: 30,),

           CustomElevatedBtn(btnDesc: 'Submit',horizontalPad: 83,onPressed:  () => controller.sendPasswordResetEmail() ),


         ],

       ),
     ),

   );
  }

  static String? validateEmail(String? value){

    if(value==null||value.isEmpty){
        return 'Email is required!';

    }
    final emailRegExp=RegExp(r'^[^@\s]+@[^@\s]+\.(com|org|net|edu|gov)$');

    if(!emailRegExp.hasMatch(value)){
      return 'Invalid email address!';

    }

    return null;
  }



}