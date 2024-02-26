import 'dart:convert';
import 'package:http/http.dart' as http;
import './tiktokCookieJar.dart';
import './webcastProtobuf.dart';
import './tiktokSignatureProvider.dart';
import './webcastConfig.dart';

class TikTokHttpClient {
  Map<String, String> customHeaders;
  Map<String, dynamic> axiosOptions;
  String? sessionId;
  http.Client _httpClient;
  TikTokCookieJar _cookieJar;

  TikTokHttpClient(this.customHeaders, this.axiosOptions, this.sessionId)
      : _httpClient = http.Client(),
        _cookieJar = TikTokCookieJar() {
    customHeaders.remove('Cookie');

    _cookieJar.processSetCookieHeader(customHeaders['Cookie'] ?? '');
    if (sessionId != null) {
      setSessionId(sessionId!);
    }
  }

  Future<http.Response> _get(String url, {String responseType = 'json'}) async {
    final response = await _httpClient.get(Uri.parse(url), headers: customHeaders);
    return response;
  }

  Future<http.Response> _post(String url, Map<String, dynamic> params, dynamic data, {String responseType = 'json'}) async {
    final response = await _httpClient.post(Uri.parse(url), body: data, headers: customHeaders);
    return response;
  }

  void setSessionId(String sessionId) {
    _cookieJar.setCookie('sessionid', sessionId);
    _cookieJar.setCookie('sessionid_ss', sessionId);
    _cookieJar.setCookie('sid_tt', sessionId);
  }

  Future<String> _buildUrl(String host, String path, Map<String, dynamic>? params, bool sign) async {
    String fullUrl = '$host$path?${Uri(queryParameters: params).query}';
    
    if (sign) {
      fullUrl = await signWebcastRequest(fullUrl, customHeaders, _cookieJar);
    }

    return fullUrl;
  }

  Future<dynamic> getMainPage(String path) async {
    final response = await _get('${Config.tiktokUrlWeb}$path');
    return json.decode(response.body);
  }

  Future<dynamic> getDeserializedObjectFromWebcastApi(String path, Map<String, dynamic> params, String schemaName, bool shouldSign) async {
    String url = await _buildUrl(Config.tiktokUrlWebcast, path, params, shouldSign);
    final response = await _get(url, responseType: 'arraybuffer');
    return deserializeMessage(schemaName, response.bodyBytes);
  }

  Future<dynamic> getJsonObjectFromWebcastApi(String path, Map<String, dynamic> params, bool shouldSign) async {
    String url = await _buildUrl(Config.tiktokUrlWebcast, path, params, shouldSign);
    final response = await _get(url);
    return json.decode(response.body);
  }

  Future<dynamic> postFormDataToWebcastApi(String path, Map<String, dynamic> params, dynamic formData) async {
    final response = await _post('${Config.tiktokUrlWebcast}$path', params, formData);
    return json.decode(response.body);
  }

  Future<dynamic> getJsonObjectFromTiktokApi(String path, Map<String, dynamic> params, bool shouldSign) async {
    String url = await _buildUrl(Config.tiktokUrlWeb, path, params, shouldSign);
    final response = await _get(url);
    return json.decode(response.body);
  }
}
