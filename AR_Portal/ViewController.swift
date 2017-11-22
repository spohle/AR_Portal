//
//  ViewController.swift
//  AR_Portal
//
//  Created by Pohle, Sven on 11/22/17.
//  Copyright © 2017 Pohle, Sven. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var arView: ARSCNView!
    @IBOutlet weak var uiPlaneLabel: UILabel!
    let configuration = ARWorldTrackingConfiguration()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.arView.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.arView.addGestureRecognizer(tapGestureRecognizer)
        
        self.arView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.configuration.planeDetection = .horizontal
        self.arView.session.run(configuration)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        guard let sceneView = sender.view as? ARSCNView else { return }
        
        let touchLocation = sender.location(in: sceneView)
        let hitTestResult = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
        
        if !hitTestResult.isEmpty {
            self.addPortal(hitTestResult: hitTestResult.first!)
        } else {
            
        }
    }
    
    func addPortal(hitTestResult: ARHitTestResult) {
        let portalScene = SCNScene(named: "Portal.scnassets/Portal.scn")
        let portalNode = portalScene?.rootNode.childNode(withName: "Portal", recursively: false)
        let transform = hitTestResult.worldTransform
        let planeXPos = transform.columns.3.x
        let planeYPos = transform.columns.3.y
        let planeZPos = transform.columns.3.z
        
        portalNode?.position = SCNVector3(planeXPos, planeYPos, planeZPos)
        self.arView.scene.rootNode.addChildNode(portalNode!)
        self.addPlane(nodeName: "roof", portalNode: portalNode!, imageName: "top")
        self.addPlane(nodeName: "floor", portalNode: portalNode!, imageName: "floor")
        self.addPlane(nodeName: "wallLeft", portalNode: portalNode!, imageName: "left")
        self.addPlane(nodeName: "wallRight", portalNode: portalNode!, imageName: "right")
        self.addPlane(nodeName: "wallBack", portalNode: portalNode!, imageName: "back")
        self.addPlane(nodeName: "doorLeft", portalNode: portalNode!, imageName: "grid")
        self.addPlane(nodeName: "doorRight", portalNode: portalNode!, imageName: "grid")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
        DispatchQueue.main.async {
            self.uiPlaneLabel.isHidden = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.uiPlaneLabel.isHidden = true
        }
    }
    
    func addPlane(nodeName: String, portalNode: SCNNode, imageName: String) {
        if let childNode = portalNode.childNode(withName: nodeName, recursively: true) {
            let imagePath = "Portal.scnassets/\(imageName).png"
            childNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: imagePath)
        }
    }
}

