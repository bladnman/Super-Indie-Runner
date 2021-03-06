//
//  GameScene.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/22/21.
//

import SpriteKit

enum GameState {
  case ready, ongoing, paused, finished
}

class GameScene: SKScene {
  var worldLayer: Layer!
  var backgroundLayer: RepeatingLayer!
  var player: Player!
  var mapNode: SKNode!
  var tileMap: SKNode!
  var popup: PopupNode?
  var soundPlayer = SoundPlayer()
  
  var gameState: GameState = .ready {
    willSet {
      switch newValue {
      case .ongoing:
        player.state = .run
        pauseEnemies(bool: false)
      case .finished, .paused:
        player.state = .idle
        pauseEnemies(bool: true)
      case .ready:
        player.state = .idle
      }
    }
  }
  
  var touch: Bool = false
  var brake: Bool = false
  var coins = 0
  var superCoins = 0
  var world: Int
  var level: Int
  var levelKey: String
  
  var sceneManagerDelegate: SceneManagerDelegate?
  
  var lastTime: TimeInterval = 0
  var dt: TimeInterval = 0
  
  var hudDelegate: HUDDelegate?
  
  init(size: CGSize, world: Int, level: Int, sceneManagerDelegate: SceneManagerDelegate) {
    self.world = world
    self.level = level
    self.levelKey = "Level_\(world)-\(level)"
    self.sceneManagerDelegate = sceneManagerDelegate
    super.init(size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func didMove(to view: SKView) {
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
    
    // set up and edge frame at the bottom of the frame (off-screen)
    physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.minY))
    physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.frameCategory
    physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.playerCategory
    
    createLayers()
    
    // make sure animations kick off (workaround)
    self.isPaused = true
    self.isPaused = false
  }
  
  func createLayers() {
    worldLayer = Layer()
    addChild(worldLayer)
    worldLayer.layerVelocity = CGPoint(x: -200, y: 0)
    worldLayer.zPosition = GameConstants.ZPositions.worldZ
    
    backgroundLayer = RepeatingLayer()
    backgroundLayer.zPosition = GameConstants.ZPositions.farBGZ
    addChild(backgroundLayer)
    
    // create 2 copies of the background and add them
    for i in 0...1 {
      let backgroundImage = SKSpriteNode(imageNamed: GameConstants.StringConstants.worldBackgroundNames[0])
      backgroundImage.name = String(i)
      backgroundImage.scale(to: frame.size, width: false, multiplier: 1.0)
      backgroundImage.anchorPoint = CGPoint.zero
      backgroundImage.position = CGPoint(x: CGFloat(i) * backgroundImage.size.width, y: 0.0)
      
      backgroundLayer.addChild(backgroundImage)
    }
    
    backgroundLayer.layerVelocity = CGPoint(x: -100.0, y: 0.0)
    
    load(level: levelKey)
  }
  func load(level: String) {
    if let levelNode = SKNode.unarchiveFromFile(file: level) {
      mapNode = levelNode
      worldLayer.addChild(mapNode)
      loadTileMap()
    }
  }
  func loadTileMap() {
    if let groundTiles = mapNode.childNode(withName: GameConstants.StringConstants.groundTilesName) as? SKTileMapNode {
      tileMap = groundTiles
      tileMap.scale(to: frame.size, width: false, multiplier: 1.0)
      PhysicsHelper.addPhysicsBody(to: groundTiles, with: "ground")
      for child in groundTiles.children {
        if let sprite = child as? SKSpriteNode, sprite.name != nil {
          ObjectHelper.handleChild(sprite: sprite, with: sprite.name!)
        }
      }
    }
    
    addPlayer()
    addHUD()
  }
  
  func addPlayer() {
    player = Player(imageNamed: GameConstants.StringConstants.playerImageName)
    player.scale(to: frame.size, width: false, multiplier: 0.1)
    player.name = GameConstants.StringConstants.playerName
    PhysicsHelper.addPhysicsBody(to: player, with: player.name!)
    
    player.position = CGPoint(x: frame.midX / 2.0, y: frame.midY)
    player.zPosition = GameConstants.ZPositions.playerZ
    player.loadTextures()
    player.state = PlayerState.idle
    addChild(player)
    addPlayerActions()
  }
  func addPlayerActions() {
    let up = SKAction.moveBy(x: 0.0, y: frame.size.height/4, duration: 0.4)
    up.timingMode = .easeOut
    
    player.createUserData(entry: up, forKey: GameConstants.StringConstants.jumpUpActionKey)
    
    let move = SKAction.moveBy(x: 0.0, y: player.size.height, duration: 0.4)
    let jump = SKAction.animate(with: player.jumpFrames, timePerFrame: 0.4/Double(player.jumpFrames.count))
    let group = SKAction.group([move, jump])
    player.createUserData(entry: group, forKey: GameConstants.StringConstants.breakDescendActionKey)
    
  }
  func jump() {
    player.airborne = true
    player.turnGravity(on: false)
    player.run(player.userData?.value(forKey: GameConstants.StringConstants.jumpUpActionKey) as! SKAction) {
      // still touching? double jump
      if self.touch {
        self.player.run(self.player.userData?.value(forKey: GameConstants.StringConstants.jumpUpActionKey) as! SKAction) {
          self.player.turnGravity(on: true)
        }
      }
    }
  }
  func brakeDescend() {
    brake = true
    player.physicsBody!.velocity.dy = 0.0
    player.run(player.userData?.value(forKey: GameConstants.StringConstants.breakDescendActionKey) as! SKAction)
    if let brakeSpark = ParticleHelper.addParticleEffect(name: GameConstants.StringConstants.brakeSparkEmitter, particlePositionRange: CGVector(dx: 30.0, dy: 30.0), position: CGPoint(x: player.position.x, y: player.position.y - player.size.height/2)) {
      brakeSpark.zPosition = GameConstants.ZPositions.objectZ
      addChild(brakeSpark)
    }
    player.run(player.userData?.value(forKey: GameConstants.StringConstants.breakDescendActionKey) as! SKAction) {
      ParticleHelper.removeParticleEffect(name: GameConstants.StringConstants.brakeSparkEmitter, from: self)
    }
  }
  
  func handleEnemyContact() {
    if player.invincible { return }
    die(reason: 0)
  }
  func pauseEnemies(bool: Bool) {
    for enemy in tileMap[GameConstants.StringConstants.enemyName] {
      enemy.isPaused = bool
    }
  }
  func handleCollectible(sprite: SKSpriteNode) {
    switch sprite.name! {
    case GameConstants.StringConstants.coinName,
         _ where GameConstants.StringConstants.superCoinNames.contains(sprite.name!):
      collectCoin(sprite: sprite)
      run(soundPlayer.coinSound)
    case GameConstants.StringConstants.powerupName:
      player.activatePowerup(active: true)
      run(soundPlayer.powerupSound)
    default:
      break
    }
  }
  func collectCoin(sprite: SKSpriteNode) {
    if GameConstants.StringConstants.superCoinNames.contains(sprite.name!) {
      superCoins += 1
      for index in 0..<3 {
        if GameConstants.StringConstants.superCoinNames[index] == sprite.name! {
          hudDelegate?.addSuperCoin(index: index)
        }
      }
    } else {
      coins += 1
      hudDelegate?.updateCoinLabel(coins: coins)
    }
    
    if let coinDust = ParticleHelper.addParticleEffect(name: GameConstants.StringConstants.coinDustEmitterKey, particlePositionRange: CGVector(dx: 1.0, dy: 1.0), position: CGPoint.zero) {
      coinDust.zPosition = GameConstants.ZPositions.objectZ
      sprite.addChild(coinDust)
      sprite.run(SKAction.fadeOut(withDuration: 0.4)) {
        coinDust.removeFromParent()
        sprite.removeFromParent()
      }
    }
  }
  func buttonHandler(index: Int) {
    if gameState == .ongoing {
      gameState = .paused
      createAndShowPopup(type: 0, title: GameConstants.StringConstants.pauseKey)
    }
  }
  func addHUD() {
    let hud = GameHUD(with: CGSize(width: frame.width, height: frame.height*0.1))
    hud.position = CGPoint(x: frame.midX, y: frame.maxY - frame.height*0.05)
    hud.zPosition = GameConstants.ZPositions.hudZ
    hudDelegate = hud
    addChild(hud)
    
    let pauseButton = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.pauseButton, action: buttonHandler, index: 0)
    pauseButton.scale(to: frame.size, width: false, multiplier: 0.1)
    pauseButton.position = CGPoint(x: frame.midX, y: frame.maxY - pauseButton.size.height/1.9)
    pauseButton.zPosition = GameConstants.ZPositions.hudZ
    addChild(pauseButton)
  }
  func createAndShowPopup(type: Int, title: String) {
    switch type {
    case 0:
      popup = PopupNode(withTitle: title, and: SKTexture(imageNamed: GameConstants.StringConstants.smallPopup), buttonHandlerDelegate: self)
      popup!.add(buttons: [0,3,2])
    default:
      popup = ScorePopupNode(buttonHandlerDelegate: self, title: title, level: levelKey, texture: SKTexture(imageNamed: GameConstants.StringConstants.largePopup), score: coins, coins: superCoins, animated: true)
      popup!.add(buttons: [2,1,0])
    }
    
    popup!.position = CGPoint(x: frame.midX, y: frame.midY)
    popup!.zPosition = GameConstants.ZPositions.hudZ
    popup!.scale(to: frame.size, width: true, multiplier: 0.8)
    addChild(popup!)
  }
  func die(reason:Int) {
    gameState = .finished
    player.turnGravity(on: false)
    run(soundPlayer.deathSound)
    let deathAnimation:SKAction!
    switch reason {
    case 0:
      deathAnimation = SKAction.animate(with: player.dieFrames, timePerFrame: 0.1, resize: true, restore: true)
    case 1:
      let up = SKAction.moveTo(y: frame.midY, duration: 0.25)
      let wait = SKAction.wait(forDuration: 0.1)
      let down = SKAction.moveTo(y: -player.size.height, duration: 0.2)
      deathAnimation = SKAction.sequence([up, wait, down])

    default:
      deathAnimation = SKAction.animate(with: player.dieFrames, timePerFrame: 0.1, resize: true, restore: true)
    }
    
//    player.removeAllActions()
    player.run(deathAnimation) {
      self.player.removeFromParent()
      self.createAndShowPopup(type: 1, title: GameConstants.StringConstants.failedKey)
    }
  }
  func finishGame() {
    run(soundPlayer.completedSound)
    gameState = .finished
    var stars = 0
    let percentage = CGFloat(coins)/100.0
    if percentage >= 0.8 {
      stars = 3
    } else if percentage > 0.4 {
      stars = 2
    } else  if coins >= 1 {
      stars = 1
    }
    let scores = [
      GameConstants.StringConstants.scoreScoreKey: coins,
      GameConstants.StringConstants.scoreStarsKey: stars,
      GameConstants.StringConstants.scoreCoinsKey: superCoins,
    ]
    ScoreManager.compare(scores: [scores], in: levelKey) // will save high scores
    createAndShowPopup(type: 1, title: GameConstants.StringConstants.completedKey)
    
    // unlock next level (if we had one)
    if level < 9 {
      let nextLevelKey = "Level_\(world)-\(level+1)"
      UserDefaults.standard.set(true, forKey: nextLevelKey)
      UserDefaults.standard.synchronize()
    }
    
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    switch gameState {
    case .ready:
      gameState = .ongoing
    case .ongoing:
      touch = true
      if !player.airborne {
        jump()
      } else if !brake {
        brakeDescend()
      }
    default:
      break
    }
  }
  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    touch = false
    player.turnGravity(on: true)
  }
  override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    touch = false
    player.turnGravity(on: true)
  }
  override func update(_ currentTime: TimeInterval) {
    // if not the first time calling, calculate
    // the DELTA of time (dt)
    if lastTime > 0 {
      dt = currentTime - lastTime
    }
    
    lastTime = currentTime
    
    if gameState == .ongoing {
      worldLayer.update(dt)
      backgroundLayer.update(dt)
    }
  }
  override func didSimulatePhysics() {
    for node in tileMap[GameConstants.StringConstants.groundNodeName] {
      if let groundNode = node as? GroundNode {
        let groundY = (groundNode.position.y + groundNode.size.height) * tileMap.yScale
        let playerY = player.position.y - player.size.height/3
        groundNode.isBodyActivated = playerY > groundY
      }
    }
  }
}


extension GameScene: SKPhysicsContactDelegate {
  func didBegin(_ contact: SKPhysicsContact) {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
    
    // GROUND
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.groundCategory:
      player.airborne = false
      brake = false
      
    // FINISH
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.finishCategory:
      gameState = .finished
      self.finishGame()
      
    // ENEMY
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.enemyCategory:
      handleEnemyContact()

    // COLLECTIBLE
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.collectibleCategory:
      let collectible = contact.bodyA.node?.name == player.name ? contact.bodyB.node as! SKSpriteNode : contact.bodyA.node as! SKSpriteNode
      handleCollectible(sprite: collectible)

    // FRAME
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.frameCategory:
      physicsBody = nil
      die(reason: 1)
      
    default:
      break
    }
  }
  func didEnd(_ contact: SKPhysicsContact) {
    let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
    switch contactMask {
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.groundCategory:
      player.airborne = true
    default:
      break
    }
  }
}

extension GameScene: PopupButtonHandlerDelegate {
  func popupButtonHandler(index: Int) {
    switch index {
    case 0:
      // Menu
      sceneManagerDelegate?.presentMenuScene()
    case 1:
      // Play
      sceneManagerDelegate?.presentLevelScene(for: world)
    case 2:
      // Retry
      sceneManagerDelegate?.presentGameScene(for: level, in: world)
    case 3:
      // Cancel
      popup!.run(SKAction.fadeOut(withDuration: 0.2)) {
        self.popup!.removeFromParent()
        self.gameState = .ongoing
      }
      break
    default:
      break
    }
  }
}
