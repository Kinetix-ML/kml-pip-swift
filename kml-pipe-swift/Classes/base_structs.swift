//
//  base_structs.swift
//
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation

/*
 export type CVImage = HTMLVideoElement | HTMLImageElement; UIImage
 export type KPFrame = Pose;
 export type FMFrame = Face;
 export type Vec = number[];
 export type Double = number;
 export type Int = number;
 export type String = string;
 export type Canvas = HTMLCanvasElement;
 export type Label = {
   x: number;
   y: number;
   value: string;
 };
 */

struct Vars {
    var vars: [String:Any] = [:]
    
    func get(_ id: String) -> Any {
        return vars[id]
    }
    
    mutating func set(_ id: String, _ val: Any) {
        self.vars[id] = val
    }
    
    mutating func clear() {
        self.vars = [:]
    }
}

struct APIResponse {
    var project: Project?
    var version: Version?
}

enum ValueTypes {
    case Vec(value: [Double])
    case Double(value: Double)
    case Int(value: Int)
    case String(name: String)
}

public struct CVVariable {
    public var id: String
    public var name: String
    public var dataType: DataType
    public var value: Any?
}

public struct CVParameter {
    var name: String
    var label: String
    var dataType: DataType
    var value: Any
}

public struct CVVariableConnection {
    var id: String
    var connection: CVVariable?
    var dataType: DataType
}

public struct CVNode {
    var id: String
    var label: String
    var operation: String
    var parameters: [CVParameter]
    var inputs: [CVVariableConnection]
    var outputs: [CVVariable]
    var supportedPlatforms: [Platform]
}

public struct Project {
    var id: String
    var projectName: String
    var owner: String
    var versions: [Int]
}

public struct Version {
    var id: String
    var projectID: String
    var version: Int
    var pipeline: CVPipeline
}

public struct CVPipeline {
    var inputs: [CVVariable]
    var outputs: [CVVariableConnection]
    var nodes: [CVNode]
}

public enum DataType: String, Codable {
    case CVImage = "Image"
    case KPFrame = "KPFrame"
    case Vec = "Vec"
    case Double = "Double"
    case NoDetections = "NoDetections"
    case String = "String"
    case Canvas = "Canvas"
    case AnyType = "Any"
}

public enum Platform: String, Codable {
    case JS = "JS"
    case SWIFT = "Swift"
    case PYTHON = "Python"
}
