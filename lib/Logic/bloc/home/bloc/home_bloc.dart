import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:rimza1/Logic/bloc/home/bloc/home_event.dart';
import 'package:rimza1/Logic/bloc/home/bloc/home_state.dart';
import 'package:rimza1/data/user.dart';
import 'package:rimza1/service/mqtt.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  final String apiUrl;
  final GetStorage storage;
  late StreamSubscription mqttSubscription;
  List<DeviceModel> _allDevices = [];
  final Set<String> _mqttReceivedDeviceIds = {};
  bool _mqttCheck = false;
  String _faulty = "";

  DeviceBloc({required this.apiUrl, required this.storage}) : super(DeviceInitial()) {
    on<FetchDevices>(_onFetchDevices);
    on<SearchDevices>(_onSearchDevices);
    on<UpdateDeviceInfo>(_onUpdateDeviceInfo);
    on<RefreshMQTTData>(_onRefreshMQTTData);

    mqttSubscription = MqttService.messageStream.listen((payload) {
      try {
        final info = jsonDecode(payload);
        final id = info['Device ID'];
        final sw = info['SW Version'];
        final release = info['Release date'];

        log('[MQTT] Received Device ID: $id');

        add(UpdateDeviceInfo(deviceId: id, swVersion: sw, releaseDate: release));
      } catch (e) {
        log('[MQTT] Failed to decode: $e');
      }
    });
  }

  Future<void> _onFetchDevices(FetchDevices event, Emitter<DeviceState> emit) async {
    emit(DeviceLoading());

    final String? mobile = storage.read('mobile');
    if (mobile == null) {
      emit(DeviceError("Mobile number not found"));
      return;
    }

    final url = Uri.parse(apiUrl);
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {"action": "get_device", "mobile": mobile},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        _allDevices = List<DeviceModel>.from(decoded.map((e) => DeviceModel.fromJson(e)));

        for (var d in _allDevices) {
          log('[IMEI] ${d.deviceName} -> ${d.imei}');
        }

        add(RefreshMQTTData());

        emit(DeviceLoaded(
          _allDevices,
          mqttCheck: _mqttCheck,
          faulty: _faulty,
          mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
        ));
      } else {
        emit(DeviceError("Failed to fetch devices: ${response.statusCode}"));
      }
    } catch (e) {
      emit(DeviceError("Error: $e"));
    }
  }

  void _onSearchDevices(SearchDevices event, Emitter<DeviceState> emit) {
    final query = event.query.toLowerCase();
    final filtered = _allDevices.where((d) => d.deviceName.toLowerCase().contains(query)).toList();
    emit(DeviceLoaded(
      filtered,
      mqttCheck: _mqttCheck,
      faulty: _faulty,
      mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
    ));
  }

  void _onUpdateDeviceInfo(UpdateDeviceInfo event, Emitter<DeviceState> emit) {
    final deviceId = event.deviceId;

    log('[MATCH] Looking for match: $deviceId');

    _allDevices = _allDevices.map((device) {
      if (device.imei == deviceId) {
        _mqttReceivedDeviceIds.add(device.imei);
        return device.copyWith(
          swVersion: event.swVersion,
          releaseDate: event.releaseDate,
        );
      }
      return device;
    }).toList();

    emit(DeviceLoaded(
      _allDevices,
      mqttCheck: _mqttCheck,
      faulty: _faulty,
      mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
    ));
  }

  Future<void> _onRefreshMQTTData(RefreshMQTTData event, Emitter<DeviceState> emit) async {
    final mqtt = MqttService.client;

    if (mqtt.connectionStatus?.state != MqttConnectionState.connected) {
      await MqttService.initMqtt();
      _mqttCheck = false;
      _faulty = "yes";
    } else {
      _mqttCheck = true;
      _faulty = "no";
    }

    for (final d in _allDevices) {
      MqttService.subscribeTopic("${d.imei}/deviceInfo");
      MqttService.publish("${d.imei}/getDeviceInfo", jsonEncode({}));
    }

    emit(DeviceLoaded(
      _allDevices,
      mqttCheck: _mqttCheck,
      faulty: _faulty,
      mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
    ));
  }

  @override
  Future<void> close() {
    mqttSubscription.cancel();
    return super.close();
  }
}
