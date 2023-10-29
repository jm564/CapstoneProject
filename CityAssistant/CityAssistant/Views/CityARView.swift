//
//  CityARView.swift
//  CityAssistant
//
//  Created by Justin Reini on 9/11/23.
//

import Foundation
import SwiftUI
import RealityKit

struct CameraView: UIViewRepresentable {
    
    //Temporary test, will be removed when separate files are created for AR objects
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    
    
    
    @ObservedObject var tap: Tap
    
    init(tap: Tap) {
        self.tap = tap
    }
    
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero, cameraMode: .ar, automaticallyConfigureSession: true)
        context.coordinator.view = arView
        arView.addGestureRecognizer(UITapGestureRecognizer(target: context.coordinator, action: #selector(CityCoordinator.handleTap(_:))))
        
//        // The "Text Text" 3D object
//        let poi = createPOI()
//        placePOI(poi: poi, arView: arView)
        
        let bubble = createBubble()
        // for now, using the same placement function as the 3D text
        placePOI(poi: bubble, arView: arView)
        
        // Test placing text at position on bubble
//        let x = -0.5
//        let y = 0.5
//        let rectOrigin = CGPoint(x: x, y: y)
//        let rectSize = CGSize(width: 0, height: 0)
//        let textFrameRect = CGRect(origin: rectOrigin, size: rectSize)
//        
//        let myTxt = ModelEntity(mesh: MeshResource.generateText(CameraView.mockPOI.BusinessName, extrusionDepth: 0.01, font: .boldSystemFont(ofSize: 0.1), containerFrame: textFrameRect, alignment: .center, lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
//        myTxt.generateCollisionShapes(recursive: true)
//        let myAnchor = AnchorEntity()
//        myAnchor.addChild(myTxt)
//        arView.scene.addAnchor(myAnchor)
        let businessNameText = create3dText(text: CameraView.mockPOI.BusinessName, x: -0.45, y: 0.4)
        placePOI(poi: businessNameText, arView: arView)
        let businessType = "Business Type"
        let businessTypeText = create3dText(text: businessType, x: -0.45, y: 0.3, fontSize: 0.07)
        placePOI(poi: businessTypeText, arView: arView)
//        let addressText = create3dText(text: CameraView.mockPOI.Address.ToString(), x: -0.45, y: 0.2, fontSize: 0.07)
//        placePOI(poi: addressText, arView: arView)
        let hours = "8 am to 9 pm"
        let hoursText = create3dText(text: hours, x: -0.45, y: 0.2, fontSize: 0.07)
        placePOI(poi: hoursText, arView: arView)
        let ratingText = create3dText(text: "Yelp Rating: \(CameraView.mockPOI.Rating!)/5 Stars", x: -0.45, y: 0.1, fontSize: 0.07)
        placePOI(poi: ratingText, arView: arView)
        let promptText = create3dText(text: "Click for more information", x: -0.45, y: -0.4, fontSize: 0.05)
        placePOI(poi: promptText, arView: arView)
        
        return arView
    }
        
        
    // have this take in a POI object
    func createPOI() -> ModelEntity {
        // For now, this function creates the test text
        // Will be used to create POI bubbles
        let txt = ModelEntity(mesh: MeshResource.generateText("Test Text", extrusionDepth: 0.01, font: .boldSystemFont(ofSize: 0.1), containerFrame: .zero, alignment: .center,lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        
        txt.generateCollisionShapes(recursive: true)
        return txt
    }
    
    // Create custom 3D text at specified local coordinate (x,y)
    func create3dText(text: String, x: Double = 0.0, y: Double = 0.0, fontSize: CGFloat = 0.1) -> ModelEntity {
        // Test placing text at location
        let x = x
        let y = y
        let rectOrigin = CGPoint(x: x, y: y)
        let rectSize = CGSize(width: 0, height: 0)
        let textFrameRect = CGRect(origin: rectOrigin, size: rectSize)
        
        let myTxt = ModelEntity(mesh: MeshResource.generateText(text, extrusionDepth: 0.01, font: .boldSystemFont(ofSize: fontSize), containerFrame: textFrameRect, alignment: .center, lineBreakMode: .byWordWrapping), materials: [SimpleMaterial(color: .black, isMetallic: true)])
        myTxt.generateCollisionShapes(recursive: true)
        return myTxt
    }
        
    // Creates bubble rectangle for POI
    func createBubble() -> ModelEntity {
        // Temporary plane test. POI bubble creation should be in a function.
        let planeWidth: Float = 1
        let planeHeight: Float = 1
        let planeCornerRadius: Float = 0.1
        let planeCollisionDepth: Float = 0.1
        let planeCollisionMass: Float = 0
        let planeColor = UIColor(red: 170, green: 166, blue: 255, alpha: 0.80)
        
        let plane = ModelEntity(
            mesh: MeshResource.generatePlane(width: planeWidth, height: planeHeight, cornerRadius: planeCornerRadius),
                materials: [SimpleMaterial(color: planeColor, isMetallic: false)],
            collisionShape: ShapeResource.generateBox(width: planeWidth, height: planeHeight, depth: planeCollisionDepth),
                mass: planeCollisionMass
            )
        
//        let bubbleAnchor = AnchorEntity()
//        bubbleAnchor.addChild(plane)
//        arView.scene.addAnchor(bubbleAnchor)
        return plane
    }
    
    // Could we modify placePOI to take an array, and have the createPOI return an array of ModelEntities to be placed on the same anchor?
    //  https://developer.apple.com/documentation/realitykit/entity
    func placePOI(poi: ModelEntity, arView: ARView) {
        // Place individual poi in scene
        // Places test text at default coordinate for now
        let poiAnchor = AnchorEntity()
        poiAnchor.addChild(poi)
        arView.scene.addAnchor(poiAnchor)
    }
    
    
    func updateUIView(_ uiView: ARView, context: Context) {
        //Place to unload old anchors and add new ones when the user moves
    }
    
    func makeCoordinator() -> CityCoordinator {
        CityCoordinator(tap: tap)
    }
    
    
    
}

class CityCoordinator: NSObject {
    weak var view: ARView?
    @ObservedObject var tap: Tap
    
    init(tap: Tap) {
        self.tap = tap
    }
    @objc func handleTap(_ recognizer: UITapGestureRecognizer) {
        guard let view = self.view else {return}
        
        let tapLocation = recognizer.location(in: view)
        if let entity = view.entity(at: tapLocation) as? ModelEntity {
            // In the future will relay specific entity back to main view
            // Will decide what POI View to open
            tap.clicked()
        }
    }
}


struct CityARView : View {
    
    @StateObject var tap = Tap()
    
    //Temporary test, will be removed when seperate files are created for AR objects
    static let mockAddress: Address = Address("101 street st.", "Columbia", "MO", "65201")
    static let mockPOI: POI = POI("Harpo's Columbia", "(417)-111-1111", 4.7, "$$", mockAddress, 3145)
    static let mockPOIs: [POI] = [mockPOI]
    static let mockReviews: [Review] = [
        Review("The food here was great. Would recommend bringing family.", 4.5, "Micheal Scott"),
        Review("Service was slow and waiters were rude. Not worth the price", 2, "Patrick Mahomes"),
        Review("Good food for a sunny day.", 3, "Tiger Woods")]
    static let mockViewModel: POIViewModel = POIViewModel(selectedBusiness: mockPOI, reviews: mockReviews)
    
    //Variables to be used in the future for tracking spcific entity tapped on
    //@State var viewModel: POIViewModel
    //@State var selectedBusiness: POI
    
    init() {

    }
    var body: some View {
        if(tap.tapped) {
            POIView(selectedBusiness: CityARView.mockPOI, viewModel: CityARView.mockViewModel)
        }
        else {
            CameraView(tap: tap).edgesIgnoringSafeArea(.all)
        }
    }
}

struct CityARView_Previews: PreviewProvider {
    static var previews: some View {
        CityARView()
    }
}
