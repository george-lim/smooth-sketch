//
//  Sketch.swift
//  sketch
//
//  Created by George Lim on 2017-01-25.
//  Copyright © 2017 George Lim. All rights reserved.
//

import SpriteKit

struct Sketch {

  private let view: SKView
  private let strokeColor: UIColor
  private let lineWidth: CGFloat

  private var coordinates: [CGPoint] = []
  private var sketchNode: SKSpriteNode?

  var lastPathCoordinates: [CGPoint]? {
    guard coordinates.count > 50 else {
      return nil
    }

    var i = coordinates.count - 9
    let offset = (coordinates.count - 1) % 3

    switch offset {
    case 0:
      i -= 3
    default:
      i -= offset
    }

    let lastPathEndPoint = CGPoint(x: (coordinates[i + 1].x + coordinates[i + 3].x) / 2, y: (coordinates[i + 1].y + coordinates[i + 3].y) / 2)
    var pathCoordinates: [CGPoint] = [lastPathEndPoint]

    for j in i ... coordinates.count - 1 {
      pathCoordinates.append(coordinates[j])
    }

    return pathCoordinates
  }

  init(view: SKView, coordinate: CGPoint, color strokeColor: UIColor, lineWidth: CGFloat) {
    self.view = view
    self.strokeColor = strokeColor
    self.lineWidth = lineWidth

    addCoordinate(coordinate)
  }

  init(view: SKView, coordinates: [CGPoint], color strokeColor: UIColor, lineWidth: CGFloat) {
    self.view = view
    self.strokeColor = strokeColor
    self.lineWidth = lineWidth

    for coordinate in coordinates {
      addCoordinate(coordinate)
    }
  }

  mutating func addCoordinate(_ point: CGPoint) {
    coordinates.append(point)
  }

  private func pathFromCoordinates() -> UIBezierPath? {
    guard coordinates.count > 5 else {
      return nil
    }

    let path = UIBezierPath()
    path.move(to: coordinates[0])

    for i in 1 ..< coordinates.count - 3 where (i - 1) % 3 == 0 {
      let endPoint = CGPoint(x: (coordinates[i + 1].x + coordinates[i + 3].x) / 2, y: (coordinates[i + 1].y + coordinates[i + 3].y) / 2)
      path.addCurve(to: endPoint, controlPoint1: coordinates[i], controlPoint2: coordinates[i + 1])
    }

    return path
  }

  private func frameFromCoordinates() -> CGRect? {
    guard coordinates.count > 0 else {
      return nil
    }

    var originX = CGFloat.greatestFiniteMagnitude
    var originY = CGFloat.greatestFiniteMagnitude
    var maxX = CGFloat.leastNormalMagnitude
    var maxY = CGFloat.leastNormalMagnitude

    for point in coordinates {
      if point.x < originX {
        originX = point.x
      }

      if point.x > maxX {
        maxX = point.x
      }

      if point.y < originY {
        originY = point.y
      }

      if point.y > maxY {
        maxY = point.y
      }
    }

    return CGRect(x: originX - lineWidth, y: originY - lineWidth, width: maxX - originX + lineWidth * 2, height: maxY - originY + lineWidth * 2)
  }

  mutating func getSketch() -> SKSpriteNode? {
    guard let path = pathFromCoordinates(), let frame = frameFromCoordinates() else {
      return nil
    }

    sketchNode?.removeFromParent()

    let sketchShape = SKShapeNode(path: path.cgPath)
    sketchShape.strokeColor = strokeColor
    sketchShape.lineWidth = lineWidth

    let drawingTexture = view.texture(from: sketchShape, crop: frame)

    sketchNode = SKSpriteNode(texture: drawingTexture)
    sketchNode!.name = SimulationObjects.sketch
    sketchNode!.anchorPoint = CGPoint.zero
    sketchNode!.position = frame.origin
    sketchNode!.zPosition = 100
    
    return sketchNode
  }
}
