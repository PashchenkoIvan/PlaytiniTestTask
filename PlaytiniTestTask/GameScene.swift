//
//  GameScene.swift
//  PlaytiniTestTask
//
//  Created by Пащенко Иван on 30.10.2024.
//

import SpriteKit
import CoreHaptics

class GameScene: SKScene {
    let background = SKSpriteNode(imageNamed: "Background")
    var earth: SKSpriteNode!
    var hapticEngine: CHHapticEngine?
    var collisionCount = 0
    
    override func didMove(to view: SKView) {
        self.isPaused = false
        
        setupBackground()
        setupEarth()
        setupHaptics()
        startObstacleLoop()
    }
    
    override func update(_ currentTime: TimeInterval) {
        checkCollisions()
    }
}

// MARK: - Background Setup
extension GameScene {
    func setupBackground() {
        background.size = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
        background.zPosition = -1
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background)
    }
}

// MARK: - Earth Setup
extension GameScene {
    func setupEarth() {
        earth = SKSpriteNode(imageNamed: "Earth")
        earth.size = CGSize(width: 200, height: 200)
        earth.position = CGPoint(x: frame.midX, y: frame.midY)
        
        earth.physicsBody = SKPhysicsBody(texture: earth.texture!, size: earth.size)
        earth.physicsBody?.isDynamic = false
        addChild(earth)
        
        let rotateAction = SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)
        let repeatAction = SKAction.repeatForever(rotateAction)
        earth.run(repeatAction)
    }
    
    func plusButtonPress(sender: AnyObject) {
        if earth.xScale < 2.5 {
            let scaleUpAction = SKAction.scale(by: 1.1, duration: 0.1)
            earth.run(scaleUpAction)
        }
    }
    
    func minusButtonPress(sender: AnyObject) {
        if earth.xScale > 0.5 {
            let scaleDownAction = SKAction.scale(by: 0.9, duration: 0.1)
            earth.run(scaleDownAction)
        }
    }
}

// MARK: - Obstacle Setup
extension GameScene {
    func startObstacleLoop() {
        let spawnObstacleAction = SKAction.run { [weak self] in
            self?.createObstacle()
        }
        let delay = SKAction.wait(forDuration: Double.random(in: 1.5...3.0))
        let spawnSequence = SKAction.sequence([spawnObstacleAction, delay])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        
        run(spawnForever)
    }
    
    func createObstacle() {
        let randomWidth = CGFloat.random(in: 100...frame.width * 0.7)
        let obstacle = SKSpriteNode(color: randomColor(), size: CGSize(width: randomWidth, height: 20))
        
        let safeArea: CGFloat = 150
        var randomY: CGFloat
        repeat {
            randomY = CGFloat.random(in: frame.minY + safeArea...frame.maxY - safeArea)
        } while abs(randomY - earth.position.y) < safeArea
        
        obstacle.position = CGPoint(x: frame.maxX + obstacle.size.width / 2, y: randomY)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false
        obstacle.name = "obstacle"
        
        addChild(obstacle)
        
        let moveLeft = SKAction.moveTo(x: frame.minX - obstacle.size.width, duration: 5)
        let scaleWidth = SKAction.scaleX(to: CGFloat.random(in: 0.8...1.2), duration: 1.5)
        let repeatScale = SKAction.repeatForever(SKAction.sequence([scaleWidth, scaleWidth.reversed()]))
        
        obstacle.run(SKAction.group([moveLeft, repeatScale])) {
            obstacle.removeFromParent()
        }
    }
    
    func randomColor() -> UIColor {
        return UIColor(
            red: CGFloat.random(in: 0.5...1),
            green: CGFloat.random(in: 0.5...1),
            blue: CGFloat.random(in: 0.5...1),
            alpha: 1.0
        )
    }
}

// MARK: - Haptics Setup
extension GameScene {
    func setupHaptics() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine creation error: \(error)")
        }
    }
    
    func playHaptic() {
        guard let hapticEngine = hapticEngine else { return }
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 1)
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1)
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [sharpness, intensity], relativeTime: 0)
        
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic: \(error)")
        }
    }
}

// MARK: - Collision Detection
extension GameScene {
    func checkCollisions() {
        enumerateChildNodes(withName: "obstacle") { node, _ in
            guard self.collisionCount < 5 else { return }
            
            if self.earth.frame.intersects(node.frame) {
                self.collisionCount += 1
                self.playHaptic()
                node.removeFromParent()
                
                if self.collisionCount >= 5 {
                    self.isPaused = true
                    self.showRestartAlert()
                }
            }
        }
    }
    
    func showRestartAlert() {
        if let view = self.view {
            let alert = UIAlertController(title: "Game over", message: "Restart the game", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Restart", style: .default) { _ in
                self.collisionCount = 0
                self.removeAllChildren()
                self.didMove(to: view)
            }
            alert.addAction(restartAction)
            view.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
