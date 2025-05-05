abstract class LoginEvent {}

class SendOtpEvent extends LoginEvent {
  final String phone;
  SendOtpEvent(this.phone);
}

class VerifyOtpEvent extends LoginEvent {
  final String otp;
  VerifyOtpEvent(this.otp);
}

class ResendOtpEvent extends LoginEvent {}