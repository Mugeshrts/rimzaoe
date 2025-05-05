import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math'hide log;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
class MqttService{
  MqttService._();
  static late MqttClient client;

  static StreamSubscription? mqttListen;


  static Future<void> initMqtt() async {
       var uuid = Uuid();
        String? deviceId = uuid.v1();
   
    client = MqttServerClient("devices.iautobells.com","$deviceId")
      ..logging(on: false)
      ..port = 1883
      ..keepAlivePeriod = 60
      ..onDisconnected = _onDisconnected
      ..onSubscribed = _onSubscribed
      ..onConnected = _onConnected
      ..onUnsubscribed = _onUnsubscribed
      ..onSubscribeFail = _onSubscribeFail
      ..onBadCertificate=(dynamic a)=>true;
     

    final mqttMsg = MqttConnectMessage()
        .authenticateAs('realiot', 'realmqtt@123')
        .withWillMessage('connection-failed-Rimza')
        // .withWillTopic('willTopic')
        .startClean()
        .withWillQos(MqttQos.exactlyOnce)
        // .withWillQos(MqttQos.atMostOnce)
        .withClientIdentifier("$deviceId")
        .withWillTopic('failed-Rimza');
    client.connectionMessage = mqttMsg;

    await _connectMqtt();
    
  }


  /// Mqtt server connected.
  static void _onConnected() {
    log('[MQTT] Connected to broker');
    log('[MQTT] Client Status: ${client.connectionStatus}');
    _listenMqtt();
  }

  /// Mqtt server disconnected
  static void _onDisconnected() {
   final status = client.connectionStatus;
  log('[MQTT] Disconnected from broker');
  log('[MQTT] Disconnect Reason: ${status?.disconnectionOrigin}');
  log('[MQTT] Connection Status: ${status?.state}');
  }

  /// Mqtt server subscribed
  static void _onSubscribed(String? topic) {
    log('Subscribed topic is : $topic');
  }

  static void _onUnsubscribed(String? topic) {
    log('Unsubscribed topic is : $topic');
  }

  static void _onSubscribeFail(String? topic) {
    log('Failed subscribe topic : $topic');
  }


  /// Connection MQTT Server.
  static Future<void> _connectMqtt() async {

    if (client.connectionStatus!.state != MqttConnectionState.connected) {
      try {
        log('[MQTT] Connecting...');
        await client.connect();
      } catch (e) {
        log('[MQTT] Connection failed: ${e.toString()}');
      }
      final state = client.connectionStatus!.state;
    log('[MQTT] Final connection state: $state');
    } else {
      log('MQTT Server already connected ');
    }
  }

  /// Diconnection MQTT Server.
  static Future<void> disconnectMqtt() async {
  // Future<void> disconnectMqtt() async {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      try {
        client.disconnect();
      } catch (e) {
        log('Disconnection Failed ' + e.toString());
      }
    } else {
      log('MQTT Server already disconnected ');
    }
    if (client.connectionStatus!.state == MqttConnectionState.faulted) {
      reconnect();
    }
  }


  /// Subscribe a topic
  static void subscribeTopic(String topic) {
    // print("subscribeTopic function");
    final state = client.connectionStatus?.state;
    if (state != null) {
      // print("state not null");
      if (state == MqttConnectionState.connected) {
         
        client.subscribe("$topic", MqttQos.atMostOnce);
        // print("subscribed");
      }
    }
  }

  
  /// [reatain] means last message save the broker.
  static void publish(String topic, String message, {bool retain = false}) {
    final state = client.connectionStatus?.state;
    if (state != null) {
      // print("state not null");
      if (state == MqttConnectionState.connected) {
        final builder = MqttClientPayloadBuilder();
        builder.addString(message);
        client.publishMessage(
          topic,
          // MqttQos.atMostOnce,
          // MqttQos.exactlyOnce,
          MqttQos.atLeastOnce,
          builder.payload!,
          retain: retain,
        );
        builder.clear();
      }
    }

  }


  static void unSubscribeTopic(String topic) {
    final state = client.connectionStatus?.state;
    if (state != null) {
      if (state == MqttConnectionState.connected) {
        client.unsubscribe(topic + "/data");
      }
    }
  }


  static void onClose(){
    // mqttListen?.close();
    // disconnectMqtt();
  }

  static void _listenMqtt() {
    final state = client.connectionStatus?.state;
    if (state != null) {
      if (state == MqttConnectionState.connected) {
        mqttListen = client.updates!.listen((dynamic t) {
          MqttPublishMessage recMessage = t[0].payload;
          final message =
          MqttPublishPayload.bytesToStringAsString(recMessage.payload.message);
          // log("Payload is $message");
         log('[MQTT] Incoming message: $message');
        });
      }else{
         log('[MQTT] Cannot listen, connection state: $state');
      }
    }

  }
 static void connect() async {
    try {
      print('Trying to connect to the MQTT broker.');
      await client.connect();
    } on NoConnectionException catch (e) {
      print('No connection: $e');
      reconnect();
    } on SocketException catch (e) {
      print('Socket error: $e');
      reconnect();
    }
  }
 static void reconnect() {
    print('Attempting to reconnect...');
    Future.delayed(Duration(seconds: 3), connect);
  }
}