//
//  GameHUD.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/24/21.
//

import SpriteKit

class GameHUD: SKSpriteNode, HUDDelegate {
  
  var coinLabel: SKLabelNode
  var superCoinCounter: SKSpriteNode
  
  init(with size: CGSize) {
    coinLabel = SKLabelNode(fontNamed: GameConstants.StringConstants.gameFontName)
    superCoinCounter = SKSpriteNode(texture: nil, color: UIColor.clear, size: CGSize(width: size.width*0.3, height: size.height*0.8))
    super.init(texture: nil, color: UIColor.clear, size: size)
    
    coinLabel.verticalAlignmentMode = .center
    coinLabel.text = "0"
    coinLabel.fontSize = 200.0
    coinLabel.scale(to: frame.size, width: false, multiplier: 0.8)
    coinLabel.position = CGPoint(x: frame.maxX - coinLabel.frame.size.width*2, y: frame.midY)
    coinLabel.zPosition = GameConstants.ZPositions.hudZ
    addChild(coinLabel)
    
    superCoinCounter.position = CGPoint(x: frame.minX + superCoinCounter.frame.size.width/2, y: frame.midY)
    superCoinCounter.zPosition = GameConstants.ZPositions.hudZ
    addChild(superCoinCounter)
    
    let sccWidth = superCoinCounter.size.width
    for i in 0..<3 {
      let emptySlot = SKSpriteNode(imageNamed: GameConstants.StringConstants.superCoinImageName)
      emptySlot.name = String(i)
      emptySlot.alpha = 0.5
      emptySlot.scale(to: superCoinCounter.size, width: true, multiplier: 0.3)
      emptySlot.position = CGPoint(x: -sccWidth/2 + emptySlot.size.width/2 + CGFloat(i)*sccWidth/2 + sccWidth*0.05, y: superCoinCounter.frame.midY)
      superCoinCounter.addChild(emptySlot)
    }

  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  func updateCoinLabel(coins: Int) {
    coinLabel.text = "\(coins)"
  }
  func addSuperCoin(index: Int) {
    if let emptySlot = superCoinCounter[String(index)].first as? SKSpriteNode {
      emptySlot.alpha = 1.0
    }
  }
}
