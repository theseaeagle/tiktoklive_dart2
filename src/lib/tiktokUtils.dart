List<Map<String, dynamic>> uu = [];

String getRoomIdFromMainPageHtml(String mainPageHtml) {
  RegExpMatch? matchMeta = RegExp(r'room_id=([0-9]*)').firstMatch(mainPageHtml);
  if (matchMeta != null && matchMeta.group(1) != null) return matchMeta.group(1)!;

  RegExpMatch? matchJson = RegExp(r'"roomId":"([0-9]*)').firstMatch(mainPageHtml);
  if (matchJson != null && matchJson.group(1) != null) return matchJson.group(1)!;

  bool validResponse = mainPageHtml.contains('"og:url"');

  throw Exception(validResponse ? 'User might be offline.' : 'Your IP or country might be blocked by TikTok.');
}

String validateAndNormalizeUniqueId(String uniqueId) {
  if (uniqueId is! String) {
    throw Exception("Missing or invalid value for 'uniqueId'. Please provide the username from TikTok URL.");
  }

  // Support full URI
  uniqueId = uniqueId.replaceAll('https://www.tiktok.com/', '');
  uniqueId = uniqueId.replaceAll('/live', '');
  uniqueId = uniqueId.replaceAll('@', '');
  uniqueId = uniqueId.trim();

  return uniqueId;
}

void addUniqueId(String uniqueId) {
  Map<String, dynamic>? existingEntry = uu.firstWhere((x) => x['uniqueId'] == uniqueId, orElse: () => null);
  if (existingEntry != null) {
    existingEntry['ts'] = DateTime.now().millisecondsSinceEpoch;
  } else {
    uu.add({
      'uniqueId': uniqueId,
      'ts': DateTime.now().millisecondsSinceEpoch,
    });
  }
}

void removeUniqueId(String uniqueId) {
  uu.removeWhere((x) => x['uniqueId'] == uniqueId);
}

int getUuc() {
  return uu.where((x) => x['ts'] > DateTime.now().millisecondsSinceEpoch - 10 * 60000).length;
}

void main() {
  // Test the functions here
}
