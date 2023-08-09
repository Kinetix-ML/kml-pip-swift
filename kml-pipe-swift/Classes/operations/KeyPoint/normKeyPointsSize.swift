//
//  poseDetection2D.swift
//
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation
class NormKeyPointsSize: CVNodeProcess {
    override func initialize() async throws {
    }
    
    override func execute(vars: inout [String:Any]) async throws {
        
        guard let frame = vars[self.cvnode.inputs[0].connection!.id] as? KPFrame else {
            throw ExecutionError.nodeInputNotFound
        }
        
        let minY = self.findMinY(frame);
            let maxY = self.findMaxY(frame);
            var minX = self.findMinX(frame);
            let maxX = self.findMaxX(frame);
            let y = maxY - minY;
            minX = (maxX + minX) / 2 - y / 2;

        let newKeypoints = frame.keyPoints.map {kp in
            kp.coordinate.x = (kp.coordinate.x - minX) / y
            kp.coordinate.y = (kp.coordinate.y - minY) / y
            return kp
            }
        let newFrame = KPFrame(keyPoints: newKeypoints, score: frame.score)
        vars[self.cvnode.outputs[0].id] = newFrame
        
    }
    
    private func findMaxY(_ frame: KPFrame) -> CGFloat {
        let vals = frame.keyPoints.sorted {
            $0.coordinate.y > $1.coordinate.y
        }
        return vals[0].coordinate.y
    }
    private func findMinY(_ frame: KPFrame) -> CGFloat {
        let vals = frame.keyPoints.sorted {
            $0.coordinate.y < $1.coordinate.y
        }
        return vals[0].coordinate.y
    }
    private func findMaxX(_ frame: KPFrame) -> CGFloat {
        let vals = frame.keyPoints.sorted {
            $0.coordinate.x > $1.coordinate.x
        }
        return vals[0].coordinate.x
    }
    private func findMinX(_ frame: KPFrame) -> CGFloat {
        let vals = frame.keyPoints.sorted {
            $0.coordinate.x < $1.coordinate.x
        }
        return vals[0].coordinate.x
    }
    
}
