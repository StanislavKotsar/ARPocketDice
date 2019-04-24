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

// MARK: - Game State

enum GameState: Int16 {
  case detectSurface
  case pointToSurface
  case swipeToPlay
}

class ViewController: UIViewController {
  
  // MARK: - Properties
  var trackingStatus: String = ""
  var focusNode: SCNNode!
  var diceNodes: [SCNNode] = []
  var diceCount: Int = 5
  var diceStyle: Int = 0
  var diceOffset: [SCNVector3] = [SCNVector3(0.0,0.0,0.0),
                                  SCNVector3(-0.05, 0.00, 0.0),
                                  SCNVector3(0.05, 0.00, 0.0),
                                  SCNVector3(-0.05, 0.05, 0.02),
                                  SCNVector3(0.05, 0.05, 0.02)]
  var gameState: GameState = .detectSurface
  var statusMessage: String = ""
  var focusPoint:CGPoint!
  
  // MARK: - Outlets
  
  @IBOutlet var sceneView: ARSCNView!
  @IBOutlet weak var statusLabel: UILabel!
  @IBOutlet weak var startButton: UIButton!
  @IBOutlet weak var styleButton: UIButton!
  @IBOutlet weak var resetButton: UIButton!
  
  // MARK: - Actions
  
  @IBAction func startButtonPressed(_ sender: Any) {
  }
  
  @IBAction func styleButtonPressed(_ sender: Any) {
    diceStyle = diceStyle >= 4 ? 0 : diceStyle + 1
  }
  
  @IBAction func resetButtonPressed(_ sender: Any) {
  }
  
  @IBAction func swipeUpGestureHandler(_ sender: Any) {
    guard let frame = sceneView.session.currentFrame else { return }
    for count in 0..<diceCount {
      throwDiceNode(transform: SCNMatrix4(frame.camera.transform),
                    offset: diceOffset[count])
    }
  }
  
  // MARK: - View Management
  
  @objc func orientationChanged() {
    focusPoint = CGPoint(x: view.center.x,
                         y: view.center.y + view.center.y * 0.25)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSceneView()
    initScene()
    initARSession()
    loadModels()
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
  
  func initSceneView() {
    sceneView.delegate = self
    sceneView.showsStatistics = true
    focusPoint = CGPoint(x: view.center.x,
                         y: view.center.y + view.center.y * 0.25)
    
    NotificationCenter.default.addObserver(self,
                                           selector: #selector(orientationChanged),
                                           name: UIDevice.orientationDidChangeNotification,
                                           object: nil)
  }
  
  func initScene() {
    let scene = SCNScene()
    scene.isPaused = false
    sceneView.scene = scene
    scene.lightingEnvironment.contents = "PokerDice.scnassets/Textures/Environment_CUBE.jpg"
    scene.lightingEnvironment.intensity = 2
    scene.physicsWorld.speed = 1
    scene.physicsWorld.timeStep = 1.0 / 60.0
  }
  
  func initARSession() {
    guard ARWorldTrackingConfiguration.isSupported else {
      print("*** ARConfig: AR World Tracking Not Supported")
      return
    }
    
    let config = ARWorldTrackingConfiguration()
    config.worldAlignment = .gravity
    config.providesAudioData = false
    config.planeDetection = .horizontal
    sceneView.session.run(config)
  }
  
  // MARK: - Load Models
  
  func loadModels() {
    // 1
    let diceScene = SCNScene(
      named: "PokerDice.scnassets/DiceScene.scn")!
    // 2
    for count in 0..<5 {
      // 3
      diceNodes.append(diceScene.rootNode.childNode(
        withName: "dice\(count)",
        recursively: false)!)
    }
    
    let focusScene = SCNScene(
      named: "PokerDice.scnassets/FocusScene.scn")!
    focusNode = focusScene.rootNode.childNode(
      withName: "focus", recursively: false)!
    
    sceneView.scene.rootNode.addChildNode(focusNode)
  }
  
  // MARK: - Helper Functions
  
  func throwDiceNode(transform: SCNMatrix4, offset: SCNVector3) {
    let position = SCNVector3(transform.m41 + offset.x,
                              transform.m42 + offset.y,
                              transform.m43 + offset.z)
    let diceNode = diceNodes[diceStyle].clone()
    diceNode.name = "dice"
    diceNode.position = position
    sceneView.scene.rootNode.addChildNode(diceNode)
    diceCount -= 1
  }
  
  func createARPlaneNode(
    planeAnchor: ARPlaneAnchor, color: UIColor) -> SCNNode {
    let planeGeometry = SCNPlane(
      width: CGFloat(planeAnchor.extent.x),
      height: CGFloat(planeAnchor.extent.z))
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents =
    "PokerDice.scnassets/Textures/Surface_DIFFUSE.png"
    planeGeometry.materials = [planeMaterial]
    // 1 - Create plane node
    let planeNode = SCNNode(geometry: planeGeometry)
    // 2
    planeNode.position = SCNVector3Make(
      planeAnchor.center.x, 0, planeAnchor.center.z)
    // 3
    planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
    // 4
    planeNode.physicsBody = createARPlanePhysics(
      geometry: planeGeometry)
    return planeNode
  }
  
  func updateARPlaneNode(
    planeNode: SCNNode, planeAchor: ARPlaneAnchor) {
    
    let planeGeometry = planeNode.geometry as! SCNPlane
    planeGeometry.width = CGFloat(planeAchor.extent.x)
    planeGeometry.height = CGFloat(planeAchor.extent.z)
    planeNode.position = SCNVector3Make(planeAchor.center.x, 0, planeAchor.center.z)
    planeNode.physicsBody = nil
    planeNode.physicsBody = createARPlanePhysics(
      geometry: planeGeometry)
    
  }
  
  func updateFocusNode() {
    // 1
    let results = self.sceneView.hitTest(self.focusPoint,
                                         types: [.existingPlaneUsingExtent])
    // 2
    if results.count == 1 {
      if let match = results.first {
        // 3
        let t = match.worldTransform
        // 4
        self.focusNode.position = SCNVector3( x: t.columns.3.x,
                                              y: t.columns.3.y,
                                              z: t.columns.3.z)
        self.gameState = .swipeToPlay
      }
    } else {
      // 5
      self.gameState = .pointToSurface
    }
  }
  
  func removeARPlaneNode (node: SCNNode) {
    for childNode in node.childNodes {
      childNode.removeFromParentNode()
    }
  }
  
  func updateDiceNodes() {
    // 1
    for node in sceneView.scene.rootNode.childNodes {
      // 2
      if node.name == "dice" {
        if  node.presentation.position.y < -2 {
          // 3
          node.removeFromParentNode()
          diceCount += 1
        }
      }
    }
  }
  
  func createARPlanePhysics(geometry: SCNGeometry) -> SCNPhysicsBody {
    // 1
    let physicsBody = SCNPhysicsBody(
      type: .kinematic,
      // 2
      shape: SCNPhysicsShape(geometry: geometry,
                             options: nil))
    // 3
    physicsBody.restitution = 0.5
    physicsBody.friction = 0.5
    // 4
    return physicsBody
  }
  
}

extension ViewController : ARSCNViewDelegate {
  
  // MARK: - SceneKit Management
  
  func renderer(_ renderer: SCNSceneRenderer,
                updateAtTime time: TimeInterval) {
    DispatchQueue.main.async {
      self.updateStatus()
      self.updateFocusNode()
      self.updateDiceNodes()
    }
  }
  
  func updateStatus() {
    // 1
    switch gameState {
    case .detectSurface:
      statusMessage = "Scan entire table surface...\nHit START when ready!"
    case .pointToSurface:
      statusMessage = "Point at designated surface first!"
    case .swipeToPlay:
      statusMessage = "Swipe UP to throw!\nTap on dice to collect it again."
    }
    // 2
    self.statusLabel.text = trackingStatus != "" ?
      "\(trackingStatus)" : "\(statusMessage)"
  }
  
  
  
  // MARK: - Session State Management
  
  func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
    switch camera.trackingState {
    case .notAvailable:
      trackingStatus = "Tacking:  Not available!"
    case .normal:
      trackingStatus = "Tracking: All Good!"
    case .limited(let reason):
      switch reason {
      case .excessiveMotion:
        trackingStatus = "Tracking: Limited due to excessive motion!"
      case .insufficientFeatures:
        trackingStatus = "Tracking: Limited due to insufficient features!"
      case .initializing:
        trackingStatus = "Tracking: Initializing..."
      case .relocalizing:
        trackingStatus = "Tracking: Relocalizing..."
      }
    }
  }
  
  // MARK: - Session Error Management
  
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
  // 1
  func renderer(_ renderer: SCNSceneRenderer,
                didAdd node: SCNNode, for anchor: ARAnchor) {
    // 2
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    // 3
    DispatchQueue.main.async {
      // 4
      let planeNode = self.createARPlaneNode(
        planeAnchor: planeAnchor,
        color: UIColor.yellow.withAlphaComponent(0.5))
      // 5
      node.addChildNode(planeNode)
    }
  }
  
  // 1
  func renderer(_ renderer: SCNSceneRenderer,
                didUpdate node: SCNNode, for anchor: ARAnchor) {
    // 2
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    // 3
    DispatchQueue.main.async {
      // 4
      self.updateARPlaneNode(planeNode: node.childNodes[0],
                             planeAchor: planeAnchor)
    }
  }
  
  func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
    guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
    DispatchQueue.main.async {
      self.removeARPlaneNode(node: node)
    }
  }
  
  
}
