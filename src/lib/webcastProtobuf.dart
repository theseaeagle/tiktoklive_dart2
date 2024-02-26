dependencies:
  protobuf: ^2.0.0
  archive: ^3.1.2

import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:protobuf/protobuf.dart';
import 'package:archive/archive.dart';

// Assuming tiktokSchema.proto is converted to Dart using the protoc plugin for Dart
import '../proto/tiktokSchema.pb.dart';

final config = {
  'skipMessageTypes': [],
};

// Load & cache schema
TikTokSchema? tiktokSchema;

void loadTikTokSchema() {
  if (tiktokSchema == null) {
    // Load your protobuf schema here. This is highly dependent on how your .proto files are structured.
    // For the sake of this example, let's assume TikTokSchema is a generated class from your .proto file.
    tiktokSchema = TikTokSchema();
  }
}

Uint8List serializeMessage(String protoName, GeneratedMessage obj) {
  loadTikTokSchema();
  // This assumes you have a method to dynamically get the correct builder for serialization
  // based on protoName. This is a simplification and might need to be adjusted.
  return tiktokSchema!.serializeMessage(protoName, obj);
}

GeneratedMessage deserializeMessage(String protoName, Uint8List binaryMessage) {
  loadTikTokSchema();
  // Similar to serialization, this assumes a method to dynamically deserialize based on protoName.
  var message = tiktokSchema!.deserializeMessage(protoName, binaryMessage);

  // Your custom logic for handling specific message types goes here.
  // This will need to be adapted based on your actual message handling logic.

  return message;
}

Future<GeneratedMessage> deserializeWebsocketMessage(Uint8List binaryMessage) async {
  // Assuming WebcastWebsocketMessage is a message type generated from your .proto file
  var decodedWebsocketMessage = deserializeMessage('WebcastWebsocketMessage', binaryMessage) as WebcastWebsocketMessage;
  if (decodedWebsocketMessage.type == 'msg') {
    var binary = decodedWebsocketMessage.binary;

    // Decompress binary (if gzip compressed)
    if (binary.isNotEmpty && binary[0] == 0x1f && binary[1] == 0x8b && binary[2] == 0x08) {
      decodedWebsocketMessage.binary = _decompressGzip(binary);
    }

    decodedWebsocketMessage.webcastResponse = deserializeMessage('WebcastResponse', decodedWebsocketMessage.binary) as WebcastResponse;
  }

  return decodedWebsocketMessage;
}

Uint8List _decompressGzip(Uint8List data) {
  return GZipDecoder().decodeBytes(data);
}
      
