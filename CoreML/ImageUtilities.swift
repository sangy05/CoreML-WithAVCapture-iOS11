//
//  ImageUtilities.swift
//  sangyxcdoe9
//
//  Created by Sangeeth K Sivakumar on 6/13/17.
//  Copyright © 2017 Sangeeth K Sivakumar. All rights reserved.
//

import UIKit

class ImageUtilities: NSObject {
  
  class func pixelBufferFromImage(image: UIImage) -> CVPixelBuffer {
    
    let newImage = ImageUtilities.resize(image: image, newSize: CGSize(width: 224/3.0, height: 224/3.0))
    
    let ciimage = CIImage(image: newImage!)
    let tmpcontext = CIContext(options: nil)
    let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
    
    let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
    let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
    let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
    let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
    let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
    let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
    keysPointer.initialize(to: keys)
    valuesPointer.initialize(to: values)
    
    let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
    
    let width = cgimage!.width
    let height = cgimage!.height
    
    var pxbuffer: CVPixelBuffer?
    var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                     kCVPixelFormatType_32BGRA, options, &pxbuffer)
    status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
    
    let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!)
    
    
    let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
    let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
    let context = CGContext(data: bufferAddress,
                            width: width,
                            height: height,
                            bitsPerComponent: 8,
                            bytesPerRow: bytesperrow,
                            space: rgbColorSpace,
                            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue)
    context?.concatenate(CGAffineTransform(rotationAngle: 0))
    context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
    
    context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)))
    status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
    return pxbuffer!
    
  }
  
  class func resize(image: UIImage, newSize: CGSize) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newImage
  }
  
  
}
