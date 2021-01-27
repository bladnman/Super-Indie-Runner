//
//  LevelScene.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/26/21.
//

import SpriteKit

class LevelScene: SKScene {
  var world: Int!
  var level: Int!
  
  var popupLayer: SKNode!
  var sceneManagerDelegate: SceneManagerDelegate?
  
  override func didMove(to view: SKView) {
    layoutScene(for: world)
  }

  func layoutScene(for world: Int) {
    let backgroundImage = SKSpriteNode(imageNamed: GameConstants.StringConstants.worldBackgroundNames[world])
    backgroundImage.scale(to: frame.size, width: false, multiplier: 1.0)
    backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
    backgroundImage.zPosition = GameConstants.ZPositions.farBGZ
    addChild(backgroundImage)
    
    let titleLabel = SKLabelNode(fontNamed: GameConstants.StringConstants.gameFontName)
    titleLabel.text = "World \(world + 1)"
    titleLabel.fontSize = 200.0
    titleLabel.scale(to: frame.size, width: false, multiplier: 0.1)
    titleLabel.position = CGPoint(x: frame.midX, y: frame.maxY - titleLabel.frame.size.height*1.5)
    titleLabel.zPosition = GameConstants.ZPositions.worldZ
    addChild(titleLabel)
    
    let menuButton = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.menuButton, action: buttonHandler, index: 12)
    menuButton.scale(to: frame.size, width: true, multiplier: 0.2)
    menuButton.position = CGPoint(x: frame.midX, y: frame.minY + menuButton.frame.size.height/1.5)
    menuButton.zPosition = GameConstants.ZPositions.worldZ
    addChild(menuButton)
    
    // no previous world when on first world
    if world != 0 {
      let previousWorldButton = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.playButton, action: buttonHandler, index: 11)
      previousWorldButton.scale(to: frame.size, width: false, multiplier: 0.075)
      previousWorldButton.xScale *= -1 // mirror the image
      previousWorldButton.position = CGPoint(x: frame.minX + previousWorldButton.frame.width/1.5, y: frame.maxY - titleLabel.frame.size.height)
      previousWorldButton.zPosition = GameConstants.ZPositions.worldZ
      addChild(previousWorldButton)
    }
    
    // no previous world when on first world
    if world < GameConstants.StringConstants.worldBackgroundNames.count - 1 {
      let nextWorldButton = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.playButton, action: buttonHandler, index: 10)
      nextWorldButton.scale(to: frame.size, width: false, multiplier: 0.075)
      nextWorldButton.position = CGPoint(x: frame.maxX - nextWorldButton.frame.width/1.5, y: frame.maxY - titleLabel.frame.size.height)
      nextWorldButton.zPosition = GameConstants.ZPositions.worldZ
      addChild(nextWorldButton)
    }
    
    // LEVEL BUTTONS
    var level = 1
    let columnStartingPoint = frame.midX/2
    let rowStartingPoint = frame.midY + frame.midX/2

    for row in 0..<3 {
      for column in 0..<3 {
        let levelBox = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.emptyButton, action: buttonHandler, index: level)
        levelBox.position = CGPoint(x: columnStartingPoint + CGFloat(column) * columnStartingPoint, y: rowStartingPoint - CGFloat(row) * columnStartingPoint)
        levelBox.zPosition = GameConstants.ZPositions.worldZ
        addChild(levelBox)
        
        let levelLabel = SKLabelNode(fontNamed: GameConstants.StringConstants.gameFontName)
        levelLabel.fontSize = 200.0
        levelLabel.verticalAlignmentMode = .center
        levelLabel.text = "\(level)"
        if !UserDefaults.standard.bool(forKey: "Level_\(world)-\(level)") && level != 1 {
          levelBox.isUserInteractionEnabled = false
          levelBox.alpha = 0.75
        }
        levelLabel.scale(to: levelBox.size, width: false, multiplier: 0.5)
        levelLabel.zPosition = GameConstants.ZPositions.worldZ
        levelBox.addChild(levelLabel)
        
        levelBox.scale(to: frame.size, width: true, multiplier: 0.2)
        
        level += 1
      }
    }
    
  }

  func createAndShowLevelPopup(for level: Int) {
    self.level = level
    popupLayer = SKNode()
    popupLayer.position = CGPoint(x: frame.midX, y: frame.midY)
    
    let shadowLayer = SKSpriteNode(texture: nil, color: UIColor.darkGray, size: frame.size)
    shadowLayer.alpha = 0.7
    shadowLayer.isUserInteractionEnabled = false
    shadowLayer.zPosition = GameConstants.ZPositions.playerZ
    popupLayer.addChild(shadowLayer)
    
    let levelKey = "Level_\(world!)-\(level)"
    let levelPopup = ScorePopupNode(buttonHandlerDelegate: self, title: "\(world!)-\(level)", level: levelKey, texture: SKTexture(imageNamed: GameConstants.StringConstants.largePopup), score: ScoreManager.getCurrentScore(for: levelKey)[GameConstants.StringConstants.scoreScoreKey]!, coins: 4, animated: false)
    levelPopup.add(buttons: [3,1])
    levelPopup.scale(to: frame.size, width: true, multiplier: 0.8)
    levelPopup.zPosition = GameConstants.ZPositions.hudZ
    popupLayer.addChild(levelPopup)
    
    popupLayer.alpha = 0.0
    addChild(popupLayer)
    popupLayer.run(SKAction.fadeIn(withDuration: 0.2))
  }
  
  func buttonHandler(index: Int) {
    switch index {
    case 1, 2, 3, 4, 5, 6, 7, 8, 9:
      // levels
      createAndShowLevelPopup(for: index)
      break
    case 10:
      // next world
      sceneManagerDelegate?.presentLevelScene(for: world + 1)
    case 11:
      // previous world
      sceneManagerDelegate?.presentLevelScene(for: world - 1)
    case 12:
      // menu
      sceneManagerDelegate?.presentMenuScene()
    default:
      break
    }
  }
}

extension LevelScene: PopupButtonHandlerDelegate {
  func popupButtonHandler(index: Int) {
    switch index {
    case 3:
      // cancel
      popupLayer.run(SKAction.fadeOut(withDuration: 0.2), completion: {
        self.popupLayer.removeFromParent()
      })
    case 1:
      // play
      sceneManagerDelegate?.presentGameScene(for: level, in: world)
    default:
      break
    }
  }
}
