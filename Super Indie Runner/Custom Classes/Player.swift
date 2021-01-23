//
//  Player.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/23/21.
//

import SpriteKit

enum PlayerState {
  case idle, run
}

class Player: SKSpriteNode {
  
  var runFrames = [SKTexture]()
  var idleFrames = [SKTexture]()
  var jumpFrames = [SKTexture]()
  var dieFrames = [SKTexture]()
  
  var state = PlayerState.idle {
    willSet {
      animate(for: newValue)
    }
  }
  
  var airborne = false
  
  func loadTextures() {
    runFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: GameConstants.StringConstants.playerRunAtlas), withName: GameConstants.StringConstants.runPrefixKey)
    idleFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: GameConstants.StringConstants.playerIdleAtlas), withName: GameConstants.StringConstants.idlePrefixKey)
    jumpFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: GameConstants.StringConstants.playerJumpAtlas), withName: GameConstants.StringConstants.jumpPrefixKey)
    dieFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: GameConstants.StringConstants.playerDieAtlas), withName: GameConstants.StringConstants.diePrefixKey)
  }
  func animate(for state:PlayerState) {
    removeAllActions()
    switch state {
    case .idle:
      self.run(SKAction.repeatForever(SKAction.animate(with: idleFrames, timePerFrame: 0.05, resize: true, restore: true)))
    case .run:
      self.run(SKAction.repeatForever(SKAction.animate(with: runFrames, timePerFrame: 0.05, resize: true, restore: true)))
    }
  }
}
