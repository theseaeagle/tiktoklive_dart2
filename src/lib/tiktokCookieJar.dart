/// Custom cookie jar for Dart HTTP requests.
/// This is adapted from a custom cookie jar implementation for Axios in JavaScript.
/// It's designed to work around issues with cookie handling when using proxy agents.
class TikTokCookieJar {
  final Map<String, String> cookies = {};

  TikTokCookieJar();

  /// Reads and stores cookies from the 'set-cookie' headers in the HTTP response.
  void readCookies(Map<String, String> headers) {
    final setCookieHeaders = headers['set-cookie'];

    if (setCookieHeaders != null) {
      final cookieList = setCookieHeaders.split(',');
      for (final setCookieHeader in cookieList) {
        processSetCookieHeader(setCookieHeader.trim());
      }
    }
  }

  /// Appends stored cookies to the request headers.
  void appendCookies(Map<String, String> headers) {
    // We use the capitalized 'Cookie' header, because every browser does that
    final headerCookie = headers['Cookie'] ?? headers['cookie'];
    if (headerCookie != null) {
      final parsedCookies = parseCookie(headerCookie);
      cookies.addAll(parsedCookies);
    }

    headers['Cookie'] = getCookieString();
  }

  /// Parses a cookie string into a Map of cookie names and values.
  Map<String, String> parseCookie(String str) {
    final Map<String, String> cookies = {};

    final cookiePairs = str.split('; ');
    for (final pair in cookiePairs) {
      final parts = pair.split('=');
      if (parts.length >= 2) {
        final name = Uri.decodeComponent(parts[0]);
        final value = parts.sublist(1).join('=');
        cookies[name] = value;
      }
    }

    return cookies;
  }

  /// Processes a 'Set-Cookie' header and stores the cookie.
  void processSetCookieHeader(String setCookieHeader) {
    final parts = setCookieHeader.split(';')[0].split('=');
    if (parts.length >= 2) {
      final name = Uri.decodeComponent(parts[0]);
      final value = parts.sublist(1).join('=');
      cookies[name] = value;
    }
  }

  /// Retrieves a cookie value by name.
  String? getCookieByName(String name) {
    return cookies[name];
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
