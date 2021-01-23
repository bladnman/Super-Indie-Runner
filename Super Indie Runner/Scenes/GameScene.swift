//
//  GameScene.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/22/21.
//

import SpriteKit

class GameScene: SKScene {
  
  var mapNode: SKNode!
  var tileMap: SKNode!
  
  override func didMove(to view: SKView) {
    load(level: "Level_0-1")
  }

  func load(level: String) {
    if let levelNode = SKNode.unarchiveFromFile(file: level) {
      mapNode = levelNode
      addChild(mapNode)
      loadTileMap()
    }
  }
  
  func loadTileMap() {
    if let groundTiles = mapNode.childNode(withName: "Ground Tiles") as? SKTileMapNode {
      tileMap = groundTiles
      tileMap.scale(to: frame.size, width: false, multiplier: 1.0)
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    // noop
  }
}
