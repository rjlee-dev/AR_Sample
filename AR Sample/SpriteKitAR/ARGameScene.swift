//
//  ARGame.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-19.
//


import SpriteKit
import GameplayKit
import ARKit


/// State Machine control for game play
enum GameState: Int {
   /// Initial place holder
   case initial = 0
   
   /// Starts loading AR
   case startup
   
   /// Waiting for AR to load
   case loading
   
   /// Waits for user input to start playing
   case tapToStart
   
   /// Start main game play
   case play
   
   /// Game over with Win
   case win
   
   /// Game over with Lose
   case lose
}


class ARGameScene: SKScene {
   
   private enum Constance {
      static let TIMER_KEY = "timer_key"
      static let MAX_TIME = 20
      static let PLAY_AREA = ( xRadius: Float(2), yRadius: Float(2) )
      static let START_AMMO = 3
      static let PICKUP_DISTANCE: Float = 0.2
      static let GHOST_COUNT = 10
      static let BATTERY_COUNT = 9
   }
   
   var sceneView: ARSKView {
      return view as! ARSKView
   }
   
   var sight: SKSpriteNode!
   var ammoGuage: SKLabelNode!
   var tapLabel: SKLabelNode!
   var timeBar: SKShapeNode!
   
   var time: Int = 0 {
      didSet {
         timeBar.xScale = CGFloat(time) / CGFloat(Constance.MAX_TIME)
         timeBar.isHidden = !(time > 0)
      }
   }
   
   var ammo: Int = 0 {
      didSet {
         if ammo < 0 {
            ammo = 0
         }
         ammoGuage.text = String(repeating: "🔋", count: ammo)
      }
   }
   
   var gameState: GameState = .initial {
       didSet {
          print("Game State: \(gameState)")
          cleanUI(gameState: oldValue)
          updateUI(gameState: gameState)
       }
   }
   
   var gameLoop: (() -> ())?
   
   /// Build Game UI
   private func buildHud() {
      let topLeft = CGPoint(x: -(UIScreen.main.bounds.size.width/2), y: UIScreen.main.bounds.size.height/2)
      
      sight = SKSpriteNode(imageNamed: "sight")
      
      let timeLabel = SKLabelNode(text: "Time:")
      timeLabel.fontName = "ArialMT"
      timeLabel.fontColor = .systemBlue
      timeLabel.horizontalAlignmentMode = .left
      timeLabel.position = topLeft + CGPoint(x: 8, y: -70)
      addChild(timeLabel)
      
      timeBar = SKShapeNode(rect: CGRect(x: 0, y: 0, width: 250, height: 26), cornerRadius: 0)
      timeBar.fillColor = .systemYellow
      timeBar.strokeColor = .clear
      timeBar.position = topLeft + CGPoint(x: timeLabel.frame.size.width+14, y: -70)
      addChild(timeBar)
      
      let ammoLabel = SKLabelNode(text: "Ammo:")
      ammoLabel.fontName = "ArialMT"
      ammoLabel.fontColor = .systemBlue
      ammoLabel.horizontalAlignmentMode = .left
      ammoLabel.position = topLeft + CGPoint(x: 8, y: -108)
      addChild(ammoLabel)
      
      ammoGuage = SKLabelNode(text: "")
      ammoGuage.horizontalAlignmentMode = .left
      ammoGuage.position = topLeft + CGPoint(x: ammoLabel.frame.size.width + 14, y: -108)
      addChild(ammoGuage)
      
      tapLabel = SKLabelNode(text: "Tap to PLAY!")
      tapLabel.fontName = "Chalkduster"
      tapLabel.fontColor = .systemBlue
      tapLabel.horizontalAlignmentMode = .center
      tapLabel.position = CGPoint(x: 0, y: 50)
   }
   
   /// When SKView becomes added to view
   /// - Parameter view: SKView
   override func didMove(to view: SKView) {
      buildHud()
      gameState = .startup
   }
   
   /// Wait for AR to load
   private func waitForAR() {
      guard sceneView.session.currentFrame != nil else {
         return
      }
      gameState = .tapToStart
   }
   
   /// When AR is ready, place AR objects when ready
   private func setUpWorld() {
      guard let currentFrame = sceneView.session.currentFrame else {
         return
      }
  
      for _ in 0 ..< Constance.GHOST_COUNT {
         addObject(type: .ghost, to: currentFrame)
      }
      
      for _ in 0 ..< Constance.BATTERY_COUNT {
         addObject(type: .battery, to: currentFrame)
      }
   }
   
   /// Setup UI
   func setupGame() {
      ammo = Constance.START_AMMO
      time = Constance.MAX_TIME
   }
   
   /// Checks if no Ghosts to win game or if no ammo avaliable lose game
   func checkGameFinished() {
      guard let currentFrame = sceneView.session.currentFrame, gameState == .play else {
         return
      }
      
      let ghost = currentFrame.anchors.reduce(0) { count, element in
         if let node = sceneView.node(for: element), node.name == NodeType.ghost.rawValue {
             return count + 1
         }
         return count
     }
      
      if ghost == 0 {
         gameOver(win: true)
         return
      }
      
      let batteries = currentFrame.anchors.reduce(0) { count, element in
         if let node = sceneView.node(for: element), node.name == NodeType.battery.rawValue {
             return count + 1
         }
         return count
      }
      
      if ammo + batteries == 0 {
         gameOver()
      }
   }
   
   /// Adds timer to game
   func startTimer() {
      run(SKAction.repeatForever(SKAction.sequence([.run(countdown),
                                                    .wait(forDuration: 1)])),
          withKey: Constance.TIMER_KEY)
   }
   
   /// Runs every game tick
   func countdown() {
      time -= 1
      if time == 0 {
         gameOver()
      }
   }
   
   /// Finishes game
   /// - Parameter win: Did player win game
   func gameOver(win: Bool = false) {
      gameState = (win) ? .win : .lose
      removeAction(forKey: Constance.TIMER_KEY)
      guard let currentFrame = sceneView.session.currentFrame else {
         return
      }
      currentFrame.anchors.forEach { anchor in
         sceneView.session.remove(anchor: anchor)
      }
   }
      
   
   
   /// Adds objects by type radomly to the play area based of game type
   /// If phone is held upright, in a matrix identity:
   /// +(columns.3.x) is up and -(columns.3.x) is down
   /// +(columns.3.y) is right and -(columns.3.y) is left
   /// +(columns.3.z) is backward and -(columns.3.z) is forward
   /// - Parameters:
   ///   - type: Type of object to create
   ///   - currentFrame: currentFrame
   private func addObject(type: NodeType, to currentFrame: ARFrame) {
      var translation = matrix_identity_float4x4
      translation.columns.3.z = Float.random(in: -Constance.PLAY_AREA.xRadius...Constance.PLAY_AREA.xRadius)
      translation.columns.3.y = Float.random(in: -Constance.PLAY_AREA.yRadius...Constance.PLAY_AREA.yRadius)
      translation.columns.3.x = Float.random(in: -1...1)  
  
      let transform = currentFrame.camera.transform * translation
      let anchor = GameAnchor(transform: transform, type: type)
      sceneView.session.add(anchor: anchor)
   }
   
   /// Remove 1 Ammo and remove ammo from game play
   private func pickupAmmo(_ anchor: ARAnchor) {
      sceneView.session.remove(anchor: anchor)
      run(Sounds.pickUp)
      ammo += 1
   }
   
   /// Removes Ghost and checks if the game is over after a slight delay
   private func removeGhost(_ anchor: ARAnchor) {
      sceneView.session.remove(anchor: anchor)
      run(.afterDelay(0.5, runBlock: checkGameFinished))
   }
   
   
   /// SpriteKit Tracking touches
   override func touchesBegan(_ touches: Set<UITouch>,
                              with event: UIEvent?) {
      switch gameState {
         case .tapToStart:
            gameState = .play
         case .play:
            shootWeapon()
         default :
            break
      }
   }
   /// Checks ammo then fires then check if there is a hit and will remove ghost if hit
   func shootWeapon() {
      guard ammo > 0 else { return }
      ammo -= 1
      let location = sight.position
      let hitNodes = nodes(at: location)
      let hitGhost = hitNodes.first(where: {$0.name == NodeType.ghost.rawValue})

      run(Sounds.fire)
      if let hitGhost = hitGhost, let anchor = sceneView.anchor(for: hitGhost) {
         let action = SKAction.run {
            self.removeGhost(anchor)
            self.sceneView.session.remove(anchor: anchor)
         }
         let group = SKAction.group([Sounds.hit, action])
         let sequence: [SKAction] = [.wait(forDuration: 0.3), group]
         hitGhost.run(SKAction.sequence(sequence))
      }
      run(.afterDelay(0.5, runBlock: checkGameFinished))
   }
   
   /// Shades the ghosts
   /// - Parameters:
   ///   - frame: ARFrame that was unwrapped from current frame
   ///   - lightEstimate: unwrapped light estimate from current frame
   private func updateShading(frame: ARFrame, lightEstimate: ARLightEstimate) {
      let neutralIntensity: CGFloat = 1000
      let ambientIntensity = min(lightEstimate.ambientIntensity,neutralIntensity)
      let blendFactor = 1 - ambientIntensity / neutralIntensity
      
      for case let node as SKSpriteNode in children where node.name == NodeType.ghost.rawValue {
         node.color = .black
         node.colorBlendFactor = blendFactor
      }
   }
   
   /// Checks if user is touching ammo
   /// - Parameter frame: ARFrame that was unwrapped from current frame
   private func checkBatteryPickup(frame: ARFrame) {
      for anchor in frame.anchors {
         guard let node = sceneView.node(for: anchor), node.name == NodeType.battery.rawValue else {
            continue
         }
         
         let distance = simd_distance(anchor.transform.columns.3, frame.camera.transform.columns.3)
         if distance < Constance.PICKUP_DISTANCE {
            pickupAmmo(anchor)
            break
         }
      }
   }
   
   /// Main game play loop. Checks for battery pickup and updates the shading for ghosts
   private func updateGamePlay() {
      guard let currentFrame = sceneView.session.currentFrame,
            let lightEstimate = currentFrame.lightEstimate else {
         return
      }
      updateShading(frame: currentFrame, lightEstimate: lightEstimate)
      checkBatteryPickup(frame: currentFrame)
   }
   
   /// Main SpriteKit update
   /// - Parameter currentTime: delta time
   override func update(_ currentTime: TimeInterval) {
      gameLoop?()
   }
   
}

//  MARK: - State Managment
extension ARGameScene {
   
   /// Cleans up for previous game state
   /// - Parameter gameState: current gameState
   private func cleanUI(gameState: GameState) {
       switch gameState {
       case .tapToStart:
          tapLabel.removeFromParent()
       case .win, .lose:
          sight.removeFromParent()
          tapLabel.removeFromParent()
       default:
           break
       }
   }
   
   /// Changes game state
   /// - Parameter gameState: current gameState
   private func updateUI(gameState: GameState) {
      switch gameState {
      case .startup:
         gameLoop = waitForAR
         self.gameState = .loading
      case .loading:
         break
      case .tapToStart:
         addChild(tapLabel)
         gameLoop = nil
      case .play:
         addChild(sight)
         gameLoop = updateGamePlay
         setUpWorld()
         setupGame()
         startTimer()
      case .win:
         run(Sounds.win)
         self.gameState = .startup
      case .lose:
         run(Sounds.lose)
         self.gameState = .startup
      default:
         break
      }
   }
   
}
