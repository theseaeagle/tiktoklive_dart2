//1
import 'package:eventify/eventify.dart';

import 'lib/tiktokHttpClient.dart';
import 'lib/webcastWebsocket.dart';
import 'lib/tiktokUtils.dart';
import 'lib/webcastDataConverter.dart';
import 'lib/webcastProtobuf.dart';
import 'lib/webcastConfig.dart';

class ControlEvents {
  static const String CONNECTED = 'connected';
  static const String DISCONNECTED = 'disconnected';
  static const String ERROR = 'error';
  static const String RAWDATA = 'rawData';
  static const String DECODEDDATA = 'decodedData';
  static const String STREAMEND = 'streamEnd';
  static const String WSCONNECTED = 'websocketConnected';
}

class MessageEvents {
  static const String CHAT = 'chat';
  static const String MEMBER = 'member';
  static const String GIFT = 'gift';
  static const String ROOMUSER = 'roomUser';
  static const String SOCIAL = 'social';
  static const String LIKE = 'like';
  static const String QUESTIONNEW = 'questionNew';
  static const String LINKMICBATTLE = 'linkMicBattle';
  static const String LINKMICARMIES = 'linkMicArmies';
  static const String LIVEINTRO = 'liveIntro';
  static const String EMOTE = 'emote';
  static const String ENVELOPE = 'envelope';
  static const String SUBSCRIBE = 'subscribe';
}

class CustomEvents {
  static const String FOLLOW = 'follow';
  static const String SHARE = 'share';
}

/// Wrapper class for TikTok's internal Webcast Push Service
class WebcastPushConnection extends EventEmitter {
  Map<String, dynamic> _options;
  String _uniqueStreamerId;
  String _roomId;
  dynamic _roomInfo;
  Map<String, dynamic> _clientParams;
  TikTokHttpClient _httpClient;
  Map<String, dynamic> _availableGifts;

  // Websocket
  WebcastWebsocket _websocket;

  // State
  bool _isConnecting;
  bool _isConnected;
  bool _isPollingEnabled;
  bool _isWsUpgradeDone;

  /// Create a new WebcastPushConnection instance
  ///
  /// uniqueId: TikTok username (from URL)
  /// options: Connection options
  /// options.processInitialData: Process the initial data which includes messages of the last minutes
  /// options.fetchRoomInfoOnConnect: Fetch the room info (room status, streamer info, etc.) on connect (will be returned when calling connect())
  /// options.enableExtendedGiftInfo: Enable this option to get extended information on 'gift' events like gift name and cost
  /// options.enableWebsocketUpgrade: Use WebSocket instead of request polling if TikTok offers it
  /// options.enableRequestPolling: Use request polling if no WebSocket upgrade is offered. If `false` an exception will be thrown if TikTok does not offer a WebSocket upgrade.
  /// options.requestPollingIntervalMs: Request polling interval if WebSocket is not used
  /// options.sessionId: The session ID from the "sessionid" cookie is required if you want to send automated messages in the chat.
  /// options.clientParams: Custom client params for Webcast API
  /// options.requestHeaders: Custom request headers for axios
  /// options.websocketHeaders: Custom request headers for websocket.client
  /// options.requestOptions: Custom request options for axios. Here you can specify an `httpsAgent` to use a proxy and a `timeout` value for example.
  WebcastPushConnection(String uniqueId, {Map<String, dynamic>? options}) {
    // Initialization code here
  }
}
//2
WebcastPushConnection(String uniqueId, {Map<String, dynamic>? options}) : super() {
    _setOptions(options ?? {});
    _uniqueStreamerId = validateAndNormalizeUniqueId(uniqueId);
    _httpClient = TikTokHttpClient(
        _options['requestHeaders'],
        _options['requestOptions'],
        _options['sessionId'],
    );

    _clientParams = {
        ...Config.DEFAULT_CLIENT_PARAMS,
        ..._options['clientParams'],
    };

    _setUnconnected();
}

void _setOptions(Map<String, dynamic> providedOptions) {
    _options = {
        'processInitialData': true,
        'fetchRoomInfoOnConnect': true,
        'enableExtendedGiftInfo': false,
        'enableWebsocketUpgrade': true,
        'enableRequestPolling': true,
        'requestPollingIntervalMs': 1000,
        'sessionId': null,
        'clientParams': {},
        'requestHeaders': {},
        'websocketHeaders': {},
        'requestOptions': {},
        'websocketOptions': {},
        ...providedOptions,
    };
}

void _setUnconnected() {
    _roomInfo = null;
    _isConnecting = false;
    _isConnected = false;
    _isPollingEnabled = false;
    _isWsUpgradeDone = false;
    _clientParams['cursor'] = '';
    _clientParams['internal_ext'] = '';
}

Future<void> connect({String? roomId}) async {
    if (_isConnecting) {
        throw Exception('Already connecting!');
    }

    if (_isConnected) {
        throw Exception('Already connected!');
    }

    _isConnecting = true;

    // add streamerId to uu
    addUniqueId(_uniqueStreamerId);

    try {
        // roomId already specified?
        if (roomId != null) {
//3
        // add streamerId to uu
addUniqueId(_uniqueStreamerId);

try {
    // roomId already specified?
    if (roomId != null) {
        _roomId = roomId;
        _clientParams['room_id'] = roomId;
    } else {
        await _retrieveRoomId();
    }

    // Fetch room info if option enabled
    if (_options['fetchRoomInfoOnConnect']) {
        await _fetchRoomInfo();

        // Prevent connections to finished rooms
        if (_roomInfo['status'] == 4) {
            throw Exception('LIVE has ended');
        }
    }

    // Fetch all available gift info if option enabled
    if (_options['enableExtendedGiftInfo']) {
        await _fetchAvailableGifts();
    }

    await _fetchRoomData(true);

    // Sometimes no upgrade to WebSocket is offered by TikTok
    // In that case we use request polling (if enabled and possible)
    if (!_isWsUpgradeDone) {
        if (!_options['enableRequestPolling']) {
            throw Exception('TikTok does not offer a websocket upgrade and request polling is disabled (`enableRequestPolling` option).');
        }

        if (_options['sessionId'] == null) {
            // We cannot use request polling if the user has no sessionid defined.
            // The reason for this is that TikTok needs a valid signature if the user is not logged in.
            // Signing a request every second would generate too much traffic to the signing server.
            // If a sessionid is present a signature is not required.
            throw Exception('TikTok does not offer a websocket upgrade. Please provide a valid `sessionId` to use request polling instead.');
        }

        _startFetchRoomPolling();
    }

    _isConnected = true;

    var state = getState();

    emit(ControlEvents.CONNECTED, state);
    return state;
} catch (err) {
    _handleError(err, 'Error while connecting');

    // remove streamerId from uu on connect fail
    removeUniqueId(_uniqueStreamerId);

    rethrow;
} finally {
    _isConnecting = false;
}
}
//4
    void disconnect() {
    if (_isConnected) {
        if (_isWsUpgradeDone && _websocket.connection.connected) {
            _websocket.connection.close();
        }

        // Reset state
        _setUnconnected();

        // remove streamerId from uu
        removeUniqueId(_uniqueStreamerId);

        emit(ControlEvents.DISCONNECTED);
    }
}

Map<String, dynamic> getState() {
    return {
        'isConnected': _isConnected,
        'upgradedToWebsocket': _isWsUpgradeDone,
        'roomId': _roomId,
        'roomInfo': _roomInfo,
        'availableGifts': _availableGifts,
    };
}

Future<dynamic> getRoomInfo() async {
    // Retrieve current room_id if not connected
    if (!_isConnected) {
        await _retrieveRoomId();
    }

    await _fetchRoomInfo();

    return _roomInfo;
}

Future<dynamic> getAvailableGifts() async {
    await _fetchAvailableGifts();

    return _availableGifts;
}

Future<void> sendMessage(String text, {String? sessionId}) async {
    if (sessionId != null) {
        // Update sessionId
        _options['sessionId'] = sessionId;
    }

    if (_options['sessionId'] == null) {
        throw Exception('Missing SessionId. Please provide your current SessionId to use this feature.');
    }

    try {
        // Retrieve current room_id if not connected
        if (!_isConnected) {
//5
            }

    // Retrieve current room_id if not connected
    if (!_isConnected) {
        await _retrieveRoomId();
    }

    // Add the session cookie to the CookieJar
    _httpClient.setSessionId(_options['sessionId']);

    // Submit the chat request
    var requestParams = {
        ..._clientParams,
        'content': text,
    };
    var response = await _httpClient.postFormDataToWebcastApi('room/chat/', requestParams, null);

    // Success?
    if (response?['status_code'] == 0) {
        return response['data'];
    }

    // Handle errors
    switch (response?['status_code']) {
        case 20003:
            throw Exception('Your SessionId has expired. Please provide a new one.');
        default:
            throw Exception('TikTok responded with status code ${response?['status_code']}: ${response?['data']?['message']}');
    }
} catch (err) {
    throw Exception('Failed to send chat message. ${err.message}');
}

void decodeProtobufMessage(String messageType, Uint8List messageBuffer) async {
    switch (messageType) {
        case 'WebcastResponse':
            var decodedWebcastResponse = deserializeMessage(messageType, messageBuffer);
            _processWebcastResponse(decodedWebcastResponse);
            break;

        case 'WebcastWebsocketMessage':
            var decodedWebcastWebsocketMessage = await deserializeWebsocketMessage(messageBuffer);
            if (decodedWebcastWebsocketMessage['webcastResponse'] is Map) {
                _processWebcastResponse(decodedWebcastWebsocketMessage['webcastResponse']);
            }
            break;

        default:
            var webcastMessage = deserializeMessage(messageType, messageBuffer);
            _processWebcastResponse({
                'messages': [
                    {
                        'decodedData': webcastMessage,
                        'type': messageType,
//6
                                    {
                'decodedData': webcastMessage,
                'type': messageType,
            },
        ],
    });
}

Future<void> _retrieveRoomId() async {
    try {
        var mainPageHtml = await _httpClient.getMainPage('@$_uniqueStreamerId/live');

        try {
            var roomId = getRoomIdFromMainPageHtml(mainPageHtml);

            _roomId = roomId;
            _clientParams['room_id'] = roomId;
        } catch (err) {
            // Use fallback method
            var roomData = await _httpClient.getJsonObjectFromTiktokApi('api-live/user/room/', {
                ..._clientParams,
                'uniqueId': _uniqueStreamerId,
                'sourceType': 54,
            });

            _roomId = roomData['data']['user']['roomId'];
            _clientParams['room_id'] = roomData['data']['user']['roomId'];
        }
    } catch (err) {
        throw Exception('Failed to retrieve room_id from page source. ${err.message}');
    }
}

Future<void> _fetchRoomInfo() async {
    try {
        var response = await _httpClient.getJsonObjectFromWebcastApi('room/info/', _clientParams);
        _roomInfo = response['data'];
    } catch (err) {
        throw Exception('Failed to fetch room info. ${err.message}');
    }
}

Future<void> _fetchAvailableGifts() async {
    try {
        var response = await _httpClient.getJsonObjectFromWebcastApi('gift/list/', _clientParams);
        _availableGifts = response['data']['gifts'];
    } catch (err) {
        throw Exception('Failed to fetch available gifts. ${err.message}');
    }
}

Future<void> _startFetchRoomPolling() async {
    _isPollingEnabled = true;

    Future<void> sleepMs(int ms) => Future.delayed(Duration(milliseconds: ms));

    while (_isPollingEnabled) {
        try {
            await _fetchRoomData(false);
        } catch (err) {
            _handleError(err, 'Error while fetching webcast data via request polling');
//7
                try {
            await _fetchRoomData(false);
        } catch (err) {
            _handleError(err, 'Error while fetching webcast data via request polling');
        }

        await sleepMs(_options['requestPollingIntervalMs']);
    }
}

Future<void> _fetchRoomData(bool isInitial) async {
    var webcastResponse = await _httpClient.getDeserializedObjectFromWebcastApi('im/fetch/', _clientParams, 'WebcastResponse', isInitial);
    var upgradeToWsOffered = webcastResponse['wsUrl'] != null && webcastResponse['wsParam'] != null;

    if (webcastResponse['cursor'] == null) {
        if (isInitial) {
            throw Exception('Missing cursor in initial fetch response.');
        } else {
            _handleError(null, 'Missing cursor in fetch response.');
        }
    }

    // Set cursor and internal_ext param to continue with the next request
    if (webcastResponse['cursor'] != null) _clientParams['cursor'] = webcastResponse['cursor'];
    if (webcastResponse['internalExt'] != null) _clientParams['internal_ext'] = webcastResponse['internalExt'];

    if (isInitial) {
        // Upgrade to Websocket offered? => Try upgrade
        if (_options['enableWebsocketUpgrade'] && upgradeToWsOffered) {
            await _tryUpgradeToWebsocket(webcastResponse);
        }
    }

    // Skip processing initial data if option disabled
    if (isInitial && !_options['processInitialData']) {
        return;
    }

    _processWebcastResponse(webcastResponse);
}

Future<void> _tryUpgradeToWebsocket(Map<String, dynamic> webcastResponse) async {
    try {
        // Websocket specific params
        var wsParams = {
            'imprp': webcastResponse['wsParam']['value'],
            'compress': 'gzip',
        };

        // Wait until ws connected, then stop request polling
        await _setupWebsocket(webcastResponse['wsUrl'], wsParams);

        _isWsUpgradeDone = true;
        _isPollingEnabled = false;

        emit(ControlEvents.WSCONNECTED, _websocket);
    } catch (err) {
        _handleError(err, 'Upgrade to websocket failed');
    }
}

Future<void> _setupWebsocket(String wsUrl, Map<String, dynamic> wsParams) async {
    _websocket = WebcastWebsocket(wsUrl, _httpClient.cookieJar, _clientParams, wsParams, _options['websocketHeaders'], _options['websocketOptions']);

    _websocket.on('connect', (wsConnection) {
        resolve();
    });
}
//8
        _websocket.on('connect', (wsConnection) {
        resolve();

        wsConnection.on('error', (err) => _handleError(err, 'Websocket Error'));
        wsConnection.on('close', () {
            disconnect();
        });
    });

    _websocket.on('connectFailed', (err) => reject('Websocket connection failed, $err'));
    _websocket.on('webcastResponse', (msg) => _processWebcastResponse(msg));
    _websocket.on('messageDecodingFailed', (err) => _handleError(err, 'Websocket message decoding failed'));

    // Hard timeout if the WebSocketClient library does not handle connect errors correctly.
    Timer(Duration(seconds: 30), () => reject('Websocket not responding'));
});

Future<void> _processWebcastResponse(Map<String, dynamic> webcastResponse) {
    // Emit raw (protobuf encoded) data for a use case specific processing
    webcastResponse['messages'].forEach((message) {
        emit(ControlEvents.RAWDATA, message['type'], message['binary']);
    });

    // Process and emit decoded data depending on the message type
    webcastResponse['messages']
        .where((x) => x['decodedData'] != null)
        .forEach((message) {
            var simplifiedObj = simplifyObject(message['decodedData']);

            emit(ControlEvents.DECODEDDATA, message['type'], simplifiedObj, message['binary']);

            switch (message['type']) {
                case 'WebcastControlMessage':
                    // Known control actions:
                    // 3 = Stream terminated by user
                    // 4 = Stream terminated by platform moderator (ban)
                    var action = message['decodedData']['action'];
                    if ([3, 4].contains(action)) {
                        emit(ControlEvents.STREAMEND, {'action': action});
                        disconnect();
                    }
                    break;
                case 'WebcastRoomUserSeqMessage':
                    emit(MessageEvents.ROOMUSER, simplifiedObj);
                    break;
                case 'WebcastChatMessage':
                    emit(MessageEvents.CHAT, simplifiedObj);
                    break;
//9
                            case 'WebcastChatMessage':
                        emit(MessageEvents.CHAT, simplifiedObj);
                        break;
                    case 'WebcastMemberMessage':
                        emit(MessageEvents.MEMBER, simplifiedObj);
                        break;
                    case 'WebcastGiftMessage':
                        // Add extended gift info if option enabled
                        if (_availableGifts is List && simplifiedObj['giftId'] != null) {
                            simplifiedObj['extendedGiftInfo'] = _availableGifts.firstWhere((x) => x['id'] == simplifiedObj['giftId'], orElse: () => null);
                        }
                        emit(MessageEvents.GIFT, simplifiedObj);
                        break;
                    case 'WebcastSocialMessage':
                        emit(MessageEvents.SOCIAL, simplifiedObj);
                        if (simplifiedObj['displayType']?.contains('follow') == true) {
                            emit(CustomEvents.FOLLOW, simplifiedObj);
                        }
                        if (simplifiedObj['displayType']?.contains('share') == true) {
                            emit(CustomEvents.SHARE, simplifiedObj);
                        }
                        break;
                    case 'WebcastLikeMessage':
                        emit(MessageEvents.LIKE, simplifiedObj);
                        break;
                    case 'WebcastQuestionNewMessage':
                        emit(MessageEvents.QUESTIONNEW, simplifiedObj);
                        break;
                    case 'WebcastLinkMicBattle':
                        emit(MessageEvents.LINKMICBATTLE, simplifiedObj);
                        break;
                    case 'WebcastLinkMicArmies':
                        emit(MessageEvents.LINKMICARMIES, simplifiedObj);
                        break;
                    case 'WebcastLiveIntroMessage':
//10
                            case 'WebcastLiveIntroMessage':
                        emit(MessageEvents.LIVEINTRO, simplifiedObj);
                        break;
                    case 'WebcastEmoteChatMessage':
                        emit(MessageEvents.EMOTE, simplifiedObj);
                        break;
                    case 'WebcastEnvelopeMessage':
                        emit(MessageEvents.ENVELOPE, simplifiedObj);
                        break;
                    case 'WebcastSubNotifyMessage':
                        emit(MessageEvents.SUBSCRIBE, simplifiedObj);
                        break;
                }
            });
    }

    void _handleError(dynamic exception, String info) {
        if (listenerCount(ControlEvents.ERROR) > 0) {
            emit(ControlEvents.ERROR, {'info': info, 'exception': exception});
        }
    }
}

class WebcastPushConnection {
    // Class implementation here
}

// Export statements

        
