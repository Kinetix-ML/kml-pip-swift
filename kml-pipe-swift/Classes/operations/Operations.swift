//
//  Operations.swift
//  
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation

enum NodeInitializer {
    case Node(CVNodeProcess)
}

let NodeCatalog: [String:CVNodeProcess.Type] = ["PoseDetection2D": PoseDetection2D.self, "NormKeyPointsSize": NormKeyPointsSize.self, "CompareKPFrames": CompareKPFrames.self]

func initProcess(cvnode: CVNode, vars: [String: Any]) -> CVNodeProcess {
    guard let catalogItem = NodeCatalog[cvnode.operation] else {
        fatalError("Catalog item not found for operation: \(cvnode.operation)")
    }
    
    return catalogItem.init(cvnode: cvnode, vars: vars)
}
