# TikTok-Live-Connector
A dart library to receive live stream events such as comments and gifts in realtime from [TikTok LIVE](https://www.tiktok.com/live) by connecting to TikTok's internal WebCast push service. The package includes a wrapper that connects to the WebCast service using just the username (`uniqueId`). This allows you to connect to your own live chat as well as the live chat of other streamers. No credentials are required. Besides [Chat Comments](#chat), other events such as [Members Joining](#member), [Gifts](#gift), [Subscriptions](#subscribe), [Viewers](#roomuser), [Follows](#social), [Shares](#social), [Questions](#questionnew), [Likes](#like) and [Battles](#linkmicbattle) can be tracked. You can also send [automatic messages](#send-chat-messages) into the chat by providing your Session ID.


**NOTE:** This is not an official API. It's a reverse engineering project.





#### Overview
- [Getting started](#getting-started)
- [Params and options](#params-and-options)
- [Methods](#methods)
- [Events](#events)
- [Examples](#examples)
- [Contributing](#contributing)

## Getting started

1. Install the package via NPM
```
npm i tiktok-live-connector
```

2. Create your first chat connection

```javascript
const { WebcastPushConnection } = require('tiktok-live-connector');

// Username of someone who is currently live
let tiktokUsername = "officialgeilegisela";

// Create a new wrapper object and pass the username
let tiktokLiveConnection = new WebcastPushConnection(tiktokUsername);

// Connect to the chat (await can be used as well)
tiktokLiveConnection.connect().then(state => {
    console.info(`Connected to roomId ${state.roomId}`);
}).catch(err => {
    console.error('Failed to connect', err);
})

// Define the events that you want to handle
// In this case we listen to chat messages (comments)
tiktokLiveConnection.on('chat', data => {
    console.log(`${data.uniqueId} (userId:${data.userId}) writes: ${data.comment}`);
})

// And here we receive gifts sent to the streamer
tiktokLiveConnection.on('gift', data => {
    console.log(`${data.uniqueId} (userId:${data.userId}) sends ${data.giftId}`);
})

// ...and more events described in the documentation below
```

## Params and options

To create a new `WebcastPushConnection` object the following parameters are required.

`WebcastPushConnection(uniqueId, [options])`

| Param Name | Required | Description |
| ---------- | -------- | ----------- |
| uniqueId   | Yes | The unique username of the broadcaster. You can find this name in the URL.<br>Example: `https://www.tiktok.com/@officialgeilegisela/live` => `officialgeilegisela` |
| options  | No | Here you can set the following optional connection properties. If you do not specify a value, the default value will be used.<br><br>`processInitialData` (default: `true`) <br> Define if you want to process the initital data which includes old messages of the last seconds.<br><br>`fetchRoomInfoOnConnect` (default: `true`) <br> Define if you want to fetch all room information on [`connect()`](#methods). If this option is enabled, the connection to offline rooms will be prevented. If enabled, the connect result contains the room info via the `roomInfo` attribute. You can also manually retrieve the room info (even in an unconnected state) using the [`getRoomInfo()`](#methods) function.<br><br>`enableExtendedGiftInfo` (default: `false`) <br> Define if you want to receive extended information about gifts like gift name, cost and images. This information will be provided at the [gift event](#gift). <br><br>`enableWebsocketUpgrade` (default: `true`) <br> Define if you want to use a WebSocket connection instead of request polling if TikTok offers it. <br><br>`requestPollingIntervalMs` (default: `1000`) <br> Request polling interval if WebSocket is not used.<br><br>`sessionId` (default: `null`) <br> Here you can specify the current Session ID of your TikTok account (**sessionid** cookie value) if you want to send automated chat messages via the [`sendMessage()`](#methods) function. See [Example](#send-chat-messages)<br><br>`clientParams` (default: `{}`) <br> Custom client params for Webcast API.<br><br>`requestHeaders` (default: `{}`) <br> Custom request headers passed to [axios](https://github.com/axios/axios).<br><br>`websocketHeaders` (default: `{}`) <br> Custom websocket headers passed to [websocket.client](https://github.com/theturtle32/WebSocket-Node). <br><br>`requestOptions` (default: `{}`) <br> Custom request options passed to [axios](https://github.com/axios/axios). Here you can specify an `httpsAgent` to use a proxy and a `timeout` value. See [Example](#connect-via-proxy). <br><br>`websocketOptions` (default: `{}`) <br> Custom websocket options passed to [websocket.client](https://github.com/theturtle32/WebSocket-Node). Here you can specify an `agent` to use a proxy and a `timeout` value. See [Example](#connect-via-proxy). |
