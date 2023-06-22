//
//  SpriteKitView.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-19.
//

import SwiftUI
import SpriteKit
import ARKit

struct SpriteKitView: View {
    var arSession = ARSession()
       let arConfiguration: ARConfiguration = {
           let configuration = ARWorldTrackingConfiguration()
           // Configure ARConfiguration settings if needed
           return configuration
       }()
   
   var body: some View {
           SpriteKitContainerView(arSession: arSession, arConfiguration: arConfiguration)
               .edgesIgnoringSafeArea(.all)
               .onAppear {
                           startARSession()
                       }
                       .onDisappear {
                           stopARSession()
                       }
       }
   
   
   
   func startARSession() {
      print(#function)
          let configuration = arConfiguration
          arSession.run(configuration)
      }
      
      func stopARSession() {
         print(#function)
          arSession.pause()
      }
}


struct SpriteKitContainerView: UIViewRepresentable {
   
   
   
   let arSession: ARSession
   let arConfiguration: ARConfiguration
   
   
   func updateUIView(_ uiView: ARSKView, context: Context) {
      print(#function)
   }
   
      typealias UIViewType = ARSKView
//    let scene: SKScene
    
    func makeUIView(context: Context) -> ARSKView {
       let arskView = ARSKView(frame:  .zero)
       arskView.session = arSession
       arskView.delegate = context.coordinator
       arskView.backgroundColor = .green
       
       
//       let box = SKShapeNode(circleOfRadius: 10)
//       box.fillColor = .red
//       arskView.addSubview(<#T##view: UIView##UIView#>)
       return arskView
    }
   
    
   
   func makeCoordinator() -> Coordinator {
           Coordinator()
       }
       
    class Coordinator: NSObject, ARSKViewDelegate {
        // Implement the ARSKViewDelegate methods
        // For example:
        func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
            let spriteNode = SKSpriteNode(color: .red, size: CGSize(width: 100, height: 100))
            return spriteNode
        }
       
       
       func session(_ session: ARSession, didFailWithError error: Error) {
         print("Ahh crap  lack camera access")
       }
       
       func sessionWasInterrupted(_ session: ARSession) {
         print(#function)
       }
       
       func sessionInterruptionEnded(_ session: ARSession) {
         print(#function)
//         sceneView.session.run(session.configuration!, options: [.resetTracking,.removeExistingAnchors])
       }
       
       
    }
   
}
//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
