import Foundation
import Capacitor
import JitsiMeetSDK
import UIKit
import WebKit

@objc public class CapacitorJitsiMeetPlugin: NSObject {
    @objc public func joinRoom(_ value: String) -> String {
        print(value)
        return value
    }
    @objc public func leaveRoom(_ value: String) -> String {
        print(value)
        return value
    }
}
