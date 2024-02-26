/// Custom cookie jar for Dart HTTP clients.
/// This is a conceptual translation from JavaScript to Dart and does not directly integrate with a Dart HTTP client.
/// It's meant to demonstrate how the cookie management logic can be implemented in Dart.

class TikTokCookieJar {
  Map<String, String> cookies = {};

  TikTokCookieJar();

  /// Reads cookies from response headers and stores them.
  void readCookies(Map<String, String> headers) {
    final setCookieHeaders = headers['set-cookie'];

    if (setCookieHeaders != null) {
      final cookieList = setCookieHeaders.split(',');
      for (final setCookieHeader in cookieList) {
        processSetCookieHeader(setCookieHeader.trim());
      }
    }
  }

  /// Appends cookies to request headers.
  void appendCookies(Map<String, String> headers) {
    // We use the capitalized 'Cookie' header, because every browser does that
    if (headers.containsKey('cookie')) {
      headers['Cookie'] = headers['cookie']!;
      headers.remove('cookie');
    }

    // Cookies already set by custom headers? => Append
    final headerCookie = headers['Cookie'];
    if (headerCookie != null) {
      final parsedCookies = parseCookie(headerCookie);
      cookies.addAll(parsedCookies);
    }

    headers['Cookie'] = getCookieString();
  }

  /// Parses cookies string to object.
  Map<String, String> parseCookie(String str) {
    final cookies = <String, String>{};

    if (str.isEmpty) {
      return cookies;
    }

    final cookiePairs = str.split('; ');
    for (final pair in cookiePairs) {
      if (pair.isEmpty) {
        continue;
      }

      final parts = pair.split('=');
      final cookieName = Uri.decodeComponent(parts.first);
      final cookieValue = parts.sublist(1).join('=');

      cookies[cookieName] = cookieValue;
    }

    return cookies;
  }

  /// Processes a single Set-Cookie header.
  void processSetCookieHeader(String setCookieHeader) {
    final nameValuePart = setCookieHeader.split(';').first;
    final parts = nameValuePart.split('=');
    final cookieName = Uri.decodeComponent(parts.first);
    final cookieValue = parts.sublist(1).join('=');

    if (cookieName.isNotEmpty && cookieValue.isNotEmpty) {
      cookies[cookieName] = cookieValue;
    }
  }

  /// Retrieves a cookie by name.
  String? getCookieByName(String cookieName) {
    return cookies[cookieName];
  }

  /// Constructs a cookie header string from stored cookies.
  String getCookieString() {
    return cookies.entries.map((e) => '${Uri.encodeComponent(e.key)}=${e.value}').join('; ');
  }

  /// Sets a cookie.
  void setCookie(String name, String value) {
    cookies[name] = value;
  }
}
