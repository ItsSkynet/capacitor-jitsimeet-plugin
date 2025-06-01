//
//  JitsiMeetViewController.swift
//  Plugin
//
//  Created by Calvin Ho on 1/25/19.
//

import Foundation
import UIKit
import JitsiMeetSDK
import WebKit

public class JitsiMeetViewController: UIViewController, UIGestureRecognizerDelegate {

    fileprivate var jitsiMeetView: UIView?
    var options: JitsiMeetConferenceOptions? = nil
    weak var delegate: JitsiMeetViewControllerDelegate?
    fileprivate var pipViewCoordinator: PiPViewCoordinator?

    var webView: WKWebView? = nil;

    public override func viewDidLoad() {
        super.viewDidLoad()
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewDidLoad");
        openJitsiMeet();
    }

    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let rect = CGRect(origin: CGPoint.zero, size: size)
        pipViewCoordinator?.resetBounds(bounds: rect)
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::viewWillTransition");
    }

    func openJitsiMeet() {
        cleanUp()

        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::openJitsiMeet");

        // create and configure the absorbPointerView and jitsimeet view
        let jitsiMeetView = JitsiMeetView()
        jitsiMeetView.delegate = self
        self.jitsiMeetView = jitsiMeetView
        jitsiMeetView.join(options)

        // Enable jitsimeet view to be a view that can be displayed
        // on top of all the things, and let the coordinator to manage
        // the view state and interactions
        // pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        // pipViewCoordinator?.configureAsStickyView(withParentView: view)
        
        //New code by Amol
        pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
        pipViewCoordinator?.configureAsStickyView(withParentView: view)
        
        // animate in
        //jitsiMeetView.alpha = 0
        pipViewCoordinator?.show()
        // uncomment line below to start meet in pip mode
        // enterPicture(inPicture: [:])
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
}

// MARK: JitsiMeetViewDelegate
extension JitsiMeetViewController: JitsiMeetViewDelegate {
    public func enterPicture(inPicture data: [AnyHashable : Any]!) {
        self.pipViewCoordinator?.enterPictureInPicture()
    }
    
    public func exitPictureInPicture(inPicture data: [AnyHashable : Any]!) {
       self.pipViewCoordinator?.exitPictureInPicture()
    }

    @objc public func conferenceJoined(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::conference joined");
        delegate?.onConferenceJoined()
        Task {
            // print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::retrieveParticipantsInfo");
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
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::conference terminated");
        delegate?.onConferenceLeft()
        self.cleanUp()

        self.dismiss(animated: true, completion: nil); // e.g. user ends the call. This is preferred over conferenceLeft to shorten the white screen while exiting the room
    }

    @objc public func chatMessageReceived(_ data: NSDictionary) {
        print("[Jitsi Plugin Native iOS]: JitsiMeetViewController::chat message received");
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
