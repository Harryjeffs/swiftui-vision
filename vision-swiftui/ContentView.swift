//
//  ContentView.swift
//  vision-swiftui
//
//  Created by Harry Jeffs on 27/11/20.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var classifier = ClassificationController()
    @State private var showCameraPopup = false
    @State var showCameraPickerView = false
    @State var cameraPickerType: UIImagePickerController.SourceType = .camera {
        didSet {
            showCameraPickerView = true
        }
    }
    private var modelText = ["Maya model", "Google Model"]
    
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
                            self.showCameraPopup = true
                        }) {
                            Image(systemName: "camera.fill")
                                .renderingMode(.original)
                        }
                    }
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
                }.actionSheet(isPresented: $showCameraPopup) {
                    ActionSheet(title: Text("Action type"), message: nil, buttons: [
                        .default(Text("Take Photo"), action: {
                            cameraPickerType = .camera
                        }),
                        .default(Text("Camera Roll"), action: {
                            cameraPickerType = .photoLibrary
                        }),
                        .cancel()
                    ])
                }
                .navigationBarTitle("")
                .navigationBarHidden(true)
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
        }
    }
}
