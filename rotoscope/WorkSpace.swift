//
//  WorkSpace.swift
//  rotoscope
//
//  Created by Aarati Akkapeddi on 9/5/16.
//  Copyright © 2016 Aarati Akkapeddi. All rights reserved.
//

import UIKit
import UIKit
import AVFoundation
import ReplayKit

class WorkSpace: CanvasController, RPPreviewViewControllerDelegate, UINavigationControllerDelegate{
    //MARK: Visage
    private var visage : Visage?
    private let notificationCenter : NSNotificationCenter = NSNotificationCenter.defaultCenter()
    
    //MARK:Screen Recorder
    var bool = false
    var recorder = ScreenRecorder()
    var startRecording: UILongPressGestureRecognizer?
    
    //MARK Shape Variables
    var faceLayer = Rectangle() //we use to transform CIDetector coordinates
    var leftEyeShape = Circle(center: Point(), radius: 40) //left eye
    var rightEyeShape = Circle(center: Point(), radius: 40) //right eye

    
    
    override func setup() {
       
        //SCREEN RECORDING
        canvasStartRecording()
        
        self.recorder.recordingEndedAction = {
            self.recorder.showPreviewInController(self)
            self.startRecording?.enabled = true
        }
        
        
        //set face layer to same width and height as canvas
        faceLayer.center = canvas.center
        faceLayer.bounds.width = canvas.width
        faceLayer.bounds.height = canvas.height
        
        //make sure its clear
        faceLayer.fillColor = Color(red: 1, green: 0.75, blue: 0.5, alpha: 0)
        faceLayer.strokeColor = clear
        
        //style eye shapes
        leftEyeShape.center = canvas.center
        leftEyeShape.fillColor = C4Pink
        leftEyeShape.strokeColor = clear
        rightEyeShape.center = canvas.center
        rightEyeShape.fillColor = blue
        rightEyeShape.strokeColor = clear

        //Set up Visage Camera
        visage = Visage(cameraPosition: Visage.CameraDevice.FaceTimeCamera, optimizeFor: Visage.DetectorAccuracy.HigherPerformance)
        visage!.onlyFireNotificatonOnStatusChange = false
        
        //Start Face Detection
        visage!.beginFaceDetection()
        
        //Add Visage Camera to Canvas
        let cam = visage!.visageCameraView
        canvas.add(cam)
        
        //Group face elements to face layer and add to canvas
        canvas.add(faceLayer)
        faceLayer.add(leftEyeShape)
        faceLayer.add(rightEyeShape)

        
        NSNotificationCenter.defaultCenter().addObserverForName("visageFaceDetectedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in

            //Find Bounds of detected face and unwrap
            guard let faceRect = self.visage!.faceBounds else{
                return
            }
            var newRect = Rectangle(frame:Rect(faceRect))
            
            
            //Find eyes and position corresponding shapes
            
            var leftEye = self.visage!.leftEyePosition
            if let leftEye = leftEye{
                self.leftEyeShape.center = Point(Double(leftEye.x), Double(leftEye.y - 40))
            }else{
            }
            
            var rightEye = self.visage!.rightEyePosition
            if let rightEye = rightEye{
                self.rightEyeShape.center = Point(Double(rightEye.x), Double(rightEye.y - 40))
            }else{
            }
            
            
            //Evaluate Expressions
            if ((self.visage!.hasSmile == true && self.visage!.isWinking == true)) {
                //print("😜")
            } else if ((self.visage!.isWinking == true && self.visage!.hasSmile == false)) {
                //print( "😉")
            } else if ((self.visage!.hasSmile == true && self.visage!.isWinking == false)) {
                //print( "😃")
            } else {
                //print("😐")
            }
            
            //Fix detector coordinates by transforming face layer using C4
            self.faceLayer.rotation = M_PI/2 //rotate 90deg
            let scale = Transform.makeScale(0.5, 0.5) //scale by half
            self.faceLayer.transform = scale
            self.faceLayer.origin = Point(0,-(self.canvas.bounds.height/3)) //move up a third the height of the canvas.
            
        })
        
        //Reset expressions when no face is detected things are reset
//        NSNotificationCenter.defaultCenter().addObserverForName("visageNoFaceDetectedNotification", object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: { notification in
//            
//        })

    }
    
    func canvasStartRecording() {
        startRecording = canvas.addLongPressGestureRecognizer { location, center, state in
            self.startRecording?.enabled = false
            let v = View(frame: self.canvas.frame)
            v.backgroundColor = C4Pink
            self.canvas.add(v)
            
            let a = ViewAnimation(duration: 0.25) {
                v.opacity = 0.0
            }
            
            a.addCompletionObserver {
                v.removeFromSuperview()
                self.recorder.start(10.0)
            }
            a.animate()
        }
        
        startRecording?.numberOfTouchesRequired = 1
    }
    




}

