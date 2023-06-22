////
//  GameAnchor.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-19.
//


import ARKit

enum NodeType: String {
   case ghost = "ghost"
   case battery = "battery"
   
   func icon() -> String {
      switch self {
      case .ghost:
         return "👻"
      case .battery:
         return "🔋"
      }
   }
}

class GameAnchor: ARAnchor {
   var type: NodeType?
   
   convenience init(transform: simd_float4x4 , type: NodeType) {
      self.init(transform: transform)
      self.type = type
   }
}

