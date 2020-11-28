//
//  Classification+Vision.swift
//  vision-swiftui
//
//  Created by Harry Jeffs on 27/11/20.
//

import CoreML
import Vision
import ImageIO
import UIKit
import SwiftUI

class ClassificationController: ObservableObject {
    
    // MARK: - Variables
    
    @Published var selectedImage = UIImage() {
        didSet {
            updateClassifications()
        }
    }
    @Published var selectedModelType = 0
    @Published var defaultPickerText = "Select an image"
    
    // MARK: - Image Classification
    lazy final var modelConfiguation = MLModelConfiguration()
    
    /// - Tag: MLModelSetup
    func classificationRequest() throws -> VNCoreMLRequest {
        do {
            /*
             Use the Swift class `MobileNet` Core ML generates from the model.
             To use a different Core ML classifier model, add it to the project
             and replace `MobileNet` with that model's generated Swift class.
             */
            let model: VNCoreMLModel!
            
            if selectedModelType == 0 {
                model = try VNCoreMLModel(for: VGG19_300_20201122224455(configuration: modelConfiguation).model) // Maya generated model here
            } else {
                model = try VNCoreMLModel(for: legoid_vgg16_260tf(configuration: modelConfiguation).model) // Google handpicked model here
            }
            
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }
    
    /// - Tag: PerformRequests
    func updateClassifications() {
        defaultPickerText = "Classifying..."
        
        guard let orientation = CGImagePropertyOrientation(rawValue: UInt32(selectedImage.imageOrientation.rawValue)) else {
            defaultPickerText = "An error occured whilst retrieving the imageOrientation"
            return
        }
        
        guard let ciImage = CIImage(image: selectedImage) else { fatalError("Unable to create \(CIImage.self) from \(selectedImage).") }
        
        DispatchQueue.main.async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest()])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    /// Updates the UI with the results of the classification.
    /// - Tag: ProcessClassifications
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.defaultPickerText = "Unable to classify image.\n\(error!.localizedDescription)"
                return
            }
            // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.defaultPickerText = "Nothing recognized."
            } else {
                // Display top classifications ranked by confidence in the UI.
                let topClassifications = classifications.prefix(5)
                let descriptions = topClassifications.map { classification in
                    // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.defaultPickerText = "Classification:\n" + descriptions.joined(separator: "\n")
            }
        }
    }
}
