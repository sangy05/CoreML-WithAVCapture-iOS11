//
//  CameraUtility.swift
//  sangyxcdoe9
//
//  Created by Sangeeth K Sivakumar on 6/13/17.
//  Copyright © 2017 Sangeeth K Sivakumar. All rights reserved.
//

import UIKit
import AVFoundation

protocol MediaCaptureDelegate: class {
  func captured(image: UIImage?, pixelImageBuffer:CVPixelBuffer?)
}

class CameraUtility:NSObject,AVCapturePhotoCaptureDelegate {
  
  var captureSession: AVCaptureSession?
  var photoOutput: AVCapturePhotoOutput?
  var previewLayer: AVCaptureVideoPreviewLayer?
  var cameraView:UIView?
  var mediaCaptureDelegate:MediaCaptureDelegate?
  
 func setupCamera() {
    // Capture session
    captureSession = AVCaptureSession()
    captureSession!.sessionPreset = AVCaptureSession.Preset.photo
  
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back) else {
      print("Couldn't load Camera Device")
      return
    }
    
    do {
      let input = try AVCaptureDeviceInput(device: camera)
      captureSession!.addInput(input)
    } catch let error {
      print("Error initialize AV input")
      print(error)
      return
    }
    
    // Output
    self.photoOutput = AVCapturePhotoOutput()
    captureSession!.addOutput(photoOutput!)
    guard let cameraView = self.cameraView else {
      return
    }
  
    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
    self.previewLayer!.frame = cameraView.bounds
    self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
    
    cameraView.layer.addSublayer(self.previewLayer!)
    cameraView.layer.masksToBounds = true
    self.captureSession?.startRunning()
  }
  
  
  
  func simpleCapture(){
    let jpegFormat:[String : Any] = [AVVideoCodecKey:AVVideoCodecType.jpeg]
    let settings = AVCapturePhotoSettings(format: jpegFormat)
    photoOutput?.capturePhoto(with: settings, delegate: self)
  }
  
  
  //MARK: Experiment & Tested
  // This method has different way to define the configuration to capture raw and processed image
  func capture() {
    //To get only Compressed Image Like JPEG
    let jpegFormat:[String : Any] = [AVVideoCodecKey:AVVideoCodecType.jpeg]
    //  TO get Only RawImage
    //let rawFormat: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String:photoOutput?.availablePhotoPixelFormatTypes.first as Any]
    
    var settings:AVCapturePhotoSettings?
    
    //Available when the back camera is chosen
    if !((photoOutput?.availableRawPhotoPixelFormatTypes.isEmpty)!) {
      let rawPixelType = UInt32.init(truncating:(photoOutput?.availableRawPhotoPixelFormatTypes[0])!)
      settings = AVCapturePhotoSettings(rawPixelFormatType: rawPixelType, processedFormat: jpegFormat)
      //TO get previewPixelImage
      //let rawPreviewFormat: [String : Any] = [kCVPixelBufferPixelFormatTypeKey as String:photoOutput?.availablePhotoPixelFormatTypes.first as Any, kCVPixelBufferWidthKey as String:224,kCVPixelBufferHeightKey as String:224]
      //settings?.previewPhotoFormat = rawPreviewFormat
    }
    else{
      //Simple Settings - front camera
      settings = AVCapturePhotoSettings(format: jpegFormat)
    }
    
    //To get Thumbnail Image with Main Image
    //settings?.embeddedThumbnailPhotoFormat = [AVVideoCodecKey:AVVideoCodecType.jpeg]
    photoOutput?.capturePhoto(with: settings!, delegate: self)
  }
  
  //IOS11 New delegate method to produce PhotoOutput
  /*
    Try depth API, Source Device Type, PixelBuffer etc
 */
  
  func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
    if let error = error {
      print(error.localizedDescription)
    }
    else{
      var displayImage:UIImage?
      //let pixelBuffer = photo.pixelBuffer
      //let previewPixelBuffer = photo.previewPixelBuffer
      
      var reducedSizeBuffer:CVPixelBuffer?
      if let data = photo.fileDataRepresentation() , let _ = UIImage(data: data) {
        displayImage = UIImage(data: data)
        reducedSizeBuffer = ImageUtilities.pixelBufferFromImage(image:displayImage!)
        print(data.count/1024)
      }
      
      self.mediaCaptureDelegate?.captured(image: displayImage, pixelImageBuffer: reducedSizeBuffer)
    }
  }
  
  
}
