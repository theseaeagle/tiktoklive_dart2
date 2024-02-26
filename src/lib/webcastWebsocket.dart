import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'webcastConfig.dart'; // Assuming webcastConfig.js is converted to webcastConfig.dart
import 'webcastProtobuf.dart'; // Assuming webcastProtobuf.js is converted to webcastProtobuf.dart

class WebcastWebsocket {
  late WebSocketChannel _channel;
  Timer? _pingInterval;
  final Uri _wsUrlWithParams;
  final Map<String, dynamic> _wsHeaders;

  WebcastWebsocket(String wsUrl, String cookieJar, Map<String, dynamic> clientParams, Map<String, dynamic> wsParams, Map<String, dynamic>? customHeaders, Map<String, dynamic>? websocketOptions)
      : _wsUrlWithParams = Uri.parse('$wsUrl?${Uri(queryParameters: {...clientParams, ...wsParams}).query}'),
        _wsHeaders = {
          'Cookie': cookieJar, // Assuming cookieJar is a string of cookie headers
          ...?customHeaders,
        } {
    _connect();
  }

  void _connect() {
    _channel = WebSocketChannel.connect(
      _wsUrlWithParams,
      protocols: ['echo-protocol'],
      headers: _wsHeaders,
    );
    _handleEvents();
  }

  void _handleEvents() {
    _channel.stream.listen((message) {
      _handleMessage(message);
    }, onDone: () {
      _pingInterval?.cancel();
    });
  }

  Future<void> _handleMessage(dynamic message) async {
    try {
      var decodedContainer = await deserializeWebsocketMessage(message);

      if (decodedContainer['id'] > 0) {
        _sendAck(decodedContainer['id']);
      }

      // Emit 'WebcastResponse' from ws message container if decoding success
      if (decodedContainer['webcastResponse'] is Map<String, dynamic>) {
        // Dart does not have a direct equivalent of Node.js's EventEmitter.
        // You might use Streams or callbacks to handle this part.
        // This is a placeholder for emitting 'webcastResponse'.
      }
    } catch (err) {
      // Placeholder for emitting 'messageDecodingFailed'.
    }
  }

  void _sendPing() {
    // Send static connection alive ping
    _channel.sink.add(utf8.encode('3A026862')); // Assuming the ping message is the same
  }

  void _sendAck(int id) {
    var ackMsg = serializeMessage('WebcastWebsocketAck', {'type': 'ack', 'id': id});
    _channel.sink.add(ackMsg);
  }

  void dispose() {
    _pingInterval?.cancel();
    _channel.sink.close();
  }
}
