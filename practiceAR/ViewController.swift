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
    var inputImage: CIImage!
//    let drawingLayer = CALayer()
    let shapeLayer = CAShapeLayer()
    
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
//        setupDrawingLayer()
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
    
    
    // MARK: - Additional Setup
    
    func setupDrawingLayer() {
//        drawingLayer.frame = sceneView.frame
//        drawingLayer.delegate = self
//        drawingLayer.needsDisplay()
        
//        sceneView.layer.addSublayer(drawingLayer)
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
        // Remove any existing layers
        clearDrawingLayer()
//        inputImage = CIImage(cvPixelBuffer: frame.capturedImage)
        
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
//            fatalError("unexpected result type from VNDetectRectanglesRequest")
            print("unexpected result type from VNDetectRectanglesRequest")
            return
        }
        guard let detectedRectangle = observations.first else {
            print("No rectangles detected.")
            return
        }

        print("rectangle detected \(detectedRectangle.topRight), \(detectedRectangle.topLeft)\n \(detectedRectangle.bottomRight), \(detectedRectangle.bottomLeft)")
//        let imageSize = inputImage.extent.size
//
//        // Verify detected rectangle is valid.
//        let boundingBox = detectedRectangle.boundingBox.scaled(to: imageSize)
//        guard inputImage.extent.contains(boundingBox) else {
//            print("invalid detected rectangle")
//            return
//        }
        
//        // TODO run on main thread
//        UIGraphicsBeginImageContext(shapeLayer.frame.size)
//        guard let context = UIGraphicsGetCurrentContext() else {
//            print("NO GRAPHICS CONTEXT")
//            return
//        }
        drawLayer(rectangle: detectedRectangle)
        
        // Rectify the detected image and reduce it to inverted grayscale for applying model.
//        let topLeft = detectedRectangle.topLeft.scaled(to: imageSize)
//        let topRight = detectedRectangle.topRight.scaled(to: imageSize)
//        let bottomLeft = detectedRectangle.bottomLeft.scaled(to: imageSize)
//        let bottomRight = detectedRectangle.bottomRight.scaled(to: imageSize)
//        let correctedImage = inputImage
//            .cropped(to: boundingBox)
//            .applyingFilter("CIPerspectiveCorrection", parameters: [
//                "inputTopLeft": CIVector(cgPoint: topLeft),
//                "inputTopRight": CIVector(cgPoint: topRight),
//                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
//                "inputBottomRight": CIVector(cgPoint: bottomRight)
//            ])
        // TODO: Draw the rectangle
        
    // MARK: Alternative
        
        //        guard let observations = request.results as? [VNRectangleObservation] else {
        //            print("unexpected result type from VNDetectRectanglesRequest")
        //            return
        //        }
        //        guard observations.first != nil else {
        //            print("No rectangles detected.")
        //            return
        //        }
        //        // Show the pre-processed image
        //        DispatchQueue.main.async {
        //            self.analyzedImageView.subviews.forEach({ (s) in
        //                s.removeFromSuperview()
        //            })
        //            for rect in observations
        //            {
        //                let view = self.CreateBoxView(withColor: UIColor.cyan)
        //                view.frame = self.transformRect(fromRect: rect.boundingBox, toViewRect: self.analyzedImageView)
        //                self.analyzedImageView.image = self.originalImageView.image
        //                self.analyzedImageView.addSubview(view)
        //                self.loadingLbl.isHidden = true
        //            }
        //        }

    }
    
//    func drawLayer(rectangle: VNRectangleObservation, layer: CALayer, context: CGContext) {
//        print("Test Layer")
//        context.setFillColor(gray: 0.6, alpha: 0.5)
//
//        let width = rectangle.topRight.x - rectangle.topLeft.x
//        let height = rectangle.topLeft.y - rectangle.bottomLeft.y
//
//        context.fill(CGRect(x: rectangle.topLeft.x, y: rectangle.topLeft.y, width: width, height: height))
//        // Drawing complete, retrieve the finished image and cleanup
//
//        layer.addSublayer(CALayer(layer: context))
//
//        UIGraphicsEndImageContext()
//    }
    func drawLayer(rectangle: VNRectangleObservation) {
        print("Test Layer")
        
        let rectTopLeft = displayPointFromARPoint(arPoint: rectangle.topLeft)
        let rectTopRight = displayPointFromARPoint(arPoint: rectangle.topRight)
        let rectBottomLeft = displayPointFromARPoint(arPoint: rectangle.bottomLeft)
//        let rectBottomRight = displayPointFromARPoint(arPoint: rectangle.bottomRight)
        
        let width = rectTopRight.x - rectTopLeft.x
        let height = rectBottomLeft.y - rectTopLeft.y

        let rectanglePath = UIBezierPath(rect: CGRect(x: rectTopLeft.x, y: rectTopLeft.y, width: width, height: height))

        shapeLayer.path = rectanglePath.cgPath
        shapeLayer.fillColor = UIColor(white: 1.0, alpha: 0.4).cgColor
        shapeLayer.fillRule = kCAFillRuleNonZero
        shapeLayer.lineCap = kCALineCapButt
        shapeLayer.lineDashPattern = nil
        shapeLayer.lineDashPhase = 0.0
        shapeLayer.lineJoin = kCALineJoinMiter
        shapeLayer.lineWidth = 1.0
        shapeLayer.miterLimit = 10.0
        shapeLayer.strokeColor = UIColor(white: 1.0, alpha: 1.0).cgColor
        
        DispatchQueue.main.async {
            self.sceneView.layer.addSublayer(self.shapeLayer)
        }
    }
    
    func clearDrawingLayer() {
        DispatchQueue.main.async {
            if (self.sceneView.layer.sublayers?.last as? CAShapeLayer) != nil {
                self.sceneView.layer.sublayers?.removeLast()
            }
        }
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
    
//    // TEMP new
//    func drawRectangle() {
//        let center = CGPointMake(self.frame.size.width / 2.0, self.frame.size.height / 2.0)
//        let rectangleWidth:CGFloat = 100.0
//        let rectangleHeight:CGFloat = 100.0
//        let ctx = UIGraphicsGetCurrentContext()
//
//        //4
//        CGContextAddRect(ctx, CGRectMake(center.x - (0.5 * rectangleWidth), center.y - (0.5 * rectangleHeight), rectangleWidth, rectangleHeight))
//        CGContextSetLineWidth(ctx, 10)
//        CGContextSetStrokeColorWithColor(ctx, UIColor.grayColor().CGColor)
//        CGContextStrokePath(ctx)
//
//        //5
//        CGContextSetFillColorWithColor(ctx, UIColor.greenColor().CGColor)
//        CGContextAddRect(ctx, CGRectMake(center.x - (0.5 * rectangleWidth), center.y - (0.5 * rectangleHeight), rectangleWidth, rectangleHeight))
//
//        CGContextFillPath(ctx)
//    }
    
    // Delegate function that draws to a CALayer
//    func draw(_ layer: CALayer, in ctx: CGContext) {
//        print("Test Layer")
//        ctx.setFillColor(gray: 0.6, alpha: 0.5)
//
////        let width = rectangle.topRight.x - rectangle.topLeft.x
////        let height = rectangle.topLeft.y - rectangle.bottomLeft.y
////
////        ctx.fill(CGRect(x: rectangle.topLeft.x, y: rectangle.topLeft.y, width: width, height: height))
//        ctx.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
//    }
    
    
    
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
