//
//  GameConstants.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/23/21.
//

import CoreGraphics
import Foundation

struct GameConstants {
  enum ZPositions {
    static let farBGZ: CGFloat = 0
    static let closeBGZ: CGFloat = 1
    static let worldZ: CGFloat = 2
    static let objectZ: CGFloat = 3
    static let playerZ: CGFloat = 4
    static let hudZ: CGFloat = 5
  }

  enum StringConstants {
    static let groundTilesName = "Ground Tiles"
    static let worldBackgroundNames = ["DessertBackground", "GrassBackground"]
    static let groundNodeName = "GroundNode"
    static let finishLineName = "FinishLine"
    static let enemyName = "Enemy"

    static let coinName = "Coin"
    static let coinImageName = "gold0"
    static let coinRotateAtlas = "Coin Rotate Atlas"
    static let coinPrefixKey = "gold"
    static let coinDustEmitterKey = "CoinDustEmitter"
    static let brakeSparkEmitter = "BrakeSparkEmitter"
    
    static let superCoinImageName = "SuperCoin"
    static let superCoinNames = ["Super1", "Super2", "Super3"]
    static let gameFontName = "Unanimous Inverted -BRK-"

    static let playerName = "Player"
    static let playerImageName = "Idle_0"
    static let playerIdleAtlas = "Player Idle Atlas"
    static let playerRunAtlas = "Player Run Atlas"
    static let playerJumpAtlas = "Player Jump Atlas"
    static let playerDieAtlas = "Player Die Atlas"
    static let idlePrefixKey = "Idle_"
    static let runPrefixKey = "Run_"
    static let jumpPrefixKey = "Jump_"
    static let diePrefixKey = "Die_"
    static let jumpUpActionKey = "JumpUp"
    static let breakDescendActionKey = "BrakeDescend"
  }

  enum PhysicsCategories {
    static let noCategory: UInt32 = 0
    static let allCategory = UInt32.max
    static let playerCategory: UInt32 = 0x1
    static let groundCategory: UInt32 = 0x1 << 1
    static let finishCategory: UInt32 = 0x1 << 2
    static let collectibleCategory: UInt32 = 0x1 << 3
    static let enemyCategory: UInt32 = 0x1 << 4
    static let frameCategory: UInt32 = 0x1 << 5
    static let ceilingCategory: UInt32 = 0x1 << 6
  }
}
