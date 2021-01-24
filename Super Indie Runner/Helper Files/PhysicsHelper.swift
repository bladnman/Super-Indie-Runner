//
//  PhysicsHelper.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/23/21.
//

import SpriteKit

class PhysicsHelper {
  static func addPhysicsBody(to sprite: SKSpriteNode, with name: String) {
    switch name {
    // PLAYER
    case GameConstants.StringConstants.playerName:
      sprite.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: sprite.size.width / 2, height: sprite.size.height))
      sprite.physicsBody!.restitution = 0.0
      sprite.physicsBody!.allowsRotation = false
      sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.playerCategory
      sprite.physicsBody!.collisionBitMask = GameConstants.PhysicsCategories.groundCategory | GameConstants.PhysicsCategories.finishCategory
      sprite.physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.allCategory

    // FINISH LINE
    case GameConstants.StringConstants.finishLineName:
      sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
      sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.finishCategory
      
    // ENEMIES
    case GameConstants.StringConstants.enemyName:
      sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
      sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.enemyCategory
      
    // COINS
    // SUPER COINS
    case GameConstants.StringConstants.coinName,
         _ where GameConstants.StringConstants.superCoinNames.contains(name):
      sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width/2)
      sprite.physicsBody!.categoryBitMask = GameConstants.PhysicsCategories.collectibleCategory
      
    default:
      sprite.physicsBody = SKPhysicsBody(rectangleOf: sprite.size)
    }
    
    // ALL NOT PLAYER
    if name != GameConstants.StringConstants.playerName {
      sprite.physicsBody!.contactTestBitMask = GameConstants.PhysicsCategories.playerCategory
      sprite.physicsBody!.isDynamic = false // don't push me bro
    }
  }

  static func addPhysicsBody(to tileMap: SKTileMapNode, with tileInfo: String) {
    let tileSize = tileMap.tileSize
    
    for row in 0..<tileMap.numberOfRows {
      var tiles = [Int]()
      
      // go through all tiles in this row
      // to see if there is any userData (e.g. isUsed)
      for col in 0..<tileMap.numberOfColumns {
        let tileDefinition = tileMap.tileDefinition(atColumn: col, row: row)
        let isUsedTile = tileDefinition?.userData?[tileInfo] as? Bool
        if isUsedTile ?? false {
          tiles.append(1)
        } else {
          tiles.append(0)
        }
      }
      
      // if there were any used tiles (e.g. 1 anywhere)
      if tiles.contains(1) {
        var platform = [Int]()

        // finding "runs" of tiles (e.g. platforms)
        for (index, tile) in tiles.enumerated() {
          // for any active tile (e.g. 1) add it
          // to this platform
          if tile == 1, index < (tileMap.numberOfColumns - 1) {
            platform.append(index)
          }
          
          // last platform had items in it
          else if !platform.isEmpty {
            let x = CGFloat(platform[0]) * tileSize.width
            let y = CGFloat(row) * tileSize.height
            
            let tileNode = GroundNode(with: CGSize(width: tileSize.width * CGFloat(platform.count), height: tileSize.height))
            tileNode.position = CGPoint(x: x, y: y)
            tileNode.anchorPoint = CGPoint.zero
            
            tileMap.addChild(tileNode)
            
            platform.removeAll()
          }
        }
      }
    }
  }
}
