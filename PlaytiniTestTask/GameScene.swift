//
//  GameScene.swift
//  PlaytiniTestTask
//
//  Created by Пащенко Иван on 30.10.2024.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var earth: SKSpriteNode!
    var increaseButton: SKLabelNode!
    var decreaseButton: SKLabelNode!
    
    override func didMove(to view: SKView) {
        setupEarth()
    }
}

extension GameScene {
    func setupEarth() {
        self.earth = SKSpriteNode(imageNamed: "Earth")
        
        self.earth.size = CGSize(width: 200, height: 200)
        
        self.earth.physicsBody = SKPhysicsBody(texture: self.earth.texture!, size: self.earth.size)
        self.earth.physicsBody?.isDynamic = false
        
        addChild(earth)
        
        // Добавляем действие вращения вправо
        let rotateAction = SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)
        let repeatAction = SKAction.repeatForever(rotateAction)
        self.earth.run(repeatAction)
    }
    
    func plusButtonPress(sender: AnyObject) {
        let scaleUpAction = SKAction.scale(by: 1.1, duration: 0.1)
        earth.run(scaleUpAction)
    }
    
    func minusButtonPress(sender: AnyObject) {
        let scaleDownAction = SKAction.scale(by: 0.9, duration: 0.1)
        earth.run(scaleDownAction)
    }
}
