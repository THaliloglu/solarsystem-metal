//
//  Scene.swift
//  SolarSystem
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import Foundation
import CoreGraphics

class Scene {
    var sceneSize: CGSize
    
    var cameras = [Camera()]
    var currentCameraIndex = 0
    var camera: Camera  {
        return cameras[currentCameraIndex]
    }
    
    let rootNode = Node()
    var renderables: [Renderable] = []
    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    let lighting = Lighting()
    
    let inputController = InputController()
    
    init(sceneSize: CGSize) {
        self.sceneSize = sceneSize
        setupScene()
        sceneSizeWillChange(to: sceneSize)
        
        fragmentUniforms.lightCount = lighting.count
    }
    
    final func update(deltaTime: Float) {
        updatePlayer(deltaTime: deltaTime)
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        fragmentUniforms.cameraPosition = camera.position
        
        updateScene(deltaTime: deltaTime)
        update(nodes: rootNode.children, deltaTime: deltaTime)
    }
    
    private func update(nodes: [Node], deltaTime: Float) {
        nodes.forEach { node in
            node.update(deltaTime: deltaTime)
            update(nodes: node.children, deltaTime: deltaTime)
        }
    }
    
    func setupScene() {
        // override this to add objects to the scene
    }
    
    func updateScene(deltaTime: Float) {
        // override this to update your scene
    }
    
    private func updatePlayer(deltaTime: Float) {
        inputController.updatePlayer(deltaTime: deltaTime)
    }
    
    final func add(node: Node,
                   parent: Node? = nil,
                   render: Bool = true) {
        if let parent = parent {
            parent.add(childNode: node)
        } else {
            rootNode.add(childNode: node)
        }
        
        guard render == true,
              let renderable = node as? Renderable else {
            return
        }
        renderables.append(renderable)
    }
    
    final func remove(node: Node) {
        if let parent = node.parent {
            parent.remove(childNode: node)
        } else {
            for child in node.children {
                child.parent = nil
            }
            node.children = []
        }
        
        guard node is Renderable,
              let index = (renderables.firstIndex {
                $0 as? Node === node
              }) else { return }
        renderables.remove(at: index)
    }
    
    func sceneSizeWillChange(to size: CGSize) {
        for camera in cameras {
            camera.aspect = Float(size.width / size.height)
        }
        sceneSize = size
    }
}
