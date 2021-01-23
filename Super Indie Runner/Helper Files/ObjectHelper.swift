//
//  ObjectHelper.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/23/21.
//

import SpriteKit

class ObjectHelper {
  
  static func handleChild(sprite: SKSpriteNode, with name:String) {
    switch name {
    case GameConstants.StringConstants.finishLineName, GameConstants.StringConstants.enemyName:
      PhysicsHelper.addPhysicsBody(to: sprite, with: name)
    default:
      break
    }
  }
  
}
