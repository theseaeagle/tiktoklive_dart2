/// Custom cookie jar for Dart HTTP clients.
/// This is a conceptual translation from the original JavaScript code designed for Axios.
/// Dart's HTTP package or similar should be used to make HTTP requests.
import 'dart:convert';

class TikTokCookieJar {
  final Map<String, String> cookies = {};

  /// Reads and stores cookies from the response headers.
  void readCookies(Map<String, String> headers) {
    final List<String>? setCookieHeaders = headers['set-cookie']?.split(',');

    if (setCookieHeaders != null) {
      for (final setCookieHeader in setCookieHeaders) {
        processSetCookieHeader(setCookieHeader.trim());
      }
    }
  }

  /// Appends stored cookies to the request headers.
  void appendCookies(Map<String, String> headers) {
    final String? headerCookie = headers['Cookie'];
    if (headerCookie != null) {
      final Map<String, String> parsedCookies = parseCookie(headerCookie);
      cookies.addAll(parsedCookies);
    }

    headers['Cookie'] = getCookieString();
  }

  /// Parses a cookie string into a Map.
  Map<String, String> parseCookie(String str) {
    final Map<String, String> cookies = {};

    final List<String> parts = str.split('; ');
    for (final part in parts) {
      final int index = part.indexOf('=');
      if (index == -1) continue;

      final String name = Uri.decodeComponent(part.substring(0, index));
      final String value = part.substring(index + 1);

      cookies[name] = value;
    }

    return cookies;
  }

  /// Processes a 'Set-Cookie' header and stores the cookie.
  void processSetCookieHeader(String setCookieHeader) {
    final int index = setCookieHeader.indexOf(';');
    final String nameValuePart = (index == -1) ? setCookieHeader : setCookieHeader.substring(0, index);
    final int equalIndex = nameValuePart.indexOf('=');

    if (equalIndex != -1) {
      final String cookieName = Uri.decodeComponent(nameValuePart.substring(0, equalIndex));
      final String cookieValue = nameValuePart.substring(equalIndex + 1);

      cookies[cookieName] = cookieValue;
    }
  }

  /// Retrieves a cookie value by name.
  String? getCookieByName(String cookieName) {
    return cookies[cookieName];
  }

  /// Returns a string representation of the stored cookies.
  String getCookieString() {
    return cookies.entries.map((entry) => '${Uri.encodeComponent(entry.key)}=${entry.value}').join('; ');
  }

  /// Sets a cookie.
  void setCookie(String name, String value) {
    cookies[name] = value;
  }
}
