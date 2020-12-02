//
//  ContentView.swift
//  vision-swiftui
//
//  Created by Harry Jeffs on 27/11/20.
//

import SwiftUI
import Vision

struct ContentView: View {
    
    @ObservedObject var classifier = ClassificationController()
    @State private var showActionSheet = false
    @State private var showCameraPickerView = false
    @State private var actionSheetOption: OptionsMenu = .cameraOptions  {
        didSet {
            showActionSheet = true
        }
    }
    @State var cameraPickerType: UIImagePickerController.SourceType = .camera {
        didSet {
            showCameraPickerView = true
        }
    }
    private var modelText = ["Maya", "Google"]
    
    var body: some View {
        NavigationView {
            Image(uiImage: classifier.selectedImage)
                .resizable()
                .renderingMode(.original)
                .background(Color.gray)
                .edgesIgnoringSafeArea(.top)
                .overlay(Text(classifier.defaultPickerText)
                            .padding()
                            .background(Color.gray.opacity(0.7))
                         ,alignment: .bottomLeading)
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        
                            Button(action: {
                                actionSheetOption = .cameraOptions
                            }) {
                                Image(systemName: "camera.fill")
                            }
                    }
                    ToolbarItem(placement: .bottomBar, content: {
                        Button(action: {
                            actionSheetOption = .scaleOptions
                        }) {
                            HStack {
                                Image(systemName: "perspective")
                                Text(classifier.selectedScaleOption.description)
                            }
                        }
                    })
                    ToolbarItem(placement: .bottomBar, content: {
                        Spacer()
                    })
                    ToolbarItem(placement: .bottomBar, content: {
                        Picker("", selection: $classifier.selectedModelType, content: {
                            ForEach(0..<modelText.count) { index in
                                Text(self.modelText[index]).tag(index)
                            }
                        }).pickerStyle(SegmentedPickerStyle())
                    })
                }.sheet(isPresented: $showCameraPickerView) {
                    ImagePickerView(sourceType: cameraPickerType) { image in
                        classifier.selectedImage = image
                    }
                }
                .actionSheet(isPresented: $showActionSheet, content: {
                    if actionSheetOption == .cameraOptions {
                        return showCameraPopupActionSheet()
                    }
                    return showScalingOptionActionSheet()
                })
                .navigationBarTitle("")
                .navigationBarHidden(true)
        }
    }
    func showScalingOptionActionSheet() -> ActionSheet {
        let options = ["Centre Crop", "Scale Fit", "Scale Fill"]
        let buttons = options.enumerated().map { i, option in
            Alert.Button.default(Text(option), action: {
                classifier.selectedScaleOption = VNImageCropAndScaleOption(rawValue: UInt(i)) ?? .centerCrop
            } )
        }
        return ActionSheet(title: Text("Scale Option"),
                           buttons: buttons + [Alert.Button.cancel()])
    }
    
    private func showCameraPopupActionSheet() -> ActionSheet {
        let captureButton = ActionSheet.Button.default(Text("Take Photo")) {
            cameraPickerType = .camera
        }
        let existingButton = ActionSheet.Button.default(Text("Camera Roll")) {
            cameraPickerType = .photoLibrary
        }
        let actionSheet = ActionSheet(title: Text("Action Sheet"),
                                      message: nil,
                                      buttons: [captureButton, existingButton, .cancel()])
        return actionSheet
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}

