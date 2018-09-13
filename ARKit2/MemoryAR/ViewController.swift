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
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var winnerLabel: UILabel!
    
    var score = 0 {
        didSet {
            DispatchQueue.main.async {
                if self.score == self.cobinations.count {
                    self.winnerLabel.isHidden = false
                }
                self.scoreLabel.text = "score: \(self.score)"
            }
        }
    }
    let allPieces = [1, 2, 3, 4, 5, 6]
    var currentPiecesTracked: [Int] = []
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
    
    func foundPiece(_ number: Int) {
        self.currentPiecesTracked.append(number)
        
        if self.currentPiecesTracked.count == 2 {
            let firstPiece = self.currentPiecesTracked[0]
            let secondPiece = self.currentPiecesTracked[1]
            if self.colorForImage(number: firstPiece) == self.colorForImage(number: secondPiece) {
                self.score = self.score + 1
                
                if let imageConfig = self.sceneView.session.configuration as? ARImageTrackingConfiguration {
                    let referenceImages = imageConfig.trackingImages.filter { (referenceImage) -> Bool in
                        Int(referenceImage.name!)! == firstPiece || Int(referenceImage.name!)! == secondPiece
                    }
                    
                    referenceImages.forEach { (image) in
                        imageConfig.trackingImages.remove(image)
                    }
                    
                    self.sceneView.session.run(imageConfig)
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                        self.sceneView.scene.rootNode.enumerateChildNodes { (node, _) in
                            node.removeFromParentNode()
                        }
                    }
                }
            }
        }
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
        
        
        let pieceName = Int(referenceImage.name!)!
        planeNode.geometry?.firstMaterial?.diffuse.contents = self.colorForImage(
            number: pieceName
        )
        
        node.addChildNode(planeNode)
        
        self.foundPiece(pieceName)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let imageAnchor = anchor as? ARImageAnchor{
            if !imageAnchor.isTracked {
                // The image is lost
                self.currentPiecesTracked.removeAll { (element) -> Bool in
                    element == Int(imageAnchor.name!)
                }
                self.sceneView.session.remove(anchor: anchor)
                print("removed \(imageAnchor.name!)")
            }
        }
    }
}
