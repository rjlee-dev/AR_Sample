//
//  ContentView.swift
//  AR Sample
//
//  Created by Richard Jason Lee on 2023-06-19.
//

import SwiftUI
import SpriteKit
import ARKit

struct ContentView: View {
   
   var body: some View {
      ZStack {
         ARSpriteKitView(skScene: ARGameScene())
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .edgesIgnoringSafeArea(.all)
      }
   }
}

struct ContentView_Previews: PreviewProvider {
   static var previews: some View {
      ContentView()
   }
}
