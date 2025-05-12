import 'package:equatable/equatable.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object> get props => [];
}

class FetchDevices extends DeviceEvent {}

class SearchDevices extends DeviceEvent {
  final String query;

  const SearchDevices(this.query);

  @override
  List<Object> get props => [query];
}

class RefreshMQTTData extends DeviceEvent {}

class UpdateDeviceInfo extends DeviceEvent {
  final String deviceId;
  final String swVersion;
  final String releaseDate;

  const UpdateDeviceInfo({
    required this.deviceId,
    required this.swVersion,
    required this.releaseDate,
  });

  @override
  List<Object> get props => [deviceId, swVersion, releaseDate];
}