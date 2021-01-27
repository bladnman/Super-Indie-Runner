//
//  MenuScene.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/26/21.
//

import SpriteKit

class MenuScene: SKScene {
  
  var sceneManagerDelegate: SceneManagerDelegate?

  override func didMove(to view: SKView) {
    layoutView()
  }
  func layoutView() {
    let backgroundImage = SKSpriteNode(imageNamed: GameConstants.StringConstants.menuBackground)
    backgroundImage.scale(to: frame.size, width: true, multiplier: 1.0)
    backgroundImage.position = CGPoint(x: frame.midX, y: frame.midY)
    backgroundImage.zPosition = GameConstants.ZPositions.farBGZ
    addChild(backgroundImage)
    
    
    
    let logoLabel = SKLabelNode(fontNamed: GameConstants.StringConstants.gameFontName)
    logoLabel.text = GameConstants.StringConstants.gameName
    logoLabel.fontSize = 200.0
    logoLabel.fontColor = UIColor.white
    logoLabel.scale(to: frame.size, width: true, multiplier: 0.8)
    logoLabel.position = CGPoint(x: frame.midX, y: frame.maxY*0.75 - logoLabel.frame.size.height/2)
    logoLabel.zPosition = GameConstants.ZPositions.hudZ
    addChild(logoLabel)
    
    let startButton = SpriteKitButton(defaultButtonImage: GameConstants.StringConstants.playButton, action: goToLevelScene, index: 0)
    startButton.scale(to: frame.size, width: false, multiplier: 0.1)
    startButton.position = CGPoint(x: frame.midX, y: frame.midY)
    startButton.zPosition = GameConstants.ZPositions.hudZ
    addChild(startButton)
  }
  func goToLevelScene(_: Int) {
    sceneManagerDelegate?.presentLevelScene(for: 0)
  }
}
