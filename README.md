# Capacitor Jitsi Meet
## Development starts May 1st, 2025

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
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>✅</td>
      <td>Create plugin structure</td>
    </tr>
    <tr>
      <td>❌</td>
      <td>Integrate SDK Libraries</td>
    </tr>
    <tr>
      <td>❌</td>
      <td>Plugin integration with Capacitor Bridge</td>
    </tr>
    <tr>
      <td>❌</td>
      <td>Picture in Picture</td>
    </tr>
    <tr>
      <td>❌</td>
      <td>Basic UI Customization trough SDK flags</td>
    </tr>
    <tr>
      <td>❌</td>
      <td>Advanced UI Customization</td>
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
        initial
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
        May 3, 2025
      </td>
    </tr>
  </tbody>
</table>

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
