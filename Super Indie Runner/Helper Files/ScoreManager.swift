//
//  ScoreManager.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/24/21.
//

import Foundation

struct ScoreManager {
  static func getCurrentScore(for levelKey: String) -> [String:Int] {
    if let existingData = UserDefaults.standard.dictionary(forKey: levelKey) as? [String:Int] {
      return existingData
    } else {
      return [
        GameConstants.StringConstants.scoreScoreKey: 0,
        GameConstants.StringConstants.scoreStarsKey: 0,
        GameConstants.StringConstants.scoreCoinsKey: 0,
      ]
    }
    
  }
  static func updateScore(for levelKey: String, and score: [String:Int]) {
    UserDefaults.standard.setValue(score, forKey: levelKey)
    UserDefaults.standard.synchronize()
  }
  static func compare(scores: [[String:Int]], in levelKey: String) {
    var newHighScore = false
    let currentScore = getCurrentScore(for: levelKey)
    var maxScore = currentScore[GameConstants.StringConstants.scoreScoreKey]!
    var maxStars = currentScore[GameConstants.StringConstants.scoreStarsKey]!
    var maxCoins = currentScore[GameConstants.StringConstants.scoreCoinsKey]!
    
    for score in scores {
      if score[GameConstants.StringConstants.scoreScoreKey]! > maxScore {
        maxScore = score[GameConstants.StringConstants.scoreScoreKey]!
        newHighScore = true
      }
      if score[GameConstants.StringConstants.scoreStarsKey]! > maxStars {
        maxStars = score[GameConstants.StringConstants.scoreStarsKey]!
        newHighScore = true
      }
      if score[GameConstants.StringConstants.scoreCoinsKey]! > maxCoins {
        maxCoins = score[GameConstants.StringConstants.scoreCoinsKey]!
        newHighScore = true
      }
    }
    
    // save our new high scores
    if newHighScore {
      let newScore = [
        GameConstants.StringConstants.scoreScoreKey: maxScore,
        GameConstants.StringConstants.scoreStarsKey: maxStars,
        GameConstants.StringConstants.scoreCoinsKey: maxCoins,
      ]
      updateScore(for: levelKey, and: newScore)
    }
  }
}
