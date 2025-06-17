import 'dart:async';
import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  MqttService._();
  static late MqttClient client;
  static final StreamController<String> _messageStreamController = StreamController<String>.broadcast();
  static Stream<String> get messageStream => _messageStreamController.stream;

  static Future<void> initMqtt() async {
    var uuid = Uuid();
    String deviceId = uuid.v1();

    client = MqttServerClient("devices.iautobells.com", deviceId)
      ..port = 1883
      ..logging(on: false)
      ..keepAlivePeriod = 60
      ..onDisconnected = _onDisconnected
      ..onConnected = _onConnected
      ..onSubscribed = _onSubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..onUnsubscribed = _onUnsubscribed
      ..onBadCertificate = (Object cert) => true;

    client.connectionMessage = MqttConnectMessage()
        .authenticateAs('realiot', 'realmqtt@123')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce)
        .withClientIdentifier(deviceId);

    try {
      await client.connect();
    } catch (e) {
      log('[MQTT] Connection failed: $e');
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      _listen();
    }
  }

  static void _listen() {
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>>? messages) {
      final recMessage = messages![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
      _messageStreamController.add(payload);
    });
  }

  static void _onConnected() => log('[MQTT] Connected');
  static void _onDisconnected() => log('[MQTT] Disconnected');
  static void _onSubscribed(String? topic) => log('[MQTT] Subscribed: $topic');
  static void _onSubscribeFail(String? topic) => log('[MQTT] Subscribe failed: $topic');
  static void _onUnsubscribed(String? topic) => log('[MQTT] Unsubscribed: $topic');

  static void subscribeTopic(String topic) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  static void publish(String topic, String message, {bool retain = false}) {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final builder = MqttClientPayloadBuilder()..addString(message);
      client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!, retain: retain);
    }
  }

  static Future<void> disconnectMqtt() async {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.disconnect();
    }
  }
}
