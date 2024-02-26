import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:your_package_name/tiktokUtils.dart'; // Adjust the import path as necessary
//import 'package:your_package_name/version.dart'; // Create this to manage your package version

// Assuming you have a version.dart file that contains your package name and version
// final packageName = 'yourPackageName';
// final packageVersion = 'yourPackageVersion';

class Config {
  bool enabled = true;
  String signProviderHost = 'https://tiktok.eulerstream.com/';
  List<String> signProviderFallbackHosts = ['https://tiktok-sign.zerody.one/'];
  Map<String, dynamic> extraParams = {};

  Config();
}

class SignEvents {
  final _signSuccessController = StreamController.broadcast();
  final _signErrorController = StreamController.broadcast();

  Stream get onSignSuccess => _signSuccessController.stream;
  Stream get onSignError => _signErrorController.stream;

  void emitSignSuccess(Map<String, dynamic> data) => _signSuccessController.add(data);
  void emitSignError(Map<String, dynamic> data) => _signErrorController.add(data);

  void dispose() {
    _signSuccessController.close();
    _signErrorController.close();
  }
}

final config = Config();
final signEvents = SignEvents();

Future<String> signWebcastRequest(String url, Map<String, String>? headers, dynamic cookieJar) async {
  return signRequest('webcast/sign_url', url, headers, cookieJar);
}

Future<String> signRequest(String providerPath, String url, Map<String, String>? headers, dynamic cookieJar) async {
  if (!config.enabled) {
    return url;
  }

  var params = {
    'url': url,
    'client': 'ttlive-node',
    ...config.extraParams,
    'uuc': getUuc(), // Ensure you have a getUuc function that returns a value
  };

  String? signHost;
  dynamic signResponse;
  dynamic signError;

  try {
    for (signHost in [config.signProviderHost, ...config.signProviderFallbackHosts]) {
      try {
        var uri = Uri.parse(signHost + providerPath).replace(queryParameters: params);
        var response = await http.get(uri, headers: {
          'User-Agent': '$packageName/$packageVersion',
        });

        if (response.statusCode == 200) {
          signResponse = json.decode(response.body);
          if (signResponse is Map && signResponse.containsKey('signedUrl')) {
            break;
          }
        }
      } catch (err) {
        signError = err;
      }
    }

    if (signResponse == null) {
      throw signError;
    }

    if (!signResponse.containsKey('signedUrl')) {
      throw Exception('missing signedUrl property');
    }

    headers?['User-Agent'] = signResponse['User-Agent'];

    // Handle cookieJar operations as per your implementation

    signEvents.emitSignSuccess({
      'signHost': signHost,
      'originalUrl': url,
      'signedUrl': signResponse['signedUrl'],
      'headers': headers,
      'cookieJar': cookieJar,
    });

    return signResponse['signedUrl'];
  } catch (error) {
    signEvents.emitSignError({
      'signHost': signHost,
      'originalUrl': url,
      'headers': headers,
      'cookieJar': cookieJar,
      'error': error.toString(),
    });

    // Handle cookieJar operations as per your implementation

    throw Exception('Failed to sign request: ${error.toString()}; URL: $url');
  }
}
