//
//  ViewController.swift
//  CoinTap
//
//  Created by Ridwan Abdurrasyid on 17/09/19.
//  Copyright © 2019 Mentimun Mulus. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import LocalAuthentication

class ViewController: UIViewController, ARSCNViewDelegate {

    //Game Balance
    let coinAmount = 25
    let timeAmount = 10
    //
    
    @IBOutlet weak var titleLabelOutlet: UILabel!
    @IBOutlet weak var playButtonOutlet: UIButton!
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    
    let musicPlayer = MusicPlayer.instance
    let pedometer = Pedometer()
    var spawnerNode = SCNNode()
    var audioPlayer = AVAudioPlayer()
    var score : Int = 0
    var seconds = 10
    let labelSize : CGFloat = 25
    var timer = Timer()
    var isTimerRunning = false
    
    var context = LAContext()
    
    /// The available states of being logged in or not.
    enum AuthenticationState {
        case loggedin, loggedout
    }
    
    /// The current authentication state.
    var state = AuthenticationState.loggedout
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupLocalAuthentication()
        setupScore()
        setupTitle()
        setupTimer()
        setupPlayButton()
        setupScene()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupTitle(){
        titleLabelOutlet.isHidden = false
        titleLabelOutlet.layer.cornerRadius = titleLabelOutlet.frame.width / 2
        titleLabelOutlet.layer.borderWidth = 12
        titleLabelOutlet.layer.borderColor = #colorLiteral(red: 0.8, green: 0.2470588235, blue: 0.003921568627, alpha: 1)
        titleLabelOutlet.layer.backgroundColor = #colorLiteral(red: 1, green: 0.9843137255, blue: 0, alpha: 1)
        titleLabelOutlet.layer.masksToBounds = true
        titleLabelOutlet.font = UIFont(name: "04b_19", size: 90)
        view.sendSubviewToBack(titleLabelOutlet)
    }
    
    func setupPlayButton(){
        playButtonOutlet.isHidden = false
        playButtonOutlet.layer.cornerRadius = 0
        playButtonOutlet.layer.borderWidth = 12
        playButtonOutlet.layer.borderColor = #colorLiteral(red: 0.8, green: 0.2470588235, blue: 0.003921568627, alpha: 1)
        playButtonOutlet.titleLabel?.font = UIFont(name: "04b_19", size: 45)
        playButtonOutlet.transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse, .allowUserInteraction], animations: {
            self.playButtonOutlet.transform = CGAffineTransform(translationX: 0, y: 10)
        }, completion: { _ in
            
        })
    }
    
    

    func setupScene(){
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.automaticallyUpdatesLighting = true
        sceneView.autoenablesDefaultLighting = true
        
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    func setupScore(){
        score = 0
        scoreLabel.font = UIFont.init(name: "04b_19", size: CGFloat(labelSize))
        scoreLabel.text = String(format: "COINS %03d", score)
        scoreLabel.isHidden = true
    }
    
    
    @IBAction func playButtonDownAction(_ sender: Any) {
        let haptic = UINotificationFeedbackGenerator()
        haptic.notificationOccurred(.success)
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        checkFaceID()
    }
    
    func play(){
        startTimer()
        spawnCoins()
        hideUI()
        pedometer.startRecord()
    }
    
    func hideUI(){
        playButtonOutlet.isHidden = true
        titleLabelOutlet.isHidden = true
        scoreLabel.isHidden = false
    }
    
    func spawnCoins(){
        spawnerNode = CoinSpawner().spawnCoins(sceneView: sceneView, coinAmount: coinAmount)
        sceneView.scene.rootNode.addChildNode(spawnerNode)
    }
    
    func gameOver(){
        spawnerNode.removeFromParentNode()
        sceneView.session.pause()
        pedometer.stopRecord()
        performSegue(withIdentifier: "gameOverSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gameOverSegue" {
            if let vc = segue.destination as? GameOverViewController {
                vc.score = score
                vc.step = pedometer.steps
            }
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
    }
    
}

