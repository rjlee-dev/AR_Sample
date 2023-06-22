////
//  Sounds.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-20.
//

import SpriteKit

enum Sounds {
  static let fire =      SKAction.playSoundFileNamed("Sounds/sprayBug",
                                                     waitForCompletion: false)
  static let hit =       SKAction.playSoundFileNamed("Sounds/hitBug",
                                                     waitForCompletion: false)
  static let pickUp =  SKAction.playSoundFileNamed("Sounds/catchBugspray",
                                                     waitForCompletion: false)
  static let win =       SKAction.playSoundFileNamed("Sounds/win.wav",
                                                     waitForCompletion: false)
  static let lose =      SKAction.playSoundFileNamed("Sounds/lose.wav",
                                                     waitForCompletion: false)
}
