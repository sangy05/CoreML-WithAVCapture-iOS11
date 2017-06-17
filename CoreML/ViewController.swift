//
//  ViewController.swift
//  sangyxcdoe9
//
//  Created by Sangeeth K Sivakumar on 6/6/17.
//  Copyright © 2017 Sangeeth K Sivakumar. All rights reserved.
//

import UIKit
import CoreImage
import CoreVideo
import AVFoundation

class ViewController: UIViewController, MediaCaptureDelegate {
  
  
  @IBOutlet weak var cameraView: UIView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var selectedImageView: UIImageView!
  @IBOutlet weak var resultLabel: UILabel!
  @IBOutlet weak var resultLabel2: UILabel!
  let camUtility = CameraUtility()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    camUtility.mediaCaptureDelegate = self
    camUtility.cameraView = self.cameraView
    camUtility.setupCamera()
  }
  
  @IBAction func capturePhoto(_ sender: Any) {
    camUtility.simpleCapture()
  }
  
  func predictImageFromSelection(image:CVPixelBuffer) {
    let model = Resnet50()
    let input = Resnet50Input(image: image)
    
    guard let output = try? model.prediction(input:input) else {
      print("error in predicito")
      return
    }
    self.resultLabel.text = output.classLabel.description
  }
  
  func predictWithGoogleImageFromSelection(image:CVPixelBuffer) {
    let model = GoogLeNetPlaces()
    let input = GoogLeNetPlacesInput(sceneImage: image)
    
    guard let output = try? model.prediction(input:input) else {
      print("error in prediciton")
      return
    }
    self.resultLabel2.text = output.sceneLabel.description
  }
  
  func captured(image: UIImage?, pixelImageBuffer:CVPixelBuffer?) {
    
    DispatchQueue.main.async {
      if let capturedImage = image {
        self.selectedImageView.image = capturedImage
      }
      
      if let pixelImageBufferFromCamera = pixelImageBuffer {
        self.predictImageFromSelection(image: pixelImageBufferFromCamera)
        self.predictWithGoogleImageFromSelection(image: pixelImageBufferFromCamera)
      }
      else{
        print("error")
      }
      
      
    }
  }
  
}

