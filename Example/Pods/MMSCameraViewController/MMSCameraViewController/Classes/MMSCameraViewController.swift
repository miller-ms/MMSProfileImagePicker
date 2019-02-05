//
//  MMSCameraViewController.swift
//  Pods
//
//  Created by William Miller on 9/3/16.
//
//
//  Copyright (c) 2016 William Miller <support@millermobilesoft.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import AVFoundation


@objc open class MMSCameraViewController: UIViewController {
    
// MARK: Properties
    
    /// Context for observing session property capturingStillImage
    fileprivate var CaptureStillImageContext = false
    
    /// Application delegate
    @objc open var delegate: MMSCameraViewDelegate! = nil
    
    /// Session for capturing still images
    let photoSession:AVCaptureSession = {
        let session = AVCaptureSession()
        session.sessionPreset = AVCaptureSession.Preset.photo
        return session
    }()
    
    /// Front or back camera device
    var cameraDevice:AVCaptureDevice!
    
    /// camera's capture input
    var cameraInput:AVCaptureDeviceInput!

    /// camera's preview layer
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer!
    
    /// Set when orientation changes
    var lastOrientation:UIDeviceOrientation = .portrait

    /// Camera's capture output
    let stillImageOutput:AVCaptureStillImageOutput = {
        let output = AVCaptureStillImageOutput()
        let outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG, AVVideoProfileLevelKey:AVVideoProfileLevelH264BaselineAutoLevel, AVVideoQualityKey:NSNumber(value: 1.0) as Any]
        output.outputSettings = outputSettings
        return output
    }()
    
    /// Queue for processing camera operations asynchronously
    let cameraQueue = DispatchQueue(label: "com.millermobilesoft.camera.queue", attributes: [])
    
    /// The view presenting the camera preview and controls
    var cameraView:CameraView {
        return view as! CameraView
    }
    
    
// MARK: Initialization and termination
    
    /**
        Initializes the camera view from the nib file
 
    */
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        var nibName = nibNameOrNil
        
        var nibBundle = nibBundleOrNil
        
        if nibBundle == nil {
            
            nibBundle = Bundle(for: MMSCameraViewController.self)
            
        }
        
        if nibName == nil {
            
            nibName = "MMSCameraViewController"
        }
        
        super.init(nibName: nibName, bundle: nibBundle)
        
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        
        fatalError("init(coder:) has not been implemented")
    }
    /**
        The status bar is hidden when the camera displays
    */
    override open var prefersStatusBarHidden : Bool {
        return true
    }
    
    /**
        The only supported interface is portrait
    */
    override open var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    /**
        Get the current device orientation when the view loads
    */
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        lastOrientation = deviceOrientation(lastOrientation)

    }
    
    /**
        Change the preview constraints when the view is about to appear if the device's aspect ratio is 3:4.
    */
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        cameraView.snapBtn.setImage(UIImage(named: "snappressed", in: Bundle(for: MMSCameraViewController.self), compatibleWith: nil), for: .highlighted)
        
        let width = UIScreen.main.bounds.size.width
        let height = UIScreen.main.bounds.size.height
        let aspect1 = width / height
        let aspect2 = height / width
        
        // if the screens aspect ratio is 3:4 then change the preview's aspect ratio constraint to 3:4
        if aspect1 == 0.75 || aspect2 == 0.75 {
            
            for constraint in cameraView.previewView.constraints {
                if constraint.identifier == "aspectratio" {
                    
                    constraint.constant = 0.75
                    
                    break
                    
                }
            }
        }

        // Set the background colors to black and 50% transparent
        cameraView.bottomBarView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        cameraView.topBarView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.5)
        
    }
    
    /**
        When the view appears authorize the camera before using.
    */
    override open func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        authorizeCamera()
        
    }
    
    /**
        When the view is about to disappear, deallocate all the objects created to support the camera session
    */
    override open func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        
        dismantleCamera()
        
    }
    
    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
        Checks if the user has granted permission for this application to use the camera.  If not, it presents a dialog to the user to chose to grant the camera permission.
    */
    fileprivate func authorizeCamera() -> Void {
        
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { granted in
                
                if granted {
                    self.setupCamera()
                }
                
            }
        case .denied, .restricted:
            fallthrough
        default:
            return
        }
        
    }
    
    /**
        Configures the lens positioned on the back of the device for taking still photos. Arranges for the images to be presented in the preview window, starts the session, and adds observers for critical notifications.
 
    */
    fileprivate func setupCamera () -> Void {
        
        activateCameraDevice(findCameraDevice(withPosition: AVCaptureDevice.Position.back))
        
        DispatchQueue.main.async {
            
            self.setupPreview(self.cameraView.previewView, forSession: self.photoSession)
            self.addObservers()
            self.photoSession.startRunning()
            
        }
        
        
    }
    
    /**
        Frees all the resources allocated for supporting a camera session.
    */
    fileprivate func dismantleCamera () -> Void {
        
        removeObservers()
        
        photoSession.stopRunning()
        
        deactivateCamera()
        
    }
    /**
        Searches for the camera positioned with the input parameter and returns it.
     
        - Parameter: the position of the camera to return
     
        - Returns: The AVCaptureDevice with input position or nil if non was found
    */
    fileprivate func findCameraDevice (withPosition position: AVCaptureDevice.Position) -> AVCaptureDevice! {
        
        var videoDevices:[AVCaptureDevice] = AVCaptureDevice.devices(for: .video)

        if #available(iOS 10.2, *) {
             videoDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera,.builtInTelephotoCamera], mediaType: .video, position: AVCaptureDevice.Position.unspecified).devices
        } else {
            // Fallback on earlier versions
            videoDevices = AVCaptureDevice.devices(for: .video)
        }
        
        return videoDevices.filter{ $0.position == position }.first
    }
    
    /**
        Creates the preview object for the current session and connects it the preview view.
     
        - Parameters:
            - previewView: The view that will display the camera's preview.
            - captureSession: The session to create a preview.
    */
    
    fileprivate func setupPreview(_ previewView: UIView, forSession captureSession: AVCaptureSession) -> Void {
        
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        captureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        captureVideoPreviewLayer.frame = previewView.bounds
        
        previewView.layer.addSublayer(captureVideoPreviewLayer)
        
    }
    
    /**
     
        Configures the device for capturing a still image.
     
        - Parameter device: The camera device.
     
    */
    fileprivate func activateCameraDevice(_ device:AVCaptureDevice!) -> Void {
        
        // Return immediately if the device is nil
        guard device != nil else {
            
            return
        }
        
        // Start the configuration
        photoSession.beginConfiguration()
        
        
        // create device input object for the device.
        
        cameraInput = try? AVCaptureDeviceInput(device: device)
        
        // add the input to the photo session
        if photoSession.canAddInput(cameraInput) {
            
            photoSession.addInput(cameraInput)
            
        }
        
        // add the output to the photo session.
        if photoSession.canAddOutput(stillImageOutput) {
            
            photoSession.addOutput(stillImageOutput)
            
        }
        
        // lock the device while configuring the flash mode to autoflash
        do {
            
            try device.lockForConfiguration()
            
            if device.hasFlash {
                device.flashMode = .auto
            }
            
            device.unlockForConfiguration()
            
        } catch _ { }
        
        // End the configuration by committing it
        photoSession.commitConfiguration()
        
        
        // Make the device active
        cameraDevice = device
        
    }
    
    
    /**
        Removes the active device's input and output from the session.
    */
    fileprivate func deactivateCamera () -> Void {
        
        photoSession.beginConfiguration()
        
        photoSession.removeInput(cameraInput)
        
        photoSession.removeOutput(stillImageOutput)
        
        photoSession.commitConfiguration()
        
    }
    
    /**
        Enables the camera UI controls
    */
    func enableControls() -> Void {
        
        // if there if there is no active camera then disable all the controls.
        guard cameraDevice != nil else {
            
            cameraView.snapBtn.isEnabled = false
            cameraView.flashBtn.isEnabled = false
            cameraView.cameraBtn.isEnabled = false
            return
        }
        
        // if the camera has a flash make it visible and enable it otherwise make it hidden.
        if cameraDevice.hasFlash {
            cameraView.flashBtn.isHidden = false
            cameraView.flashBtn.isEnabled = true
        } else {
            
            cameraView.flashBtn.isHidden = true
        }
        
        // The snap and swap camera buttons are always enabled
        cameraView.snapBtn.isEnabled = true
        cameraView.cameraBtn.isEnabled = true
        
    }
    
    /**
        Disables camera UI controls
    */
    func disableControls() -> Void {
        
        // if there is no active camera then disable all the controls.
        guard cameraDevice != nil else {
            
            cameraView.snapBtn.isEnabled = false
            cameraView.flashBtn.isEnabled = false
            cameraView.cameraBtn.isEnabled = false
            return
        }
        
        // if the camera has a flash make it disabled and hiddent it otherwise make it hidden.
        if cameraDevice.hasFlash {
            cameraView.flashBtn.isHidden = false
            cameraView.flashBtn.isEnabled = false
        } else {
            cameraView.flashBtn.isHidden = true
        }
        
        // The snap and swap camera buttons are always disabled in this call.
        cameraView.snapBtn.isEnabled = false
        cameraView.cameraBtn.isEnabled = false
        
    }
    
// MARK: Capture
    
    /**
        Searches the device's output connection for a video media type and returns it.
     
        - Returns: A capture connection of video type.
    */
    fileprivate func findVideoConnection() -> AVCaptureConnection? {
        
        var videoConnection: AVCaptureConnection! = nil
        
        connectionloop: for connection in stillImageOutput.connections {
            
            guard (connection as AnyObject).inputPorts != nil else {
                
                continue
                
            }
            
            for port in (connection ).inputPorts {
                if (port ).mediaType == AVMediaType.video {
                    videoConnection = connection 
                    break connectionloop
                }
            }
        }
        
        return videoConnection
        
    }
    
    /**
        Captures a still image, converts it to a UIImage, and passes it back on the delegate method.
    */
    fileprivate func captureStillImage() -> Void {
        
        // find a video connection on the devices output return immediately if one was not found.
        let videoConnection = findVideoConnection()
        
        guard videoConnection != nil else {
            
            return
        }
        
        // capture the still image currently in the camera's focus
        stillImageOutput.captureStillImageAsynchronously(from: videoConnection!)
        { buffer, error in
                        
            
            guard buffer != nil, let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer!) else {
                self.cameraView.enableSnapButton()
                return
            }
            
            // determine the orientation of the device in order to set the orientation correctly in the UIImage.
            let device = UIDevice.current
            
            var imageOrientation = UIImage.Orientation.up
            
            switch device.orientation {
                
            case .portrait:
                imageOrientation = UIImage.Orientation.right
            case .portraitUpsideDown:
                imageOrientation = UIImage.Orientation.left
            case .landscapeLeft:
                if self.cameraDevice?.position == .back {
                    imageOrientation = UIImage.Orientation.up
                } else {
                    imageOrientation = UIImage.Orientation.downMirrored
                }
            case .landscapeRight:
                if self.cameraDevice?.position == .back {
                    imageOrientation = UIImage.Orientation.down
                } else {
                    imageOrientation = UIImage.Orientation.upMirrored
                }
            case .unknown:
                print("Device orientation has unknown value.")
                
            case .faceDown, .faceUp:
                // if the orientatino is faceup or facedown than use the last orientation for the image.
                imageOrientation = {
                    switch self.lastOrientation {
                    case .landscapeLeft:
                        return UIImage.Orientation.up
                    case .landscapeRight:
                        return UIImage.Orientation.down
                    case .portrait:
                        return UIImage.Orientation.right
                    case .portraitUpsideDown:
                        return UIImage.Orientation.left
                    default:
                        return UIImage.Orientation.right
                    }
                } ()
            }
            
            // convert the captured data into a UIImage
            var cameraImage = UIImage(data: imageData)
            
            // convert the UIImage into a new UIImage to give it the proper orientation
            cameraImage = UIImage(cgImage: cameraImage!.cgImage!, scale: 1.0, orientation: imageOrientation)
            
            // Pass the UIImage back on the delegate.
            self.delegate.cameraDidCaptureStillImage(cameraImage!, camera: self)
            
            self.cameraView.enableSnapButton()
            
        }
        
        
    }
    
// MARK: KVO and Notifications
    /**
        Setup the observers to become notified when the camera is capturing an image, changes to the session, and device orientation
    */
    fileprivate func addObservers() -> Void {
        
        stillImageOutput.addObserver(self, forKeyPath: "capturingStillImage", options: NSKeyValueObservingOptions.new, context: &CaptureStillImageContext)
        
        addSessionObservers()
        
        addOrientationObserver()
        
    }
    
    /**
        Removes all the created observers.
    */
    fileprivate func removeObservers() -> Void {
        
        stillImageOutput.removeObserver(self, forKeyPath: "capturingStillImage")
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
    /**
        Add observers to become notified when the session started and ended, the session interrupted, and an error was detected.
    */
    fileprivate func addSessionObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifySessionStarted),
            name: NSNotification.Name.AVCaptureSessionDidStartRunning,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifySessionWasInterrupted),
            name: NSNotification.Name.AVCaptureSessionWasInterrupted,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifySessionRuntimeError),
            name: NSNotification.Name.AVCaptureSessionRuntimeError,
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notiySessionInterruptionEnded),
            name: NSNotification.Name.AVCaptureSessionInterruptionEnded,
            object: nil)
        
    }
    
    /**
        Become notified when the user flipped the device.
    */
    fileprivate func addOrientationObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(notifyOrientationChanged),
            name: UIDevice.orientationDidChangeNotification,
            object: nil)
    }
    
    /**
        Enable the camera's UI controls when the session has started.
    */
    @objc internal func notifySessionStarted(_ notification: Notification) {
        
        enableControls()
        
    }
    
    /**
        Rotate the camera UI controls when the device orientation has changed.
    */
    @objc internal func notifyOrientationChanged(_ notification: Notification) {
        
        let currentOrientation = deviceOrientation(lastOrientation)
        
        rotateButtons(from: lastOrientation, to: currentOrientation)
        
        lastOrientation = currentOrientation
        
        return
        
    }
    /**
        Give the user the ability to resume the session if it's in use by another client.  Otherwise present an inforational message that the camera is unavailable.
    */
    @objc internal func notifySessionWasInterrupted(_ notification: Notification) {
        
        var showResumeBtn = false
                
        if #available(iOS 9, *) {
        
            let reason = AVCaptureSession.InterruptionReason(rawValue: (notification.userInfo![AVCaptureSessionInterruptionReasonKey] as! NSNumber ).intValue)
            
            switch reason! {
                
            case .videoDeviceInUseByAnotherClient:
                showResumeBtn = true
            case .videoDeviceNotAvailableWithMultipleForegroundApps:
                cameraView.unavailableLbl.isHidden = false
                cameraView.unavailableLbl.alpha = 0
                UIView.animate(withDuration: 0.25, animations: {
                    self.cameraView.unavailableLbl.alpha = 1.0
                }) 
            default:
                break
                
            }
            
        } else {
            
            // if the application is inacive then display the resume button
            showResumeBtn = UIApplication.shared.applicationState == .inactive
            
        }
        
        // show the resume button
        if showResumeBtn {
            
            cameraView.resumeSessionBtn.isHidden = false
            cameraView.resumeSessionBtn.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                self.cameraView.resumeSessionBtn.alpha = 1.0
            }) 
        }
        
    }
    
    // FIXME:  Need to figure out what to do with a runtime error
    @objc internal func notifySessionRuntimeError(_ notification: Notification) {
        
    }
    
    /**
        Hide the resume button or the unavailable notification if they were previously showing.
    */
    @objc internal func notiySessionInterruptionEnded(_ notification: Notification) {


    
        if !cameraView.resumeSessionBtn.isHidden {

            UIView.animate(withDuration: 0.25, animations: {self.cameraView.resumeSessionBtn.alpha = 0.0}, completion: { finished in
                self.cameraView.resumeSessionBtn.isHidden = true
            })
        }
        
        if !cameraView.unavailableLbl.isHidden {
            
            UIView.animate(withDuration: 0.25, animations: {self.cameraView.unavailableLbl.alpha = 0.0}, completion: { finished in
                self.cameraView.unavailableLbl.isHidden = true
            })

            
        }
        
    }
    
    /**
        Observing Output Session's member variable capturingStillImage. If in the process of capturing a still image, the preview view is animated from transparent to opaque giving the appearance of the shutter closing and opening.
    */
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        guard context != nil else {
            self.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        switch (keyPath!, context!) {
        case ("capturingStillImage", &CaptureStillImageContext):
            let isCapturingStillImage = change![NSKeyValueChangeKey.newKey] as! Bool
            if isCapturingStillImage {
                DispatchQueue.main.async {
                    
                    self.cameraView.previewView.layer.opacity = 0.0
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        self.cameraView.previewView.layer.opacity = 1.0
                    })
                    
                }
            }
        default:
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
// MARK: Orientation Changes
    
    /**
        Sets the input CGAffineTransform to each of the control views that rotate when device orientation changes.
    */
    func setTransform(to:CGAffineTransform) -> Void {
        
        cameraView.cameraBtn.transform = to
        cameraView.flashBtn.transform = to
        cameraView.cancelBtn.transform = to
        
    }
    
    /**
        rotates the camera's UI controls from their from orientation to their to orientation.
    */
    func rotateButtons (from fromOrientation:UIDeviceOrientation, to toOrientation:UIDeviceOrientation) {
        
        guard fromOrientation != toOrientation else {
            return
        }
        
        let from = CGAffineTransform(rotationAngle: radians(degrees: rotateDegrees(orientation: fromOrientation)))
        
        _ = from
        
        let to = CGAffineTransform(rotationAngle: radians(degrees: rotateDegrees(orientation: toOrientation)))
        
// TODO: Is there a need to set to set the start position of each control before initiating the animated rotation?
        
//        setTransform(to: from)
        
        let time = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds +  UInt64(NSEC_PER_SEC)/100)
        
        DispatchQueue.main.asyncAfter(deadline: time) {
            
            CATransaction.begin()
            CATransaction.setDisableActions(false)
            CATransaction.commit()
            
            UIView.animate(
                withDuration: 0.25,
                delay: 0.1,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0,
                options: .curveLinear,
                animations: {
                    self.setTransform(to: to)
                },
                completion: nil
            )
        }
        
    }

    

// MARK: Action Handlers
    
    /**
        Change the active camer from the front to the back or visa-versa.
    */
    @IBAction func switchCamera(_ sender: UIButton) {
        
        // the controls are disabled while the camer is being updated
        disableControls()
        
        DispatchQueue.main.async {
            
            // find the camera device that is the opposite of the current position.
            var device = self.cameraDevice
            
            switch (device?.position)! {
                
            case .front: device = self.findCameraDevice(withPosition: .back)
                
            case .back: device = self.findCameraDevice(withPosition: .front)
                
            case .unspecified: device = self.findCameraDevice(withPosition: .front)
                
            }
            
            
            guard (device != nil) else {
                
                guard self.cameraDevice != nil else {
                    
                    return
                    
                }
                
                self.enableControls()
                
                return
                
            }
            
            // make the new camera active.
            self.deactivateCamera()
            
            self.activateCameraDevice(device)
            
            self.enableControls()
                        
        }
        
    }
    
    /**
        The flash toggles from auto(initial state) to on and finally to off and then back to auto again.
    */
    @IBAction func toggleFlash(_ sender: UIButton) {
        
        guard let device = cameraDevice , cameraDevice.hasFlash else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            switch device.flashMode {
            case .on:
                device.flashMode = .off
                cameraView.flashBtn.setImage(UIImage(named: "flashoff", in: Bundle(for: MMSCameraViewController.self), compatibleWith: nil), for: .normal)
                
            case .off:
                device.flashMode = .auto
                cameraView.flashBtn.setImage(UIImage(named: "flashauto", in: Bundle(for: MMSCameraViewController.self), compatibleWith: nil), for: .normal)
        
            case .auto:
                device.flashMode = .on
                cameraView.flashBtn.setImage(UIImage(named: "flashon", in: Bundle(for: MMSCameraViewController.self), compatibleWith: nil), for: .normal)
                
            }
            device.unlockForConfiguration()
        } catch _ { }
        
    }
    /**
        Capture a still image in the camera's view.
    */
    @IBAction func takePhoto(_ sender: UIButton) {

        guard cameraView.isSnapButtonEnabled() else {
            return
        }
        cameraView.disableSnapButton()
        captureStillImage()

    }
   
    /**
        User tapped the exit camera button.  The camera is removed and the focus is given back to the controller that launched it.
    */
    @IBAction func cancelCamera(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
        
    }
    
    /**
        The camera was interrupted and the resume button was displayed.  If the session is running, then check if the user wants to cancel out of the camera view.
    */
    @IBAction func resumeInterruptedSession(_ sender: UIButton) {
        
        cameraQueue.async {
            
            self.photoSession.startRunning()
            
            if self.photoSession.isRunning {
                
                DispatchQueue.main.async {
                    
                    let message = International.interface.LString("camera.interrupted.alert.msg", comment:"Messsage when start session fails for the current session after interruption.")
                    
                    let title = International.interface.LString("camera.interrupted.alert.title", comment: "Title for alert ")
                    
                    let alertCtlr = UIAlertController(title: title, message: message, preferredStyle: .alert)
                    
                    let cancelAction = UIAlertAction.init(title: International.interface.LString("button.ok", comment: "OK Button Title"), style: .cancel, handler: nil)
                    
                    alertCtlr.addAction(cancelAction)
                    
                    self.present(alertCtlr, animated: true, completion: nil)
                    
                }
            } else {
                
                DispatchQueue.main.async {
                    
                    self.cameraView.resumeSessionBtn.isHidden = true

                }
            }
            
        }
        
    }
    
}
