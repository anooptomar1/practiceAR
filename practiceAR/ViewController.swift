//
//  ViewController.swift
//  practiceAR
//
//  Created by cl-dev on 2017-08-09.
//  Copyright © 2017 Connected Lab. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    // MARK: - Vision Parts
    private var requests = [VNRequest()]
    var inputImage: CIImage!
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
//
//        // Set the scene to the view
//        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    

    // MARK: - ARSession delegate

    // gets each frame as they are updated
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        inputImage = CIImage(cvPixelBuffer: frame.capturedImage)
        
        rectangleDetector(frame: frame)
    }
    
    
    // MARK: - Vision
    
//    func setupVision() {
//        let rectangleDetectionRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
//        rectangleDetectionRequest.minimumSize = 0.1
//        rectangleDetectionRequest.maximumObservations = 3
//
//        self.requests = [rectangleDetectionRequest]
//    }
    
    func rectangleDetector(frame: ARFrame) {
        let cameraIntrinsicsData = frame.camera.intrinsics
        
        var requestOptions = [VNImageOption.cameraIntrinsics:cameraIntrinsicsData]
        
        // not sure if this works
        let exifOrientation = exifOrientationFromDevice()
        
        // Run the rectangle detector
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: exifOrientation)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([self.rectanglesRequest])
            } catch {
                print(error)
            }
        }
        
    }
    lazy var rectanglesRequest: VNDetectRectanglesRequest = {
        let rectangleDetectionRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
        rectangleDetectionRequest.minimumSize = 0.1
        rectangleDetectionRequest.maximumObservations = 20
        
        return rectangleDetectionRequest
    }()
    func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRectangleObservation]
            else { fatalError("unexpected result type from VNDetectRectanglesRequest") }
        guard let detectedRectangle = observations.first else {
            print("No rectangles detected.")
            return
        }
        
        let imageSize = inputImage.extent.size

        // Verify detected rectangle is valid.
        let boundingBox = detectedRectangle.boundingBox.scaled(to: imageSize)
        guard inputImage.extent.contains(boundingBox)
            else { print("invalid detected rectangle"); return }

        // Rectify the detected image and reduce it to inverted grayscale for applying model.
        let topLeft = detectedRectangle.topLeft.scaled(to: imageSize)
        let topRight = detectedRectangle.topRight.scaled(to: imageSize)
        let bottomLeft = detectedRectangle.bottomLeft.scaled(to: imageSize)
        let bottomRight = detectedRectangle.bottomRight.scaled(to: imageSize)
        let correctedImage = inputImage
            .cropped(to: boundingBox)
            .applyingFilter("CIPerspectiveCorrection", parameters: [
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)
            ])
        
        print("rectangle found")
    }
    
    func handleRectangleDetection(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRectangleObservation]
            else { fatalError("unexpected result type from VNDetectRectanglesRequest") }
        guard let detectedRectangle = observations.first else {
            print("No rectangles detected.")
            return
        }
        
        print("detected rectangle: \(detectedRectangle.topLeft) and \(detectedRectangle.bottomRight)")
    }
    
//    func drawVisionRequestRectangles(_ results: [VNObservation]) {
//        CATransaction.begin()
//
//    }
    
    func exifOrientationFromDevice() -> CGImagePropertyOrientation {
//        CGImagePropertyOrientation(rawValue: UInt32(Int32(orientation.rawValue)))!
        // default
        var exifOrientation: CGImagePropertyOrientation = CGImagePropertyOrientation(.up)
        
        switch UIDevice.current.orientation{
        case .portrait:
            exifOrientation = CGImagePropertyOrientation(.up)
            break
        case .portraitUpsideDown:
            exifOrientation = CGImagePropertyOrientation(.down)
            break
        case .landscapeLeft:
            exifOrientation = CGImagePropertyOrientation(.left)
            break
        case .landscapeRight:
            exifOrientation = CGImagePropertyOrientation(.right)
            break
        default:
            break
        }
        
        return exifOrientation
    }
}
