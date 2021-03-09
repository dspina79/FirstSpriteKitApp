//
//  GameScene.swift
//  OMGMarbles
//
//  Created by Dave Spina on 3/5/21.
//
import CoreMotion
import SpriteKit

class Ball: SKSpriteNode {}

class GameScene: SKScene {
    var balls = ["ballBlue", "ballGreen", "ballCyan", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    var motionManager: CMMotionManager?
    var score = 0 {
        didSet {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            let formattedScore = formatter.string(from: score as NSNumber) ?? "0"
            scoreLabel.text = "SCORE: \(formattedScore)"
        }
    }
    var matchedBalls = Set<Ball>()
    
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Thin")
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        
        addChild(background)
        
        scoreLabel.fontSize = 72
        scoreLabel.fontColor = .yellow
        scoreLabel.text = "SCORE: 0"
        scoreLabel.position = CGPoint(x: 20, y: 20)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        let ball = SKSpriteNode(imageNamed: "ballBlue")
        let ballRadius = ball.frame.width / 2.0
        
        for i in stride(from: ballRadius, through: view.bounds.width - ballRadius, by: ball.frame.width) {
            for j in stride(from: 100, through: view.bounds.height - ballRadius, by: ball.frame.height) {
                let ballType = balls.randomElement()!
                let ball = Ball(imageNamed: ballType)
                ball.position = CGPoint(x: i, y: j)
                ball.name = ballType
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ballRadius)
                ball.physicsBody?.allowsRotation = false
                ball.physicsBody?.friction = 0
                ball.physicsBody?.restitution = 0
                
                addChild(ball)
            }
        }
        // set the boundaries to be inside the frame but leave room for the score.
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame.inset(by: UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)))
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()

    }
    
    // quick way to get matches
//    func getMatches(from node: Ball) {
//        for body in node.physicsBody!.allContactedBodies() {
//            guard let ball = body.node as? Ball else { continue }
//            guard ball.name == node.name else { continue }
//
//            if !matchedBalls.contains(ball) {
//                matchedBalls.insert(ball)
//                getMatches(from: ball)
//            }
//        }
//    }

    func distanceSquared(from: Ball, to: Ball) -> CGFloat {
        return (from.position.x - to.position.x) * (from.position.x - to.position.x) +
            (from.position.y - to.position.y) * (from.position.y - to.position.y)
    }
    
    func getMatches(from startBall: Ball) {
        let matchWidth = startBall.frame.width * startBall.frame.width * 1.1
        for node in children {
            guard let ball = node as? Ball else { continue }
            let distance = distanceSquared(from: startBall, to: ball)
            guard distance < matchWidth && startBall.name == ball.name else { continue }
            
            if !matchedBalls.contains(ball) {
                matchedBalls.insert(ball)
                getMatches(from: ball)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let position = touches.first?.location(in: self) else { return }
        
        guard let tappedBall = nodes(at: position).first(where: {$0 is Ball}) as? Ball else { return }
        
        matchedBalls.removeAll(keepingCapacity: true)
        getMatches(from: tappedBall)
        
        
        if matchedBalls.count >= 3 {
            score += min(matchedBalls.count * matchedBalls.count, 512)
            for ball in matchedBalls {
                if let particles = SKEmitterNode(fileNamed: "Explosion") {
                    particles.position = ball.position
                    addChild(particles)
                    
                    let removeAfterDead = SKAction.sequence([SKAction.wait(forDuration: 3), SKAction.removeFromParent()])
                    particles.run(removeAfterDead)
                }
                
                ball.removeFromParent()
            }
        }
        
        if matchedBalls.count >= 6 {
            // show OMG
            let omg = SKSpriteNode(imageNamed: "omg")
            omg.position = CGPoint(x: frame.midX, y: frame.midY)
            omg.zPosition = 100
            omg.yScale = 0.001
            omg.xScale = 0.001
            
            addChild(omg)
            
            let appear = SKAction.group([SKAction.scale(to: 1, duration: 0.25), SKAction.fadeIn(withDuration: 0.25)])
            let dissappear = SKAction.group([SKAction.scale(to: 2, duration: 0.25), SKAction.fadeOut(withDuration: 0.25)])
            let sequence = SKAction.sequence([appear, SKAction.wait(forDuration: 0.25), dissappear])
            omg.run(sequence)
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        if let accelData = self.motionManager?.accelerometerData {
            physicsWorld.gravity = CGVector(dx: accelData.acceleration.y * -50, dy: accelData.acceleration.x * 50)
        }
    }
}
