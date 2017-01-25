//
//  GameScene.swift
//  sketch
//
//  Created by George Lim on 2017-01-25.
//  Copyright © 2017 George Lim. All rights reserved.
//

import SpriteKit

struct SimulationObjects {
  static let sketch = "Sketch"
}

class GameScene: SKScene {

  private var sketchColor = UIColor.red
  private var sketchLineWidth: CGFloat = 5
  private var currentSketch: Sketch?

  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touchLocation = touches.first?.location(in: self) else {
      return
    }

    if let view = view {
      currentSketch = Sketch(view: view, coordinate: touchLocation, color: sketchColor, lineWidth: sketchLineWidth)
    }
  }

  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let touchLocation = touches.first?.location(in: self) else {
      return
    }

    currentSketch?.addCoordinate(touchLocation)

    if let sketchNode = currentSketch?.getSketch() {
      addChild(sketchNode)
    }
  }

  override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    enumerateChildNodes(withName: SimulationObjects.sketch, using: { node, _ in
      let fadeAction = SKAction.fadeOut(withDuration: 0.5)
      let killAction = SKAction.removeFromParent()
      let actionSequence = SKAction.sequence([fadeAction, killAction])
      node.run(actionSequence)
    })
  }

  override func update(_ currentTime: TimeInterval) {
  }
}
