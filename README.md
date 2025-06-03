# Capacitor Jitsi Meet
## Maintained by CollabWorkx.com
[![NPM](https://img.shields.io/badge/NPM-%23CB3837.svg?style=for-the-badge&logo=npm&logoColor=white)](https://www.npmjs.com/package/@collabworkx/capacitor-jitsimeet-plugin)

A plugin that enables Ionic Capacitor to access Jitsi Meet Conferences for iOS and Android.

Featuring:
- Picture in Picture
- Video Calls
- Audio Calls
- Breakout Rooms
- Waiting Rooms
- Integrated Chat
- Moderation Controls
- and more...

## Road Map
<table>
  <thead>
    <tr>
      <th>Status</th>
      <th>Task</th>
      <th>Notes</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>✅</td>
      <td>Create plugin structure</td>
      <td></td>
    </tr>
    <tr>
      <td>✅</td>
      <td>Integrate SDK Libraries</td>
      <td></td>
    </tr>
    <tr>
      <td>✅</td>
      <td>Plugin integration with Capacitor Bridge</td>
      <td></td>
    </tr>
    <tr>
      <td>✅</td>
      <td>Picture in Picture</td>
      <td>Custom PiP using WebView</td>
    </tr>
    <tr>
      <td>✅</td>
      <td>Basic UI Customization trough SDK flags</td>
      <td></td>
    </tr>
    <tr>
      <td>✅</td>
      <td>Advanced UI Customization</td>
      <td></td>
    </tr>
  </tbody>
</table>

## Compatibility
<table>
  <thead>
    <tr>
      <th>Release</th>
      <th>Capacitor</th>
      <th>Xcode</th>
      <th>Android Studio</th>  
      <th>Maintained</th>
      <th>Last Update</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>
        0.1.4
      </td>
      <td>
        >= 7.0.0
      </td>
      <td>
        >=16.0
      </td>
      <td>
        >= 2024.2.1
      </td>
      <td>
        ✅
      </td>
      <td>
        June 2, 2025
      </td>
    </tr>
  </tbody>
</table>


## Usage
1. Install pluging trough NPM or Git
```
@collabworkx/capacitor-jitsimeet-plugin
```
2. Add it to your JS module and call it
```javascript
import { Jitsi } from "@collabworkx/capacitor-jitsimeet-plugin";

const result = await Jitsi.joinConference({
    // required parameters
    roomName: 'room1', // room identifier for the conference
    url: 'https://meet.jit.si', // endpoint of the Jitsi Meet video bridge

    // recommended settings for production build. see full list of featureFlags in the official Jitsi Meet SDK documentation
    featureFlags: {
        'prejoinpage.enabled': false, // go straight to the meeting and do not show the pre-join page
        'recording.enabled': false, // disable as it requires Dropbox integration
        'live-streaming.enabled': false, // 'sign in on Google' button not yet functional
        'android.screensharing.enabled': false, // experimental feature, not fully production ready
        'pip.enabled': false, // flag that enables PiP mode
    },

    // optional parameters
    subject: string, // name of the video room
    displayName: string, // user's display name
    email: string, // user's email
    avatarURL: string, // user's avatar url
    startWithAudioMuted: true, // start with audio muted, default: false
    startWithVideoMuted: false, // start with video muted, default: false
    chatEnabled: false, // enable Chat feature, default: true
    inviteEnabled: false, // enable Invitation feature, default: true

    // advanced parameters (optional)
    token: string, // jwt authentication token
    configOverrides: { 'p2p.enabled': false }, // see list of config overrides in the official Jitsi Meet SDK documentation
});
console.log(result) // { success: true }

window.addEventListener('onConferenceJoined', () => {
    // do things here
});
window.addEventListener('onConferenceTerminated', () => {
    // do things here
});
window.addEventListener('onConferenceLeft', () => {
    // do things here
});
window.addEventListener('onChatMessageReceived', (data: any) => {
    // console.log("message", JSON.stringify(data))
    // {"isTrusted":false,"senderId":"00b50123","isPrivate":"false","message":"this is the message","timestamp":"2024-09-16T18:53:34Z"}
});
window.addEventListener('onParticipantsInfoRetrieved', (data: any) => {
    // console.log("participant info", JSON.stringify(data));
    //{"isTrusted":false,"participantsInfo":"[{participantId=00b50123, name=My Name, role=moderator, avatarUrl=https://xxx.png, isLocal=true}
});

const result = await Jitsi.leaveConference()
console.log(result) // { success: true }
```

## Customization

### Custom Toolbar Buttons
This build features customization options using customToolbarButtons config overrides (THANKS TO @dima887 for this wonderful code)
```javascript
const result = await Jitsi.joinConference({
    // required parameters
    roomName: 'room1', // room identifier for the conference
    url: 'https://meet.jit.si', // endpoint of the Jitsi Meet video bridge

    // optional parameters
    configOverrides: {
        customToolbarButtons: [
            {
                icon: 'https://w7.pngwing.com/pngs/987/537/png-transparent-download-downloading-save-basic-user-interface-icon-thumbnail.png',
                id: 'btn1',
                text: 'Button one'
            },
            {
                icon: 'https://w7.pngwing.com/pngs/987/537/png-transparent-download-downloading-save-basic-user-interface-icon-thumbnail.png',
                id: 'btn2',
                text: 'Button two'
            }
        ]
    },
});

const handleCustomButton = async (event) => {
    try {
        const { id, text } = event;
        if (id === 'btn1') {
            console.log(id, text);
            // do things here
        } else if (id === 'btn2') {
            console.log(id, text);
            // do things here
        }
    } catch (e) {
        console.error('Error parsing custom button event:', e);
    }
};

window.addEventListener('onCustomButtonPressed', handleCustomButton);
```
### Custom PiP information
This PiP Mode relies on building custom interfaces that display conference information, PiP mode natively for Jitsi is at this point nearly impossible to implement without reliying on low performance gestureDelegations that need to be passed on to the webview scope.
For now, this can be used to create minimized views similar to whatsapp. Newer updates on call start will try to give back RTCVideo information to preview.

The following methods have been made available to JS land, current PiP view button inside the Jitsi Meet view will execute "HideConference".
```javascript
await Jitsi.hideConference();
await Jitsi.showConference();
```

## Official Jitsi-Meet SDK Documentation and constants

This plugin uses Jitsi Meet SDK for IOS and Android:
- [IOS SDK documentation](https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-ios-sdk)
- [Android SDK documentation](https://jitsi.github.io/handbook/docs/dev-guide/dev-guide-android-sdk/)
- [List of feature flags](https://github.com/jitsi/jitsi-meet/blob/master/react/features/base/flags/constants.ts)
- [List of config overrides](https://github.com/jitsi/jitsi-meet/blob/master/config.js).

## Jitsi Infrastructure Requirements
This plugin is made to integrate with Jitsi Meet, It is possible to run this plugin with https://meet.jitsi.si, however Jitsi warns developers to use it ONLY for development purposes due to service configuration not apt for production. Meetings created with development environment will be limited to 5 minutes. Additionally, development environment no longer allows anonymous conferences as stated in their blog published on Aug 22, 2023: [Authentication on meet.jit.si](https://jitsi.org/blog/authentication-on-meet-jit-si/)

For production please use either one of these solutions below:
- [JaaS - Jitsi as a Service](https://jaas.8x8.vc/) - PAID💲
- [Self hosting](https://jitsi.github.io/handbook/docs/devops-guide/) - FREE Software, requires a server to host

## Contributing
If you are looking to contribute to the development of this plugin, feel free to fork it and push updates to this repository!

This plugin is being released to all using the Apache License 2.0.
Jitsi Meet SDK for IOS and Android are licensed trough Apache License 2.0, please visit [Jitsi Github](https://github.com/jitsi) for more information and repositories.
