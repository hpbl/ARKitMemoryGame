//
//  ViewController.swift
//  MemoryAR
//
//  Created by Hilton Pintor Bezerra Leite on 13/09/2018.
//  Copyright © 2018 Hilton Pintor Bezerra Leite. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {
    
    var score = 0
    let allpieces = [1, 2, 3, 4, 5, 6]
    var cobinations: [(Int, Int, UIColor)] = [
        (1, 2, .red), (3, 4, .green), (5, 6, .blue)
    ]

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let referenceImages = ARReferenceImage
            .referenceImages(
                inGroupNamed: "AR Resources",
                bundle: nil
            )
            else { fatalError("Missing expected asset") }
        
        
        // Create a session configuration
        let configuration = ARImageTrackingConfiguration()
        configuration.maximumNumberOfTrackedImages = 2
        configuration.trackingImages = referenceImages

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

    
    func colorForImage(number: Int) -> UIColor? {
        for (firstNumber, secondNumber, color) in self.cobinations {
            if number == firstNumber || number == secondNumber {
                return color
            }
        }
        
        return nil
    }
}


// MARK: - ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let referenceImage = imageAnchor.referenceImage
        
        let plane = SCNPlane(width: referenceImage.physicalSize.width, height: referenceImage.physicalSize.height)
        let planeNode = SCNNode(geometry: plane)
        planeNode.opacity = 0.5
        planeNode.eulerAngles.x = -.pi / 2
        
        planeNode.geometry?.firstMaterial?.diffuse.contents = self.colorForImage(
            number: Int(referenceImage.name!)!
        )
        
        node.addChildNode(planeNode)
    }
}
