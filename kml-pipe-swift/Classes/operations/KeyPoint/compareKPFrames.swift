//
//  poseDetection2D.swift
//
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation
class CompareKPFrames: CVNodeProcess {
    override func initialize() async throws {
    }
    
    override func execute(vars: inout [String:Any]) async throws {
        
        guard let frame = vars[self.cvnode.inputs[0].connection!.id] as? KPFrame else {
            throw ExecutionError.nodeInputNotFound
        }
        guard let frame2 = vars[self.cvnode.inputs[1].connection!.id] as? KPFrame else {
            throw ExecutionError.nodeInputNotFound
        }
        
        vars[self.cvnode.outputs[0].id] = try compareKPFrames(frame: frame, frame2: frame2)
        
    }
    
    private func compareKPFrames(frame: KPFrame, frame2: KPFrame) throws -> [Double] {
        var res: [Double] = []
        for i in 0..<frame.keyPoints.count {
            let kp = frame.keyPoints[i]
            let kp2 = frame2.keyPoints[i]
            let similarity = try cosineSimilarity(vector1: [kp.coordinate.x, kp.coordinate.y], vector2: [kp2.coordinate.x, kp2.coordinate.y])
            res.append(similarity)
        }
        return res
    }
    
    private func cosineSimilarity(vector1: [Double], vector2: [Double]) throws -> Double {
        if vector1.count != vector2.count {
            throw NSError(domain: "com.example", code: 1, userInfo: [NSLocalizedDescriptionKey: "Vectors must have the same length"])
        }

        var dotProduct: Double = 0
        var normVector1: Double = 0
        var normVector2: Double = 0

        for i in 0..<vector1.count {
            dotProduct += vector1[i] * vector2[i]
            normVector1 += vector1[i] * vector1[i]
            normVector2 += vector2[i] * vector2[i]
        }

        normVector1 = sqrt(normVector1)
        normVector2 = sqrt(normVector2)

        if normVector1 == 0 || normVector2 == 0 {
            return 0 // Handle zero vector case
        }

        let similarity = dotProduct / (normVector1 * normVector2)
        return similarity
    }
    
}
