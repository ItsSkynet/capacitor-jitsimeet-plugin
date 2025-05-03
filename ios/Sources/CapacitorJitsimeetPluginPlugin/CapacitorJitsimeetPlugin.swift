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

    @objc func joinRoom(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.joinRoom(value)
        ])
    }
    
    @objc func leaveRoom(_ call: CAPPluginCall) {
        let value = call.getString("value") ?? ""
        call.resolve([
            "value": implementation.leaveRoom(value)
        ])
    }
}
