//
//  UIImage+crop.swift
//  ZenIDDemo
//
//  Created by Marek Stana on 02/07/2019.
//  Copyright © 2019 Trask, a.s. All rights reserved.
//

import AVFoundation
import VideoToolbox
import UIKit

extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer, crop: CGRect? = nil) {
        var cgImage: CGImage?
        VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &cgImage)
        
        if let cropRect = crop {
            cgImage = cgImage?.cropping(to: cropRect)
        }
        
        if let cgImage = cgImage {
            self.init(cgImage: cgImage)
        } else {
            return nil
        }
    }
    
    func cropCameraImage(previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {

        var image = UIImage()

        let previewImageLayerBounds = previewLayer.bounds

        let originalWidth = size.width
        let originalHeight = size.height

        let A = previewImageLayerBounds.origin
        let B = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.origin.y)
        let D = CGPoint(x: previewImageLayerBounds.size.width, y: previewImageLayerBounds.size.height)

        let a = previewLayer.captureDevicePointConverted(fromLayerPoint: A)
        let b = previewLayer.captureDevicePointConverted(fromLayerPoint: B)
        let d = previewLayer.captureDevicePointConverted(fromLayerPoint: D)

        let posX = floor(b.x * originalHeight)
        let posY = floor(b.y * originalWidth)

        let width: CGFloat = d.x * originalHeight - b.x * originalHeight
        let height: CGFloat = a.y * originalWidth - b.y * originalWidth

        let cropRect = CGRect(x: posX, y: posY, width: width, height: height)

        if let imageRef = cgImage?.cropping(to: cropRect) {
            image = UIImage(cgImage: imageRef, scale: 1.0, orientation: .right)
        }

        return image
    }

    func cropCameraImageLandscape(previewLayer: AVCaptureVideoPreviewLayer) -> UIImage? {

        let originalSize = CGSize(width: size.height, height: size.width)
        let visibleLayerFrame = previewLayer.bounds

        let metaRect: CGRect = (previewLayer.metadataOutputRectConverted(fromLayerRect: visibleLayerFrame))

        let cropRect: CGRect = CGRect(
            x: metaRect.origin.y * originalSize.height,
            y: metaRect.origin.x * originalSize.width,
            width: metaRect.size.height * originalSize.height,
            height: metaRect.size.width * originalSize.width).integral

        return UIImage(cgImage: cgImage!.cropping(to: cropRect)!,
                       scale:1,
                       orientation: imageOrientation)
    }
    
    func flip(_ flipMethod: ImageFlip) -> UIImage {
        guard let cgImage = cgImage else {
            return self
        }
        
        switch flipMethod {
        case .fromPortrait:
            return UIImage(cgImage: cgImage, scale: scale, orientation: .leftMirrored)
        case .fromLandScape:
            return UIImage(cgImage: cgImage, scale: scale, orientation: .right)
        default:
            return self
        }
    }
}
