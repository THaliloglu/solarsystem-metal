//
//  MotionController.swift
//  SolarSystem-iOS
//
//  Created by TOLGA HALILOGLU on 13.02.2021.
//

import CoreMotion
import simd

class MotionController {
    let motionManager = CMMotionManager()
    var motionClosure: ((CMDeviceMotion?, Error?) -> Void)?
    var acceleration: float3 = [0, 0, 0]
    var previousAcceleration: float3 = [0, 0, 0]
    
    var deltaAcceleration: float3 {
        return previousAcceleration - acceleration
    }
    
    func setupCoreMotion() {
        motionManager.accelerometerUpdateInterval = 0.2
        let queue = OperationQueue()
        
        motionManager.startDeviceMotionUpdates(to: queue, withHandler: {
            motion, error in
            self.motionClosure?(motion, error)
        })
        motionManager.startAccelerometerUpdates(to: queue, withHandler: {
            accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            let acceleration = accelerometerData.acceleration
            self.previousAcceleration = self.acceleration
            self.acceleration.x = (Float(acceleration.x) * 0.75) + (self.acceleration.x * 0.25)
            self.acceleration.y = (Float(acceleration.y) * 0.75) + (self.acceleration.y * 0.25)
            self.acceleration.z = (Float(acceleration.z) * 0.75) + (self.acceleration.z * 0.25)
        })
    }
}
