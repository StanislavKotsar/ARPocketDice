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
    
    // MARK: - Session State Management
    
    // MARK: - Session Error Managent
    
    // MARK: - Plane Management
}
