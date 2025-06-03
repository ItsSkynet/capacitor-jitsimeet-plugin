import Foundation
import UIKit
import JitsiMeetSDK
import WebKit

public class JitsiMeetViewController: UIViewController, UIGestureRecognizerDelegate {

    fileprivate var jitsiMeetView: UIView?
    var options: JitsiMeetConferenceOptions? = nil
    weak var delegate: JitsiMeetViewControllerDelegate?
    internal var pipViewCoordinator: PiPViewCoordinator?

    var webView: WKWebView? = nil;

    public override func viewDidLoad() {
        super.viewDidLoad()
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewDidLoad");
        openJitsiMeet();
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewWillTransition");
    }

    func openJitsiMeet() {
        cleanUp()

        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::openJitsiMeet");

        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        jitsiMeetView.join(options)
        
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)

        // animate in
        jitsiMeetView.alpha = 1
        jitsiMeetView.backgroundColor = .clear
        pipViewCoordinator?.show()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewDidDisappear");
        cleanUp();
    }

    fileprivate func cleanUp() {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::cleanUp");
        
        jitsiMeetView?.removeFromSuperview()
        jitsiMeetView = nil
        pipViewCoordinator = nil
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    public func leave() {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::leave");
        let jitsiMeetView = JitsiMeetView()
        self.jitsiMeetView = jitsiMeetView
        jitsiMeetView.hangUp()
    }
}

protocol JitsiMeetViewControllerDelegate: AnyObject {
    func onConferenceJoined()
    func onConferenceLeft()
    func onChatMessageReceived(_ dataString: String)
    func onParticipantsInfoRetrieved(_ dataString: String)
    func onCustomButtonPressed(_ dataString: String)
}

// MARK: JitsiMeetViewDelegate
extension JitsiMeetViewController: JitsiMeetViewDelegate {
    public func enterPicture(inPicture data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.hide()
    }
    
    public func exitPictureInPicture(inPicture data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.show()
    }
    
    @objc public func conferenceJoined(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::conference joined");
        delegate?.onConferenceJoined()
        Task {
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

    @objc public func ready(toClose: [AnyHashable : Any]!) {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::ready to close");
        delegate?.onConferenceLeft()
        self.pipViewCoordinator?.hide() { _ in
            self.cleanUp()
        }

        self.dismiss(animated: true, completion: nil);
    }

    @objc public func conferenceTerminated(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::conference terminated");
        delegate?.onConferenceLeft()
        self.cleanUp()

        self.dismiss(animated: true, completion: nil);
    }

    @objc public func customOverflowMenuButtonPressed(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: Custom button pressed")

        if let jsonData = try? JSONSerialization.data(withJSONObject: data, options: .prettyPrinted),
           let jsonString = String(data: jsonData, encoding: .utf8) {
            delegate?.onCustomButtonPressed(jsonString)
        }
    }


}
