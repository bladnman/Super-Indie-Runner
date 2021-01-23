//
//  RepeatingLayer.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/23/21.
//

import SpriteKit

class RepeatingLayer: Layer {
  override func updateNodes(_ delta: TimeInterval, childNode: SKNode) {
    // see if node is out of layer frame
    // if so, move it to the other side
    if let node = childNode as? SKSpriteNode {
      if node.position.x <= -node.size.width {
        if node.name == "0" && self.childNode(withName: "1") != nil || node.name == "1" && self.childNode(withName: "0") != nil {
          node.position = CGPoint(x: node.position.x + node.size.width * 2, y: node.position.y)
        }
      }
    }
  }
}
