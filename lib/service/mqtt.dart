import 'dart:async';
import 'dart:developer';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  MqttService._();
  static late MqttClient client;

  static Future<void> initMqtt() async {
    var uuid = Uuid();
    String deviceId = uuid.v1();

    client = MqttServerClient("devices.iautobells.com", deviceId)
      ..logging(on: false)
      ..port = 1883
      ..keepAlivePeriod = 60
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed
      ..onConnected = _onConnected
      ..onUnsubscribed = _onUnsubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..onBadCertificate = (Object cert) => true;

    client.connectionMessage = MqttConnectMessage()
        .authenticateAs('realiot', 'realmqtt@123')
        .startClean()
        .withWillQos(MqttQos.exactlyOnce)
        .withClientIdentifier(deviceId)
        .withWillTopic('failed-Rimza')
        .withWillMessage('connection-failed-Rimza');

    await _connectMqtt();
  }

  static Future<void> _connectMqtt() async {
    try {
      log('[MQTT] Connecting...');
      await client.connect();
    } catch (e) {
      log('[MQTT] Connection failed: ${e.toString()}');
    }
    log('[MQTT] Final connection state: ${client.connectionStatus!.state}');
  }

  static void _onConnected() {
    log('[MQTT] Connected to broker');
  }

  static void _onDisconnected() {
    log('[MQTT] Disconnected. Status: ${client.connectionStatus?.state}');
  }

  static void _onSubscribed(String? topic) {
    log('[MQTT] Subscribed: $topic');
  }

  static void _onUnsubscribed(String? topic) {
    log('[MQTT] Unsubscribed: $topic');
  }

  static void _onSubscribeFail(String? topic) {
    log('[MQTT] Subscribe failed: $topic');
  }

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

  static void disconnectMqtt() {
    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      client.disconnect();
    }
  }

  static void reconnect() {
    Future.delayed(Duration(seconds: 3), () async {
      try {
        await client.connect();
      } catch (e) {
        log('[MQTT] Reconnect failed: $e');
      }
    });
  }
}
