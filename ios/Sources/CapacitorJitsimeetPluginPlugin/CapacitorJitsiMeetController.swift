import Foundation
import Capacitor
import JitsiMeetSDK
import UIKit
import WebKit

public class CapacitorJitsiMeetController: UIViewController, UIGestureRecognizerDelegate {

    fileprivate var jitsiMeetView: UIView?
    var options: JitsiMeetConferenceOptions? = nil
    weak var delegate: JitsiMeetViewControllerDelegate?
    fileprivate var pipViewCoordinator: PiPViewCoordinator?

    var webView: WKWebView? = nil;

    public override func viewDidLoad() {
        super.viewDidLoad()
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::viewDidLoad");
        openJitsiMeet();
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        pipViewCoordinator?.resetBounds(bounds: rect)
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::viewWillTransition");
    }

    func openJitsiMeet() {
        cleanUp()

        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::openJitsiMeet");

        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        jitsiMeetView.join(options)

        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)

        pipViewCoordinator?.show()
        // uncomment line below to start meet in pip mode
        // enterPicture(inPicture: [:])
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::viewDidDisappear");
        cleanUp();
    }

    fileprivate func cleanUp() {
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::cleanUp");
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
    }

    public func leave() {
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::leave");
        let jitsiMeetView = JitsiMeetView()
        self.jitsiMeetView = jitsiMeetView
        jitsiMeetView.hangUp()
    }
}

protocol CapacitorJitsiMeetControllerDelegate: AnyObject {
    func onConferenceJoined()
    func onConferenceLeft()
    func onChatMessageReceived(_ dataString: String)
    func onParticipantsInfoRetrieved(_ dataString: String)
}

// MARK: JitsiMeetViewDelegate
extension CapacitorJitsiMeetController: JitsiMeetViewDelegate {
    public func enterPicture(inPicture data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.enterPictureInPicture()
    }
    
    public func exitPictureInPicture(inPicture data: [AnyHashable : Any]!) {
       self.pipViewCoordinator?.exitPictureInPicture()
    }

    @objc public func conferenceJoined(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::conference joined");
        delegate?.onConferenceJoined()
        Task {
            // print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::retrieveParticipantsInfo");
            let jitsiMeetView = JitsiMeetView()
            self.jitsiMeetView = jitsiMeetView
            await jitsiMeetView.retrieveParticipantsInfo({ (_ data: Any) -> Void in
                if let theJSONData = try?  JSONSerialization.data(
                      withJSONObject: data,
                      options: .prettyPrinted
                      ),
                      let theJSONText = String(data: theJSONData,
                                           encoding: String.Encoding.ascii) {
                      print("JSON string = \n\(theJSONText)")
                    self.delegate?.onParticipantsInfoRetrieved(theJSONText)
                }
            });
        }
    }

    public func ready(toClose data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.hide() { _ in
            self.cleanUp()
        }
    }

    @objc public func conferenceTerminated(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::conference terminated");
        delegate?.onConferenceLeft()
        self.cleanUp()

        self.dismiss(animated: true, completion: nil); // e.g. user ends the call. This is preferred over conferenceLeft to shorten the white screen while exiting the room
    }

    @objc public func chatMessageReceived(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: CapacitorJitsiMeetController::chat message received");
        if let theJSONData = try?  JSONSerialization.data(
              withJSONObject: data,
              options: .prettyPrinted
              ),
              let theJSONText = String(data: theJSONData,
                                   encoding: String.Encoding.ascii) {
              print("JSON string = \n\(theJSONText)")
            delegate?.onChatMessageReceived(theJSONText)
        }
    }

}
