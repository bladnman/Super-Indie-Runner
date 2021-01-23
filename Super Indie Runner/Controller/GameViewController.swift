//
//  GameViewController.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/22/21.
//

import SpriteKit
import UIKit

class GameViewController: UIViewController {
  override func viewDidLoad() {
    super.viewDidLoad()

    if let view = self.view as! SKView? {
      let scene = GameScene(size: view.bounds.size)
      scene.scaleMode = .aspectFill
      view.presentScene(scene)
      view.ignoresSiblingOrder = true

      view.showsFPS = true
      view.showsPhysics = true
      view.showsNodeCount = true
    }
  }
}
