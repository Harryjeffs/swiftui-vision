//
//  VNImageCropAndScaleOption+description.swift
//  vision-swiftui
//
//  Created by Harry Jeffs on 2/12/20.
//

import Vision

extension VNImageCropAndScaleOption {
    var description: String {
        switch self {
        case .centerCrop: return "Centre Crop"
        case .scaleFit: return "Scale Fit"
        case .scaleFill: return "Scale Fill"
        @unknown default:
            return "Unknown string value"
        }
    }
}
