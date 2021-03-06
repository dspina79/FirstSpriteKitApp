//
//  GameScene.swift
//  OMGMarbles
//
//  Created by Dave Spina on 3/5/21.
//

import SpriteKit

class Ball: SKSpriteNode {}

class GameScene: SKScene {
    var balls = ["ballBlue", "ballGreen", "ballCyan", "ballGray", "ballPurple", "ballRed", "ballYellow"]
    
    override func didMove(to view: SKView) {

    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
