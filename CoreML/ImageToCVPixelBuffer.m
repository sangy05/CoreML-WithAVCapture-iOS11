+ (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image {
    NSData * rawImageData = [UIImage RawRepresentation:image pixelFormat:SVPixelFormat_BGRA];
    
    NSDictionary * attributes = @{
                                  (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
                                  (NSString *)kCVPixelBufferCGImageCompatibilityKey : @(YES),
                                  (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @(YES),
                                  (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @(YES),
                                  };
    
    CVPixelBufferRef pixelBufferRef = NULL;
    CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, image.size.width * image.scale, image.size.height * image.scale, kCVPixelFormatType_32BGRA, (void *)rawImageData.bytes, (NSUInteger)image.size.width * image.scale * 4, NULL, NULL, (__bridge CFDictionaryRef)(attributes), &pixelBufferRef);
    
    if (kCVReturnSuccess != status) {
        CrazyInnerLoge(@"create pixel buffer from UIImage failed!");
        return NULL;
    }
    
    return pixelBufferRef;
}