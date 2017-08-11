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
    
    private var requests = [VNRequest()]
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = true
        
        setupVision()
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
    

    // MARK: - ARSessionDelegate

    // Gets each frame as they are updated
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        rectangleDetector(frame: frame)
    }
    
    
    // MARK: - Vision Rectangles
    
    func setupVision() {
        // 1. Create Rectangle Detection Request
        let rectangleDetectionRequest = VNDetectRectanglesRequest(completionHandler: self.handleRectangles)
        rectangleDetectionRequest.minimumSize = 0.4 // Only Finds rectangles the size of the card or larger
        rectangleDetectionRequest.maximumObservations = 3

        self.requests = [rectangleDetectionRequest]
    }

    func rectangleDetector(frame: ARFrame) {
        let cameraIntrinsicsData = frame.camera.intrinsics
        let requestOptions = [VNImageOption.cameraIntrinsics:cameraIntrinsicsData]
        // not sure if this works
        let exifOrientation = exifOrientationFromDevice()
        
        // 2. Run the rectangle detector
        let handler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage, orientation: exifOrientation, options: requestOptions)
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                // 3. assign image requests to handler
                try handler.perform(self.requests)
            } catch {
                print(error)
            }
        }
        
    }
    
    // 4. Request Handler Code
    func handleRectangles(request: VNRequest, error: Error?) {
        guard let observations = request.results as? [VNRectangleObservation] else {
            print("unexpected result type from VNDetectRectanglesRequest")
            return
        }
        guard let detectedRectangle = observations.first else {
            print("No rectangles detected.")
            return
        }

        print("rectangle detected \(detectedRectangle.topRight), \(detectedRectangle.topLeft)\n \(detectedRectangle.bottomRight), \(detectedRectangle.bottomLeft)")
    }
    
    func displayPointFromARPoint(arPoint: CGPoint) -> CGPoint {
        let displaySize = UIScreen.main.bounds.size
        let adjustedX = arPoint.x * displaySize.width
        let adjustedY = arPoint.y * displaySize.height
        
        return CGPoint(x: adjustedX, y: adjustedY)
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
    
    func exifOrientationFromDevice() -> CGImagePropertyOrientation {
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
