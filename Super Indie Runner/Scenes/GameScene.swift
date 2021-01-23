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
  var touch: Bool = false
  var brake: Bool = false

  var lastTime: TimeInterval = 0
  var dt: TimeInterval = 0
  
  var gameState: GameState = .ready {
    willSet {
      switch newValue {
      case .ongoing:
        player.state = .run
      case .finished:
        player.state = .idle
      case .ready:
        player.state = .idle
      default:
        break
      }
    }
  }
  
  override func didMove(to view: SKView) {
    physicsWorld.contactDelegate = self
    physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
    
    // set up and edge frame at the bottom of the frame (off-screen)
    physicsBody = SKPhysicsBody(edgeFrom: CGPoint(x: frame.minX, y: frame.minY), to: CGPoint(x: frame.maxX, y: frame.minY))
    physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.frameCategory
    physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.playerCategory
    
    createLayers()
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
    
    load(level: "Level_0-1")
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
  }
  
  func handleEnemyContact() {
    die(reason: 0)
  }
  
  func die(reason:Int) {
    gameState = .finished
    player.turnGravity(on: false)
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
      
    // ENEMY
    case GameConstants.PhysicsCategories.playerCategory | GameConstants.PhysicsCategories.enemyCategory:
      handleEnemyContact()
      
    // ENEMY
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
