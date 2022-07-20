import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:io';

Future<MqttClient> connect() async {
  MqttServerClient client =
      MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
  client.logging(on: true);
  client.onConnected = onConnected;
  client.onDisconnected = onDisconnected;
  client.onSubscribed = onSubscribed;
  client.onSubscribeFail = onSubscribeFail;
  client.pongCallback = pong;
  client.keepAlivePeriod = 30;

  final connMess = MqttConnectMessage()
      .withClientIdentifier("flutter_client")
      .authenticateAs("test", "test")
      .withWillTopic('ALTHEATESTER/willtopic')
      .withWillMessage('My Will message')
      .startClean()
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;
  try {
    print('Connecting');
    await client.connect();
  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }

  // client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
  //   final recMess = c![0].payload as MqttPublishMessage;
  //   final pt =
  //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

  //   /// The above may seem a little convoluted for users only interested in the
  //   /// payload, some users however may be interested in the received publish message,
  //   /// lets not constrain ourselves yet until the package has been in the wild
  //   /// for a while.
  //   /// The payload is a byte buffer, this will be specific to the topic
  //   print(
  //       'EXAMPLE::Change notification:: topic is <${c[0].topic}>, payload is <-- $pt -->');
  //   print('');
  // });

  return client;
}

void onConnected() {
  print('Connected');
}

void onDisconnected() {
  print('Disconnected');
}

void onSubscribed(String topic) {
  print('Subscribed topic: $topic');
}

void onSubscribeFail(String topic) {
  print('Failed to subscribe topic: $topic');
}

void onUnsubscribed(String topic) {
  print('Unsubscribed topic: $topic');
}

void pong() {
  print('Ping response client callback invoked');
}
