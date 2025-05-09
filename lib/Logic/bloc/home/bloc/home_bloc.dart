import 'dart:async';
import 'dart:convert';
import 'dart:math';
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
  bool _mqttCheck = false;
  String _faulty = "";
  final Set<String> _mqttReceivedDeviceIds = {};

  DeviceBloc({required this.apiUrl, required this.storage}) : super(DeviceInitial()) {
    on<FetchDevices>(_onFetchDevices);
    on<SearchDevices>(_onSearchDevices);
    on<UpdateDeviceInfo>(_onUpdateDeviceInfo);
    on<RefreshMQTTData>(_onRefreshMQTTData);

    if (MqttService.client.updates != null) {
      mqttSubscription = MqttService.client.updates!.listen((c) {
        final recMess = c[0].payload as MqttPublishMessage;
        final payload = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

         try {
          final info = jsonDecode(payload);
          final mqttId = info['Device ID'];
          log('[MQTT] Received Device ID: $mqttId' as num); // 🔍

          add(UpdateDeviceInfo(
            deviceId: mqttId,
            swVersion: info['SW Version'],
            releaseDate: info['Release date'],
          ));
        } catch (e) {
          log('[MQTT] Failed to decode message: $e' as num);
        }
      });
    } else {
      mqttSubscription = Stream.empty().listen((_) {});
    }
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
        if (decoded is List) {
          _allDevices = decoded.map<DeviceModel>((e) => DeviceModel.fromJson(e)).toList();


          // 🔍 Print IMEI list
          for (var d in _allDevices) {
            log('[IMEI] ${d.deviceName} -> ${d.imei}' as num);
          }

          add(RefreshMQTTData());
          emit(DeviceLoaded(
            _allDevices,
            mqttCheck: _mqttCheck,
            faulty: _faulty,
            mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
          ));
        } else {
          emit(DeviceError("Unexpected response format"));
        }
      } else {
        emit(DeviceError("Failed to load devices: ${response.statusCode}"));
      }
    } catch (e) {
      emit(DeviceError("Failed to load devices: $e"));
    }
  }

  void _onSearchDevices(SearchDevices event, Emitter<DeviceState> emit) {
    final query = event.query.toLowerCase();
    final filteredDevices = _allDevices
        .where((device) => device.deviceName.toLowerCase().contains(query))
        .toList();
    emit(DeviceLoaded(
      filteredDevices,
      mqttCheck: _mqttCheck,
      faulty: _faulty,
      mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
    ));
  }

  void _onUpdateDeviceInfo(UpdateDeviceInfo event, Emitter<DeviceState> emit) {
    final normalizedId = event.deviceId.replaceFirst("IM_", "");
    print('[MATCH] Trying to match normalized Device ID: $normalizedId'); // 🔍

    _allDevices = _allDevices.map((device) {
      if (device.imei == normalizedId) {
        print('[MATCH ✅] Matched IMEI: ${device.imei}'); // ✅
        return device.copyWith(
          swVersion: event.swVersion,
          releaseDate: event.releaseDate,
        );
      }
      return device;
    }).toList();

    _mqttReceivedDeviceIds.add(normalizedId);

    emit(DeviceLoaded(
      _allDevices,
      mqttCheck: _mqttCheck,
      faulty: _faulty,
      mqttReceivedDeviceIds: _mqttReceivedDeviceIds.toList(),
    ));
  }

  Future<void> _onRefreshMQTTData(RefreshMQTTData event, Emitter<DeviceState> emit) async {
    final mqttClient = MqttService.client;

    if (mqttClient.connectionStatus?.state == MqttConnectionState.connected) {
      _mqttCheck = true;
      _faulty = "no";
    } else {
      if (mqttClient.connectionStatus?.state == MqttConnectionState.disconnected ||
          mqttClient.connectionStatus?.state == MqttConnectionState.faulted) {
        await MqttService.initMqtt();
      }
      _mqttCheck = false;
      _faulty = "yes";
    }

    for (DeviceModel device in _allDevices) {
      MqttService.subscribeTopic("${device.imei}/deviceInfo");
      MqttService.publish("${device.imei}/getDeviceInfo", jsonEncode({}));
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
