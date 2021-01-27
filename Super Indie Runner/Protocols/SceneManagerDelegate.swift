//
//  SceneManagerDelegate.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/26/21.
//

import Foundation

protocol SceneManagerDelegate {
  func presentLevelScene(for world: Int)
  func presentGameScene(for level: Int, in world: Int)
  func presentMenuScene()
}
