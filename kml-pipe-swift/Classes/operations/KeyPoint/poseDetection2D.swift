//
//  poseDetection2D.swift
//  
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation
class PoseDetection2D: CVNodeProcess {
    var confidenceThreshold: Double = 0.3
    var detector: PoseEstimator?
    override func initialize() async throws {
        guard case let self.confidenceThreshold = self.cvnode.parameters[0].value as? Double else {
            return
        }
        detector = try MoveNet(
                threadCount: 1,
                delegate: .gpu,
                modelType: .pose2d)
    }
    
    override func execute(vars: inout [String:Any]) async throws {
        guard let input = vars[self.cvnode.inputs[0].connection!.id] else {
            throw ExecutionError.nodeInputNotFound
        }
        let pose = try self.detector?.estimateSinglePose(on: input as! CVPixelBuffer)
        if let pose = pose {
            vars[self.cvnode.outputs[0].id] = pose.0
        } else {
            vars[self.cvnode.outputs[0].id] = DataType.NoDetections
        }
    }
}
