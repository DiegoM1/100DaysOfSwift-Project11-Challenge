//
//  GameScene.swift
//  Project 11
//
//  Created by Diego Sebastián Monteagudo Díaz on 10/2/20.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate{
    
    
    var ballsColors = ["ballRed","ballBlue","ballCyan","ballGreen","ballGrey","ballPurple","ballYellow"]
    var scoreLabel: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var ballsCounter: SKLabelNode!
    var counter = 5 {
        didSet {
            ballsCounter.text = "Balls: \(counter)"
        }
    }
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        
        physicsWorld.contactDelegate = self
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel?.text = "Score: 0"
        scoreLabel?.horizontalAlignmentMode = .right
        scoreLabel?.position = CGPoint(x: 980, y: 700)
        
        
        ballsCounter = SKLabelNode(fontNamed: "Chalkduster")
        ballsCounter.text = "Balls: 5"
        ballsCounter.horizontalAlignmentMode = .right
        ballsCounter.position = CGPoint(x: 800, y: 700)
        addChild(ballsCounter)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        let object = nodes(at: location)
        if counter == 0 {
            let ac = UIAlertController(title: "More balls",message: "If you want to buy more balls please ok",preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Ok", style: .default){
                [weak self] _ in
                self?.counter += 3
            })
            
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
            
        } else {
            if object.contains(editLabel) {
                editingMode.toggle()
            } else {
                if editingMode {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.name = "box"
                    box.physicsBody = SKPhysicsBody(rectangleOf:  box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                } else {
                    let ball = SKSpriteNode(imageNamed: ballsColors.randomElement()!)
                    ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                    ball.physicsBody?.restitution = 0.4
                    location.y = 700
                    ball.position = location
                    ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                    ball.name = "ball"
                    counter -= 1
                    addChild(ball)
                }
            }
            
        }
    }
    func makeBouncer(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius:bouncer.size.width / 2)
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position:CGPoint, isGood:Bool) {
        var slotbase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotbase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotbase.name = "good"
           
        } else {
            slotbase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotbase.name = "bad"
        }
        slotbase.position = position
        slotGlow.position = position
        
        slotbase.physicsBody = SKPhysicsBody(rectangleOf: slotbase.size)
        slotbase.physicsBody?.isDynamic = false
        
        
        addChild(slotGlow)
        addChild(slotbase)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10   )
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            score += 1
            counter += 1
            destroy(ball: ball)
        } else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        } else if object.name == "box" {
            destroy(ball: object)
        }
    }
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
        if ball.name == "box" {
            if (self.childNode(withName: "box") == nil) {
                let ac = UIAlertController(title: "You win",message: "Winner",preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Ok", style: .default){
                    [weak self] _ in
                    self?.counter = 5
                })
                view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between:nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
    }
}
