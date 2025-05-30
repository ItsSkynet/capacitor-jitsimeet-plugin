import Foundation
import Capacitor
import JitsiMeetSDK
import UIKit

@objc(CapacitorJitsiMeetPlugin)
public class CapacitorJitsiMeetPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "CapacitorJitsiMeetPlugin"
    public let jsName = "JitsiMeet"
    public let pluginMethods: [CAPPluginMethod] = [
        CAPPluginMethod(name: "joinRoom", returnType: CAPPluginReturnPromise),
        CAPPluginMethod(name: "leaveRoom", returnType: CAPPluginReturnPromise)
    ]
    private let implementation = CapacitorJitsiMeetPlugin()
    var jitsiMeetViewController: JitsiMeetViewController?

    @objc func joinRoom(_ call: CAPPluginCall) {
        let podBundle = Bundle(for: JitsiMeetViewController.self)
        let bundleURL = podBundle.url(forResource: "Plugin", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!

        let storyboard = UIStoryboard(name: "JitsiMeet", bundle: bundle)
        self.jitsiMeetViewController = storyboard.instantiateViewController(withIdentifier: "CapacitorjitsiMeetStoryBoard") as? JitsiMeetViewController
        guard let url = call.options["url"] as? String else {
            call.reject("Call to jitsi requires a valid URL")
            return
        }
        guard let roomName = call.options["roomName"] as? String else {
            call.reject("Jitsi requires a Room Name to initialize")
            return
        }
        let subject = call.options["subject"] as? String ?? " "

        self.jitsiMeetViewController?.webView = self.webView

        self.jitsiMeetViewController?.options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
            builder.serverURL = URL(string: url)
            builder.room = roomName
            builder.setSubject(subject)
            if let token = call.options["token"] as? String {
                builder.token = token;
            }
            if let isAudioMuted = call.options["startWithAudioMuted"] as? Bool {
                builder.setAudioMuted(isAudioMuted);
            }
            if let isAudioOnly = call.options["isAudioOnly"] as? Bool {
                builder.setAudioOnly(isAudioOnly)
            }
            if let isVideoMuted = call.options["startWithVideoMuted"] as? Bool {
                builder.setVideoMuted(isVideoMuted)
            }

            let displayName = call.options["displayName"] as? String
            let email = call.options["email"] as? String
            let avatarUrlString = call.options["avatarURL"] as? String
            if (displayName != nil || email != nil || avatarUrlString != nil) {
                let avatarUrl = avatarUrlString != nil ? URL(string: avatarUrlString!) : nil
                builder.userInfo = JitsiMeetUserInfo(displayName: displayName, andEmail: email, andAvatar: avatarUrl)
            }

            if let pipEnabled = call.options["pipEnabled"] as? Bool {
                builder.setFeatureFlag("pip.enabled", withBoolean: pipEnabled)
            }
            if let chatEnabled = call.options["chatEnabled"] as? Bool {
                builder.setFeatureFlag("chat.enabled", withBoolean: chatEnabled)
            }
            if let inviteEnabled = call.options["inviteEnabled"] as? Bool {
                builder.setFeatureFlag("invite.enabled", withBoolean: inviteEnabled)
            }

            let featureFlags = call.options["featureFlags"] as? Dictionary<String, Any>
            featureFlags?.forEach { key, value in
                var readValue = value
                if (key == "call-integration.enabled") {
                    let userLocale = NSLocale.current as NSLocale
                    if  userLocale.countryCode?.contains("CN") ?? false ||
                        userLocale.countryCode?.contains("CHN") ?? false ||
                        userLocale.countryCode?.contains("MO") ?? false ||
                        userLocale.countryCode?.contains("HK") ?? false {
                        print("Locale is set to China, CallKit will be unavailable.")
                        readValue = false
                    }
                }
                builder.setFeatureFlag(key, withValue: readValue);
            }
            #if DEBUG
                builder.setFeatureFlag("call-integration.enabled", withValue: false);
                print("Disable CallKit for debug mode - prevents call from disconnecting in simulated environments.")
            #endif

            let configOverrides = call.options["configOverrides"] as? Dictionary<String, Any>
            configOverrides?.forEach { key, value in
                builder.setConfigOverride(key, withValue: value);
            }
        }

        self.jitsiMeetViewController?.delegate = self;

        DispatchQueue.main.async {
            self.bridge?.viewController?.present(self.jitsiMeetViewController!, animated: true, completion: { call.resolve(["success": true ]) });
        }
    }
    
    @objc func leaveRoom(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.jitsiMeetViewController?.leave();
            call.resolve([
                "success": true
            ])
        }
    }
}
