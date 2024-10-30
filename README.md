
# Документація проєкту PlaytiniTestTask

Це приклад гри, створеної за допомогою Swift і SpriteKit. Гравець взаємодіє з об’єктом (планетою), що обертається, та повинен уникати перешкод, які рухаються з правого боку екрана. Гра також використовує тактильний зворотний зв’язок (хаптику) для більшої взаємодії.

## Основні частини коду та пояснення

#### 1. Основний клас GameScene

У класі GameScene налаштовуються основні елементи гри, такі як фон, планета та хаптика. Клас також містить основний ігровий цикл та обробляє зіткнення з перешкодами.

```swift
class GameScene: SKScene {
    // Оголошення основних об'єктів, таких як фон, планета та хаптичний двигун.
}
```

#### 2. extension GameScene: Налаштування фону

Цей розширення відповідає за ініціалізацію та налаштування фону сцени.

```swift
extension GameScene {
    func setupBackground() {
        // Налаштування розміру фону вдвічі більше розміру екрану для ефекту.
        background.size = CGSize(width: UIScreen.main.bounds.width * 2, height: UIScreen.main.bounds.height * 2)
        background.zPosition = -1 // Задання шару для фону, щоб інші елементи були попереду.
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        addChild(background) // Додавання фону як дочірнього елемента сцени.
    }
}
```
Це забезпечує, щоб фон був завжди позаду всіх інших об’єктів і займав весь екран.

#### 3. extension GameScene: Налаштування планети (Землі)
Це розширення відповідає за створення планети в центрі екрану, її розмір та поведінку (обертання, масштабування).

```swift
extension GameScene {
    func setupEarth() {
        // Ініціалізація об’єкта Землі та його розмірів.
        earth = SKSpriteNode(imageNamed: "Earth")
        earth.size = CGSize(width: 200, height: 200)
        earth.position = CGPoint(x: frame.midX, y: frame.midY)
        
        // Додавання фізичного тіла, яке буде використовуватися для перевірки зіткнень.
        earth.physicsBody = SKPhysicsBody(texture: earth.texture!, size: earth.size)
        earth.physicsBody?.isDynamic = false // Фіксація планети на місці
        addChild(earth)
        
        // Додавання дії обертання для планети.
        let rotateAction = SKAction.rotate(byAngle: -CGFloat.pi, duration: 1)
        let repeatAction = SKAction.repeatForever(rotateAction)
        earth.run(repeatAction)
    }
    
    func plusButtonPress(sender: AnyObject) {
        // Збільшення розміру Землі.
        if earth.xScale < 2.5 {
            let scaleUpAction = SKAction.scale(by: 1.1, duration: 0.1)
            earth.run(scaleUpAction)
        }
    }
    
    func minusButtonPress(sender: AnyObject) {
        // Зменшення розміру Землі.
        if earth.xScale > 0.5 {
            let scaleDownAction = SKAction.scale(by: 0.9, duration: 0.1)
            earth.run(scaleDownAction)
        }
    }
}
```
Цей блок дозволяє гравцеві контролювати розмір Землі та забезпечує плавне обертання, яке додає візуальної привабливості.

#### 4. extension GameScene: Налаштування перешкод

Це розширення відповідає за генерування перешкод, які рухаються з правого боку екрана, а також їх випадкову появу на сцені.

```swift
extension GameScene {
    func startObstacleLoop() {
        // Цикл створення перешкод з різним часом затримки.
        let spawnObstacleAction = SKAction.run { [weak self] in
            self?.createObstacle()
        }
        let delay = SKAction.wait(forDuration: Double.random(in: 1.5...3.0))
        let spawnSequence = SKAction.sequence([spawnObstacleAction, delay])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        
        run(spawnForever) // Запуск безкінечного циклу перешкод.
    }
    
    func createObstacle() {
        // Визначення випадкової ширини та кольору для перешкоди.
        let randomWidth = CGFloat.random(in: 100...frame.width * 0.7)
        let obstacle = SKSpriteNode(color: randomColor(), size: CGSize(width: randomWidth, height: 20))
        
        // Встановлення безпечної зони, щоб перешкоди не з'являлися занадто близько до планети.
        let safeArea: CGFloat = 150
        var randomY: CGFloat
        repeat {
            randomY = CGFloat.random(in: frame.minY + safeArea...frame.maxY - safeArea)
        } while abs(randomY - earth.position.y) < safeArea
        
        obstacle.position = CGPoint(x: frame.maxX + obstacle.size.width / 2, y: randomY)
        obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
        obstacle.physicsBody?.isDynamic = false // Фіксація об’єкта
        obstacle.name = "obstacle"
        
        addChild(obstacle)
        
        // Дія, яка переміщує перешкоду з правого боку екрану вліво.
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
```
Цей блок створює динамічні перешкоди з випадковими розмірами, кольорами та розташуванням, що робить гру непередбачуваною та цікавою.

#### 5. extension GameScene: Налаштування хаптики

Це розширення відповідає за ініціалізацію хаптичного двигуна та відтворення хаптичного сигналу при зіткненнях з перешкодами.

```swift
extension GameScene {
    func setupHaptics() {
        // Перевірка, чи підтримує пристрій хаптику.
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            hapticEngine = try CHHapticEngine()
            try hapticEngine?.start()
        } catch {
            print("Haptic engine creation error: \(error)")
        }
    }
    
    func playHaptic() {
        // Відтворення хаптичного сигналу при зіткненні.
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
```
Хаптичний зворотний зв’язок покращує взаємодію, даючи гравцеві фізичний відгук про зіткнення з перешкодами.

#### 6. extension GameScene: Обробка зіткнень

Це розширення відповідає за перевірку зіткнень Землі з перешкодами. Якщо кількість зіткнень досягає 5, гра зупиняється та пропонує гравцю почати знову.

```swift
extension GameScene {
    func checkCollisions() {
         enumerateChildNodes(withName: "obstacle") { node, _ in
            guard self.collisionCount < 5 else { return }
            
            // Перевірка, чи перетинаються рамки Землі та перешкоди.
            if self.earth.frame.intersects(node.frame) {
                self.collisionCount += 1
                self.playHaptic() // Виклик хаптичного зворотного зв'язку
                node.removeFromParent() // Видалення перешкоди після зіткнення
                
                // Якщо кількість зіткнень досягла 5, гра зупиняється.
                if self.collisionCount >= 5 {
                    self.isPaused = true
                    self.showRestartAlert() // Виклик діалогового вікна для рестарту
                }
            }
        }
    }
    
    func showRestartAlert() {
        if let view = self.view {
            // Створення та показ діалогового вікна з кнопкою для рестарту гри.
            let alert = UIAlertController(title: "Гру завершено", message: "Перезапустіть гру", preferredStyle: .alert)
            let restartAction = UIAlertAction(title: "Перезапустити", style: .default) { _ in
                self.collisionCount = 0
                self.removeAllChildren() // Очищення всіх елементів зі сцени
                self.didMove(to: view) // Повторний виклик для перезапуску сцени
            }
            alert.addAction(restartAction)
            view.window?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
```

Це розширення відповідає за перевірку зіткнень Землі з перешкодами. Якщо кількість зіткнень досягає 5, гра зупиняється та пропонує гравцю почати знову.
