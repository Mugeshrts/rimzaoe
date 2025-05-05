import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:pinput/pinput.dart';
import 'package:rimza1/Logic/bloc/login/loginbloc.dart';
import 'package:rimza1/Logic/bloc/login/loginevent.dart';
import 'package:rimza1/Logic/bloc/login/loginstate.dart';
import 'package:rimza1/presentation/Screens/home.dart';



class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginBloc(),
      child: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
          if (state is LoginSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("OTP Verified Successfully"), backgroundColor: Colors.green),
            );
            Get.offAll(() => DashboardPage());
          }
        },
        builder: (context, state) {
          final isOtpScreen = state is OtpSentState;
          final isLoading = state is LoginLoading;

         return Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/loginvector.png', height: 180),
                    SizedBox(height: 20),
                    isOtpScreen
                        ? _buildOtpUI(context, isLoading)
                        : _buildPhoneInputUI(context, isLoading),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneInputUI(BuildContext context, bool isLoading) {
    return Column(
      children: [
        Text("Enter Your Mobile Number", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text("We will send you a confirmation code", style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        SizedBox(height: 24),
        IntlPhoneField(
          controller: phoneController,
          decoration: InputDecoration(
            // labelText: "Phone number",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          initialCountryCode: "IN",
        ),
        SizedBox(height: 24),
        isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                style: _buttonStyle(),
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context).add(SendOtpEvent(phoneController.text));
                },
                child: Text("Get OTP", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
      ],
    );
  }

  Widget _buildOtpUI(BuildContext context, bool isLoading) {
    String obfuscated = phoneController.text.length >= 10
        ? '******${phoneController.text.substring(6)}'
        : '***';

    return Column(
      children: [
        Text("Enter Verification Code", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text("A 6-digit code has been sent to $obfuscated", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 24),
        Pinput(
          controller: otpController,
          length: 6,
          keyboardType: TextInputType.number,
          defaultPinTheme: PinTheme(
            width: 56,
            height: 56,
            textStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue),
            ),
          ),
        ),
        SizedBox(height: 24),
        isLoading
            ? CircularProgressIndicator()
            : ElevatedButton(
                style: _buttonStyle(),
                onPressed: () {
                  BlocProvider.of<LoginBloc>(context).add(VerifyOtpEvent(otpController.text));
                },
                child: Text("Verify", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
        TextButton(
          onPressed: () {
            BlocProvider.of<LoginBloc>(context).add(ResendOtpEvent());
          },
          child: Text("RESEND OTP", style: TextStyle(color: Colors.blue)),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue.shade900,
      padding: EdgeInsets.symmetric(vertical: 14),
      minimumSize: Size(double.infinity, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    );
  }
}
