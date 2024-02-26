//1
/**
 * This function brings the nested protobuf objects to a flat level
 * In addition, attributes in "Long" format are converted to strings (e.g. UserIds)
 * This makes it easier to handle the data later, since some libraries have problems to serialize this protobuf specific data.
 */
void simplifyObject(Map<String, dynamic> webcastObject) {
  if (webcastObject.containsKey('questionDetails')) {
    webcastObject.addAll(webcastObject['questionDetails']);
    webcastObject.remove('questionDetails');
  }

  if (webcastObject.containsKey('user')) {
    webcastObject.addAll(getUserAttributes(webcastObject['user']));
    webcastObject.remove('user');
  }

  if (webcastObject.containsKey('event')) {
    webcastObject.addAll(getEventAttributes(webcastObject['event']));
    webcastObject.remove('event');
  }

  if (webcastObject.containsKey('eventDetails')) {
    webcastObject.addAll(webcastObject['eventDetails']);
    webcastObject.remove('eventDetails');
  }

  if (webcastObject.containsKey('topViewers')) {
    webcastObject['topViewers'] = getTopViewerAttributes(webcastObject['topViewers']);
  }

  if (webcastObject.containsKey('battleUsers')) {
    List<Map<String, dynamic>> battleUsers = [];
    webcastObject['battleUsers'].forEach((user) {
      if (user?['battleGroup']?['user'] != null) {
        battleUsers.add(getUserAttributes(user['battleGroup']['user']));
      }
    });

    webcastObject['battleUsers'] = battleUsers;
  }

  if (webcastObject.containsKey('battleItems')) {
    webcastObject['battleArmies'] = [];
    webcastObject['battleItems'].forEach((battleItem) {
      battleItem['battleGroups'].forEach((battleGroup) {
        Map<String, dynamic> group = {
          'hostUserId': battleItem['hostUserId'].toString(),
          'points': int.parse(battleGroup['points']),
          'participants': [],
        };

        battleGroup['users'].forEach((user) {
          group['participants'].add(getUserAttributes(user));
        });

        webcastObject['battleArmies'].add(group);
      });
    });

    webcastObject.remove('battleItems');
  }

  if (webcastObject.containsKey('giftId')) {
    // Convert to boolean
    webcastObject['repeatEnd'] = webcastObject['repeatEnd'] != null;

    // Add previously used JSON structure (for compatibility reasons)
    // Can be removed soon
    webcastObject['gift'] = {
      'gift_id': webcastObject['giftId'],
      'repeat_count': webcastObject['repeatCount'],
      'repeat_end': webcastObject['repeatEnd'] ? 1 : 0,
      'gift_type': webcastObject['giftDetails']?['giftType'],
    };

    if (webcastObject.containsKey('giftDetails')) {
      webcastObject.addAll(webcastObject['giftDetails']);
      webcastObject.remove('giftDetails');
    }
  }
}
//2
/**
 * This function brings the nested protobuf objects to a flat level
 * In addition, attributes in "Long" format are converted to strings (e.g. UserIds)
 * This makes it easier to handle the data later, since some libraries have problems to serialize this protobuf specific data.
 */
Map<String, dynamic> simplifyObject(Map<String, dynamic> webcastObject) {
  if (webcastObject.containsKey('giftId')) {
    // Convert to boolean
    webcastObject['repeatEnd'] = webcastObject['repeatEnd'] != null;

    // Add previously used JSON structure (for compatibility reasons)
    // Can be removed soon
    webcastObject['gift'] = {
      'gift_id': webcastObject['giftId'],
      'repeat_count': webcastObject['repeatCount'],
      'repeat_end': webcastObject['repeatEnd'] ? 1 : 0,
      'gift_type': webcastObject['giftDetails']?['giftType'],
    };

    if (webcastObject.containsKey('giftDetails')) {
      webcastObject.addAll(webcastObject['giftDetails']);
      webcastObject.remove('giftDetails');
    }

    if (webcastObject.containsKey('giftImage')) {
      webcastObject.addAll(webcastObject['giftImage']);
      webcastObject.remove('giftImage');
    }

    if (webcastObject.containsKey('giftExtra')) {
      webcastObject.addAll(webcastObject['giftExtra']);
      webcastObject.remove('giftExtra');

      if (webcastObject.containsKey('receiverUserId')) {
        webcastObject['receiverUserId'] = webcastObject['receiverUserId'].toString();
      }

      if (webcastObject.containsKey('timestamp')) {
        webcastObject['timestamp'] = int.parse(webcastObject['timestamp']);
      }
    }

    if (webcastObject.containsKey('groupId')) {
      webcastObject['groupId'] = webcastObject['groupId'].toString();
    }

    if (webcastObject.containsKey('monitorExtra') && webcastObject['monitorExtra'] is String && webcastObject['monitorExtra'].startsWith('{')) {
      try {
        webcastObject['monitorExtra'] = jsonDecode(webcastObject['monitorExtra']);
      } catch (e) {}
    }
  }

  if (webcastObject.containsKey('emote')) {
    webcastObject['emoteId'] = webcastObject['emote']?['emoteId'];
    webcastObject['emoteImageUrl'] = webcastObject['emote']?['image']?['imageUrl'];
    webcastObject.remove('emote');
  }

  if (webcastObject.containsKey('emotes')) {
    webcastObject['emotes'] = webcastObject['emotes'].map((x) {
      return {
        'emoteId': x['emote']?['emoteId'],
        'emoteImageUrl': x['emote']?['image']?['imageUrl'],
        'placeInComment': x['placeInComment'],
      };
    });
  }

  if (webcastObject.containsKey('treasureBoxUser')) {
    webcastObject.addAll(getUserAttributes(webcastObject['treasureBoxUser']?['user2']?['user3'][0]?['user4']?['user'] ?? {});
    webcastObject.remove('treasureBoxUser');
  }

  if (webcastObject.containsKey('treasureBoxData')) {
    webcastObject.addAll(webcastObject['treasureBoxData']);
    webcastObject.remove('treasureBoxData');
    webcastObject['timestamp'] = int.parse(webcastObject['timestamp']);
  }

  return Map<String, dynamic>.from(webcastObject);
}

Map<String, dynamic> getUserAttributes(Map<String, dynamic> webcastUser) {
  Map<String, dynamic> userAttributes = {
    'userId': webcastUser['userId']?.toString(),
    'secUid': webcastUser['secUid']?.toString(),
    'uniqueId': webcastUser['uniqueId'] != '' ? webcastUser['uniqueId'] : null,
    'nickname': webcastUser['nickname'] != '' ? webcastUser['nickname'] : null,
    'profilePictureUrl': getPreferredPictureFormat(webcastUser['profilePicture']?['urls']),
    // Add other attributes as needed
  };

  return userAttributes;
}
//3
Map<String, dynamic> getUserAttributes(Map<String, dynamic> webcastUser) {
  Map<String, dynamic> userAttributes = {
    'userId': webcastUser['userId']?.toString(),
    'secUid': webcastUser['secUid']?.toString(),
    'uniqueId': webcastUser['uniqueId'] != '' ? webcastUser['uniqueId'] : null,
    'nickname': webcastUser['nickname'] != '' ? webcastUser['nickname'] : null,
    'profilePictureUrl': getPreferredPictureFormat(webcastUser['profilePicture']?['urls']),
    'followRole': webcastUser['followInfo']?['followStatus'],
    'userBadges': mapBadges(webcastUser['badges']),
    'userSceneTypes': webcastUser['badges']?.map((x) => x?['badgeSceneType'] ?? 0),
    'userDetails': {
      'createTime': webcastUser['createTime']?.toString(),
      'bioDescription': webcastUser['bioDescription'],
      'profilePictureUrls': webcastUser['profilePicture']?['urls'],
    },
  };

  if (webcastUser.containsKey('followInfo')) {
    userAttributes['followInfo'] = {
      'followingCount': webcastUser['followInfo']['followingCount'],
      'followerCount': webcastUser['followInfo']['followerCount'],
      'followStatus': webcastUser['followInfo']['followStatus'],
      'pushStatus': webcastUser['followInfo']['pushStatus'],
    };
  }

  userAttributes['isModerator'] = userAttributes['userBadges'].any((x) => (x['type'] != null && x['type'].toLowerCase().contains('moderator')) || x['badgeSceneType'] == 1);
  userAttributes['isNewGifter'] = userAttributes['userBadges'].any((x) => x['type'] != null && x['type'].toLowerCase().contains('live_ng_'));
  userAttributes['isSubscriber'] = userAttributes['userBadges'].any((x) => (x['url'] != null && x['url'].toLowerCase().contains('/sub_')) || x['badgeSceneType'] == 4 || x['badgeSceneType'] == 7);
  userAttributes['topGifterRank'] = userAttributes['userBadges']
      .firstWhere((x) => x['url'] != null && x['url'].contains('/ranklist_top_gifter_'), orElse: () => {})['url']?.match(RegExp(r'(?<=ranklist_top_gifter_)(\d+)(?=.png)'))?.map(int.parse)?.first ?? null;

  userAttributes['gifterLevel'] = userAttributes['userBadges'].firstWhere((x) => x['badgeSceneType'] == 8, orElse: () => {})['level'] ?? 0;
  userAttributes['teamMemberLevel'] = userAttributes['userBadges'].firstWhere((x) => x['badgeSceneType'] == 10, orElse: () => {})['level'] ?? 0;

  return userAttributes;
}

Map<String, dynamic> getEventAttributes(Map<String, dynamic> event) {
  if (event.containsKey('msgId')) event['msgId'] = event['msgId'].toString();
  if (event.containsKey('createTime')) event['createTime'] = event['createTime'].toString();
  return event;
}

List<Map<String, dynamic>> getTopViewerAttributes(List<Map<String, dynamic>> topViewers) {
  return topViewers.map((viewer) {
    return {
      'user': viewer['user'] != null ? getUserAttributes(viewer['user']) : null,
      'coinCount': viewer['coinCount'] != null ? int.parse(viewer['coinCount']) : 0,
    };
  }).toList();
}

List<Map<String, dynamic>> mapBadges(List<Map<String, dynamic>> badges) {
  List<Map<String, dynamic>> simplifiedBadges = [];

  if (badges != null) {
    badges.forEach((innerBadges) {
      int badgeSceneType = innerBadges['badgeSceneType'];

      if (innerBadges.containsKey('badges')) {
//4
          List<Map<String, dynamic>> mapBadges(List<Map<String, dynamic>> badges) {
  List<Map<String, dynamic>> simplifiedBadges = [];

  if (badges != null) {
    badges.forEach((innerBadges) {
      int badgeSceneType = innerBadges['badgeSceneType'];

      if (innerBadges.containsKey('badges')) {
        innerBadges['badges'].forEach((badge) {
          simplifiedBadges.add({
            'badgeSceneType': badgeSceneType,
            ...badge,
          });
        });
      }

      if (innerBadges.containsKey('imageBadges')) {
        innerBadges['imageBadges'].forEach((badge) {
          if (badge != null && badge['image'] != null && badge['image']['url'] != null) {
            simplifiedBadges.add({
              'type': 'image',
              'badgeSceneType': badgeSceneType,
              'displayType': badge['displayType'],
              'url': badge['image']['url'],
            });
          }
        });
      }

      if (innerBadges['privilegeLogExtra']?['level'] != null && innerBadges['privilegeLogExtra']['level'] != '0') {
        simplifiedBadges.add({
          'type': 'privilege',
          'privilegeId': innerBadges['privilegeLogExtra']['privilegeId'],
          'level': int.parse(innerBadges['privilegeLogExtra']['level']),
          'badgeSceneType': badgeSceneType,
        });
      }
    });
  }

  return simplifiedBadges;
}

String getPreferredPictureFormat(List<String> pictureUrls) {
  if (pictureUrls == null || pictureUrls.isEmpty) {
    return null;
  }

  return pictureUrls.firstWhere((x) => x.contains('100x100') && x.contains('.webp'), orElse: () {
    return pictureUrls.firstWhere((x) => x.contains('100x100') && x.contains('.jpeg'), orElse: () {
      return pictureUrls.firstWhere((x) => !x.contains('shrink'), orElse: () {
        return pictureUrls[0];
      });
    });
  });
}
//5
          
