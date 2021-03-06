//
//  GameScene.swift
//  OMGMarbles
//
//  Created by Dave Spina on 3/5/21.
//

import SpriteKit

class Ball: SKSpriteNode {}

class GameScene: SKScene {
    var balls = ["ballBlue", "ballGreen", "ballCyan", "ballGrey", "ballPurple", "ballRed", "ballYellow"]
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "checkerboard")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.alpha = 0.2
        background.zPosition = -1
        
        addChild(background)
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

    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
