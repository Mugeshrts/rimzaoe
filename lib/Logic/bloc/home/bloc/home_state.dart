import 'package:equatable/equatable.dart';
import 'package:rimza1/data/user.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DeviceLoaded extends DeviceState {
  final List<DeviceModel> devices;
  final bool mqttCheck;
  final String faulty;
  final List<String> mqttReceivedDeviceIds;

  const DeviceLoaded(
    this.devices, {
    required this.mqttCheck,
    required this.faulty,
    this.mqttReceivedDeviceIds = const [],
  });

  @override
  List<Object> get props => [devices, mqttCheck, faulty, mqttReceivedDeviceIds];
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError(this.message);

  @override
  List<Object> get props => [message];
}
