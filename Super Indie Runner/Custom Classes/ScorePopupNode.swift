//
//  PopupNode.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/24/21.
//

import SpriteKit

class ScorePopupNode: PopupNode {
  
  
  var level: String
  var score: [String:Int]
  var scoreLabel: SKLabelNode!
  
  init(buttonHandlerDelegate: PopupButtonHandlerDelegate, title: String, level: String, texture: SKTexture, score: Int, coins: Int, animated: Bool) {
    self.level = level
    self.score = ScoreManager.getCurrentScore(for: level)
    
    super.init(withTitle: title, and: texture, buttonHandlerDelegate: buttonHandlerDelegate)
  }
  
  func addScoreLabel() {
    scoreLabel = SKLabelNode(fontNamed: GameConstants.StringConstants.gameFontName)
    scoreLabel.fontSize = 200.0
    scoreLabel.text = "0"
    scoreLabel.scale(to: size, width: false, multiplier: 0.1)
    scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - size.height*0.6)
    scoreLabel.zPosition = GameConstants.ZPositions.hudZ
    addChild(scoreLabel)
  }
  
  func addStars() {
    for i in 0...2 {
      let empty = SKSpriteNode(imageNamed: GameConstants.StringConstants.emptyStarName)
      let star = SKSpriteNode(imageNamed: GameConstants.StringConstants.fullStarName)
      
      empty.scale(to: size, width: true, multiplier: 0.25)
      empty.position = CGPoint(x: -empty.size.width + CGFloat(i) * empty.size.width, y: frame.maxY - size.height*0.4)
      if i == 1 {
        empty.position.y += empty.size.height/4
      }
      empty.zRotation = -CGFloat(-Double.pi / 4 / 2) + CGFloat(i) * CGFloat(-Double.pi / 4 / 2)
      empty.zPosition = GameConstants.ZPositions.hudZ
      
      star.size = empty.size
      star.position = empty.position
      star.zRotation = empty.zRotation
      star.zPosition = empty.zPosition
      star.name = GameConstants.StringConstants.fullStarName + "_\(i)"
      star.alpha = 0.0
    }
  }
  func addCoins(count: Int) {
    // video 75
  }
  func animateResult(with achievedScore: CGFloat, and maxScore: CGFloat) {
    
  }
  func animateStar(number: Int) {
    
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
