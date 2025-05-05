
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rimza1/Core/network.dart';
import 'package:rimza1/Logic/bloc/login/loginevent.dart';
import 'package:rimza1/Logic/bloc/login/loginstate.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final GetStorage storage = GetStorage();
  // final url = Uri.parse(login_url);
  final String apiUrl = login_url;

   LoginBloc() : super(LoginInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<ResendOtpEvent>(_onResendOtp);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<LoginState> emit) async {
    final phone = event.phone.trim();

    if (phone.isEmpty || phone.length != 10 || !RegExp(r'^\d{10}$').hasMatch(phone)) {
      emit(LoginFailure("Please enter a valid 10-digit mobile number"));
      return;
    }

    emit(LoginLoading());
     print('[SEND OTP] Request to: $apiUrl');
  print('[SEND OTP] Body: action=get_otp, mobile=${event.phone}');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          "action": "get_otp",
          "mobile": event.phone,
        },
      );

 print('[SEND OTP] Response Status: ${response.statusCode}');
    print('[SEND OTP] Raw Response: ${response.body}');


      final data = jsonDecode(response.body);
       print('[SEND OTP] Parsed Response: $data');
      if (data['status'] == 'success' && data['hash'] != null) {
        storage.write('otp_hash', data['hash']);
        storage.write('mobile', event.phone);
        emit(OtpSentState());
      } else {
        emit(LoginFailure(data['msg'] ?? 'OTP send failed'));
      }
    } catch (e) {
      emit(LoginFailure('Network error: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<LoginState> emit) async {
    final otp = event.otp.trim();
    
     if (otp.length != 6 || !RegExp(r'^\d{6}$').hasMatch(otp)) {
      emit(LoginFailure("Please enter a valid 6-digit OTP"));
      return;
    }

    final hash = storage.read('otp_hash');
    if (hash == null) {
      emit(LoginFailure("OTP session expired. Please request a new OTP."));
      return;
    }

    emit(LoginLoading());
  print('[VERIFY OTP] Request to: $apiUrl');
  print('[VERIFY OTP] Body: action=verify_otp, hash=$hash, otp=${event.otp}');


    try {
      // final hash = storage.read('otp_hash');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          "action": "verify_otp",
          "hash": hash,
          "otp": event.otp,
        },
      );

print('[VERIFY OTP] Response Status: ${response.statusCode}');
    print('[VERIFY OTP] Raw Response: ${response.body}');


      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        storage.write('isLoggedIn', true);
        emit(LoginSuccess());
      } else {
        emit(LoginFailure(data['msg'] ?? 'OTP verification failed'));
      }
    } catch (e) {
       print('[VERIFY OTP] ERROR: $e');
      emit(LoginFailure('Network error: ${e.toString()}'));
    }
  }

  Future<void> _onResendOtp(ResendOtpEvent event, Emitter<LoginState> emit) async {
    final phone = storage.read('mobile');
    if (phone == null) {
      emit(LoginFailure('Phone number not available'));
      return;
    }

    add(SendOtpEvent(phone));
  }
}