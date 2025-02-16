//
//  MainViewController.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

import MetalKit

class MainViewController: LocalViewController {
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let metalView = view as? MTKView else {
            fatalError("metal view not set up in storyboard")
        }
        
        renderer = Renderer(metalView: metalView)
        let scene = DemoScene(sceneSize: metalView.bounds.size)
        renderer?.scene = scene
        
        addGestureRecognizers(to: metalView)
        
//        if let demoView = metalView as? DemoView {
//            demoView.inputController = scene.inputController
//        }
    }
}

