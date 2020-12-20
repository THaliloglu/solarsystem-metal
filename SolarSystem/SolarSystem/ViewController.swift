//
//  ViewController.swift
//  SolarSystem
//
//  Created by Tolga Haliloğlu on 20.12.2020.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    var renderer: Renderer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        guard let metalView = view as? MTKView else {
            fatalError("metal view not set up in storyboard")
        }
        
        renderer = Renderer(metalView: metalView)
    }
}

