//
//  PopupNode.swift
//  Super Indie Runner
//
//  Created by Maher, Matt on 1/24/21.
//

import SpriteKit

class PopupNode: SKSpriteNode {
  
  var buttonHandlerDelegate: PopupButtonHandlerDelegate
  
  init(withTitle title: String, and texture: SKTexture, buttonHandlerDelegate: PopupButtonHandlerDelegate) {
    self.buttonHandlerDelegate = buttonHandlerDelegate
    
    super.init(texture: texture, color: UIColor.clear, size: texture.size())
    
    let bannerLabel = BannerLabel(withTitle: title)
    bannerLabel.scale(to: size, width: true, multiplier: 1.1)
    bannerLabel.zPosition = GameConstants.ZPositions.hudZ
    bannerLabel.position = CGPoint(x: frame.midX, y: frame.maxY)
    addChild(bannerLabel)
  }
  
  func add(buttons: [Int]) {
    let scalar = 1.0/CGFloat(buttons.count-1)
    for (index, button) in buttons.enumerated() {
      let imageName = GameConstants.StringConstants.popupButtonNames[button]
      let buttonToAdd = SpriteKitButton(defaultButtonImage: imageName, action: buttonHandlerDelegate.popupButtonHandler, index: button)
      let x = -frame.maxX/2 + CGFloat(index) * scalar * (frame.size.width*0.5)
      buttonToAdd.position = CGPoint(x: x, y: frame.minY)
      buttonToAdd.zPosition = GameConstants.ZPositions.hudZ
      buttonToAdd.scale(to: frame.size, width: true, multiplier: 0.25)
      addChild(buttonToAdd)
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}
