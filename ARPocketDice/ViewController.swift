//
//  ViewController.swift
//  ARPocketDice
//
//  Created by Stas on 06/04/2019.
//  Copyright © 2019 Stas. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    // MARK: - Properties
    var trackingStatus: String = "Normal"
    
    // MARK: - Outlets
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Actions
    @IBAction func startButtonPressed(_ sender: UIButton) {
        
    }
    
    @IBAction func styleButtonTapped(_ sender: UIButton) {
        
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        
    }
    
    // MARK: - View Management
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSceneView()
        initScene()
        initARSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("*** ViewWillAppear()")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("*** ViewWillDisappear()")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("*** DidReceiveMemoryWarning()")
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Initialization
    
    private func initSceneView() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showBoundingBoxes, .showWireframe]
    }
    
    private func initScene() {
        let scene = SCNScene(named: "PokerDice.scnassets/SimpleScene.scn")!
        scene.isPaused = false
        sceneView.scene = scene
    }
    
    private func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        // 1
        let config = ARWorldTrackingConfiguration()
        // 2
        config.worldAlignment = .gravity
        // 3
        config.providesAudioData = false
        sceneView.session.run(config)
    }
}


extension ViewController: ARSCNViewDelegate {
    
    // MARK: - SceneKit Management
    func renderer(_ renderer: SCNSceneRenderer,
                  updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.statusLabel.text = self.trackingStatus
        }
    }
    // MARK: - Session State Management
    func session(_ session: ARSession,
                 cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        // 1
        case .notAvailable:
            trackingStatus = "Tracking: Not available!"
        // 2
        case .normal:
            trackingStatus = "Tracking: All good!"
        // 3
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                trackingStatus = "Tracking: Limited due to excessive motion!"
            // 3.1
            case .insufficientFeatures:
                trackingStatus = "Tracking: Limited due to insufficient features!"
            // 3.2
            case .initializing:
                trackingStatus = "Tracking: Initializing..."
            // 3.3
            case .relocalizing:
                trackingStatus = "Tracking: Relocalizing..."
            }
        }
    }
    // MARK: - Session Error Managent
    func session(_ session: ARSession,
                 didFailWithError error: Error) {
        trackingStatus = "AR Session Failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        trackingStatus = "AR Session Was Interrupted!"
    }
    func sessionInterruptionEnded(_ session: ARSession) {
        trackingStatus = "AR Session Interruption Ended"
    }
    // MARK: - Plane Management
    
}
