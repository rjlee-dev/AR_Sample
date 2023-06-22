//
//  ARSpriteKitView.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-20.
//


import SwiftUI
import ARKit
import SpriteKit



struct ARSpriteKitView: UIViewRepresentable {

   let skScene: SKScene
   func makeUIView(context: Context) -> some UIView {
      let arView = ARSKView()
      let configuration = ARWorldTrackingConfiguration()
      arView.delegate = context.coordinator
      //      UserManager()
      let scene = skScene
      scene.scaleMode = .resizeFill
      scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
      arView.presentScene(scene)
      arView.showsFPS = true
      arView.showsNodeCount = true
      

      arView.session.run(configuration)
      return arView
   }
   
   func updateUIView(_ uiView: UIViewType, context: Context) {
      print(#function)
   }
   
   func makeCoordinator() -> Coordinator {
      Coordinator()
   }
       
   class Coordinator: NSObject, ARSKViewDelegate {

      func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
         var node: SKNode?
         if let anchor = anchor as? GameAnchor, let type = anchor.type {
              node = SKLabelNode(text: type.icon())
              node?.name = type.rawValue
         }
         return node
      }
      
      func session(_ session: ARSession, didFailWithError error: Error) {
         print(#function)
      }
      
      func sessionWasInterrupted(_ session: ARSession) {
         print(#function)
      }
      
      func sessionInterruptionEnded(_ session: ARSession) {
         print(#function)
      }
   }
   
}
