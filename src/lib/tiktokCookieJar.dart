import 'dart:convert';
import 'package:http/http.dart' as http;
import 'tiktokCookieJar.dart';
import 'webcastProtobuf.dart';
import 'tiktokSignatureProvider.dart';
import 'webcastConfig.dart';

class TikTokHttpClient {
  final Map<String, String> _customHeaders;
  final http.Client _httpClient;
  final TikTokCookieJar _cookieJar;
  String? _sessionId;

  TikTokHttpClient(this._customHeaders, {String? sessionId})
      : _httpClient = http.Client(),
        _cookieJar = TikTokCookieJar() {
    if (_customHeaders.containsKey('Cookie')) {
      _customHeaders.remove('Cookie');
    }

    if (sessionId != null) {
      setSessionId(sessionId);
    }
  }

  Future<http.Response> _get(String url, {String? responseType}) async {
    return _httpClient.get(Uri.parse(url), headers: _customHeaders);
  }

  Future<http.Response> _post(String url, Map<String, String> params, dynamic data, {String? responseType}) async {
    return _httpClient.post(Uri.parse(url), body: data, headers: _customHeaders);
  }

  void setSessionId(String sessionId) {
    _sessionId = sessionId;
    _cookieJar.setCookie('sessionid', sessionId);
    _cookieJar.setCookie('sessionid_ss', sessionId);
    _cookieJar.setCookie('sid_tt', sessionId);
  }

  Future<String> _buildUrl(String host, String path, Map<String, dynamic>? params, bool sign) async {
    var fullUrl = '$host$path?${Uri(queryParameters: params).query}';

    if (sign) {
      fullUrl = await signWebcastRequest(fullUrl, _customHeaders, _cookieJar);
    }

    return fullUrl;
  }

  Future<dynamic> getMainPage(String path) async {
    var response = await _get('${Config.TIKTOK_URL_WEB}$path');
    return json.decode(response.body);
  }

  Future<dynamic> getDeserializedObjectFromWebcastApi(String path, Map<String, dynamic> params, String schemaName, bool shouldSign) async {
    var url = await _buildUrl(Config.TIKTOK_URL_WEBCAST, path, params, shouldSign);
    var response = await _get(url);
    return deserializeMessage(schemaName, response.bodyBytes);
  }

  Future<dynamic> getJsonObjectFromWebcastApi(String path, Map<String, dynamic> params, bool shouldSign) async {
    var url = await _buildUrl(Config.TIKTOK_URL_WEBCAST, path, params, shouldSign);
    var response = await _get(url);
    return json.decode(response.body);
  }

  Future<dynamic> postFormDataToWebcastApi(String path, Map<String, dynamic> params, dynamic formData) async {
    var response = await _post('${Config.TIKTOK_URL_WEBCAST}$path', params, formData);
    return json.decode(response.body);
  }

  Future<dynamic> getJsonObjectFromTiktokApi(String path, Map<String, dynamic> params, bool shouldSign) async {
    var url = await _buildUrl(Config.TIKTOK_URL_WEB, path, params, shouldSign);
    var response = await _get(url);
    return json.decode(response.body);
  }
}
