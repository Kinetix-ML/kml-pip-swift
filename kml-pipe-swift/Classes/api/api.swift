//
//  api.swift
//
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation

enum APIError: Error {
    case parsingFailed
    case requestNotFullfilledCorrectly
}

@available(*, renamed: "getProjectVersion(projectName:projectVersion:apiKey:)")
func getProjectVersion(projectName: String, projectVersion: Int, apiKey: String) async throws -> APIResponse {
    let urlString = "https://getpipeline-kk2bzka6nq-uc.a.run.app/?projectName=\(projectName)&version=\(projectVersion)&apiKey=\(apiKey)"
    let replacedURL = urlString.replacingOccurrences(of: " ", with: "%20", options: .literal, range: nil)
    if let url = URL(string: replacedURL) {
        let (data, response) = try await URLSession.shared.data(from: url)
            if let dict = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                let apiResponse = try buildAPIResponse(json: dict)
                return apiResponse
            } else {
                throw APIError.requestNotFullfilledCorrectly
            }
    } else {
        throw APIError.requestNotFullfilledCorrectly
    }
}

func buildAPIResponse(json: [String:Any]) throws -> APIResponse {
    // parse project
    guard let project = json["project"] as? [String:Any], let owner = project["owner"] as? String, let projectName = project["projectName"] as? String, let id = project["id"] as? String, let versions = project["versions"] as? [Int] else {
        throw APIError.parsingFailed
    }
    
    // parse version
    guard let version = json["version"] as? [String:Any], let v = version["version"] as? Int, let projectID = version["projectID"] as? String, let id = version["id"] as? String, let pipeline = version["pipeline"] as? [String:Any] else {
        throw APIError.parsingFailed
    }
    
    // parse pipeline
    guard let pipeOutputs = pipeline["outputs"] as? [[String:Any]], let pipeInputs = pipeline["inputs"] as? [[String:Any]], let pipeNodes = pipeline["nodes"] as? [[String:Any]] else {
        throw APIError.parsingFailed
    }
    
    // parse inputs
    let inputs = try parseInputs(ins: pipeInputs)
    
    // parse outputs
    let outputs = try parseOutputs(ous: pipeOutputs)
    
    // parse nodes
    let nodes: [CVNode] = try pipeNodes.map { node in
        guard let inputs = node["inputs"] as? [[String:Any]], let outputs = node["outputs"] as? [[String:Any]], let id = node["id"] as? String, let supportedPlatforms = node["supportedPlatforms"] as? [String], let label = node["label"] as? String, let operation = node["operation"] as? String, let parameters = node["parameters"] as? [[String:Any]] else {
            throw APIError.parsingFailed
        }
        let parsedInputs = try parseOutputs(ous: inputs)
        let parseOutputs = try parseInputs(ins: outputs)
        let parsedParameters = try parseParameters(pas: parameters)
        let parsedSupportedPlatforms = supportedPlatforms.map { p in Platform(rawValue: p) ?? Platform.SWIFT}
        
        return CVNode(id: id, label: label, operation: operation, parameters: parsedParameters, inputs: parsedInputs, outputs: parseOutputs, supportedPlatforms: parsedSupportedPlatforms)
    }
    
    let resProject = Project(id: id, projectName: projectName, owner: owner, versions: versions)
    let resPipeline = CVPipeline(inputs: inputs, outputs: outputs, nodes: nodes)
    let resVersion = Version(id: id, projectID: projectID, version: v, pipeline: resPipeline)
    return APIResponse(project: resProject, version: resVersion)
}

func parseInputs(ins: [[String: Any]]) throws -> [CVVariable] {
    let inputs: [CVVariable] = try ins.map {i in
        guard let id = i["id"] as? String, let name = i["name"] as? String, let dataType = i["dataType"] as? String else {
            throw APIError.parsingFailed
        }
        return CVVariable(id: id, name: name, dataType: DataType(rawValue: dataType) ?? DataType.AnyType)
    }
    return inputs
}

func parseOutputs(ous: [[String: Any]]) throws -> [CVVariableConnection] {
    let outputs: [CVVariableConnection] = try ous.map {o in
        guard let id = o["id"] as? String, let dataType = o["dataType"] as? String, let connection = o["connection"] as? [String:Any] else {
            throw APIError.parsingFailed
        }
        guard let cDataType = connection["dataType"] as? String, let cName = connection["name"] as? String, let cId = connection["id"] as? String else {
            throw APIError.parsingFailed
        }
        let c = CVVariable(id: cId, name: cName, dataType: DataType(rawValue: cDataType) ?? DataType.AnyType)
        return CVVariableConnection(id: id, connection: c, dataType: DataType(rawValue: dataType) ?? DataType.AnyType)
    }
    return outputs
}

func parseParameters(pas: [[String: Any]]) throws -> [CVParameter] {
    let params: [CVParameter] = try pas.map {p in
        guard let label = p["label"] as? String, let name = p["name"] as? String, let dataType = p["dataType"] as? String, let value = p["value"] as? Any else {
            throw APIError.parsingFailed
        }
        return CVParameter(name: name, label: label, dataType: DataType(rawValue: dataType) ?? DataType.AnyType, value: value)
    }
    return params
}
