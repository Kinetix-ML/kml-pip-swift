// The Swift Programming Language
// https://docs.swift.org/swift-book
import Foundation
@available(macOS 10.15, *)
public class KMLPipeline {
    var projectName: String
    var projectVersion: Int
    var apiKey: String
    var project: Project?
    var version: Version?
    var pipeline: CVPipeline?
    var nodes: [CVNode]?
    var execNodes: [String:CVNodeProcess] = [:]
    var vars: [String:Any] = [:]
    
    public init(projectName: String, projectVersion: Int, apiKey: String) {
        self.projectName = projectName
        self.projectVersion = projectVersion
        self.apiKey = apiKey
    }
    public func initialize() async throws {
        let response = try await getProjectVersion(projectName: self.projectName, projectVersion: self.projectVersion, apiKey: self.apiKey)
        
        self.project = response.project
        self.version = response.version
        
        self.pipeline = self.version?.pipeline
        self.nodes = self.version?.pipeline.nodes ?? []
        
        for node in self.nodes! {
            if self.execNodes[node.id] == nil {
                let newExecNode = initProcess(cvnode: node, vars: self.vars)
                try await newExecNode.initialize()
                self.execNodes[node.id] = newExecNode
            }
        }
        
        
    }
    
    public func execute(inputValues: [Any]) async throws -> [CVVariableConnection] {
        
        // check inputs
        if inputValues.count != self.pipeline?.inputs.count {
            throw ExecutionError.incorrectNumInputs
        }
        
        
        // reset execution state
        self.vars.removeAll()
        
        // set inputs
        self.pipeline?.inputs.enumerated().forEach { i, input in
            self.vars[input.id] = inputValues[i]
        }
        
        // run execution
        // check ready nodes
        var executedNodes: [CVNode] = []
        guard let nodes = self.nodes as? [CVNode] else {
            throw ExecutionError.pipelineNotInitialized
        }
        var readyNodes: [CVNode] = checkReadyNodes(nodes: nodes, executedNodes: executedNodes, vars: self.vars)
        if readyNodes.count == 0 {
            throw ExecutionError.noNodesToExecute
        }
        
        // run while loop
        while readyNodes.count > 0 {
            for node in readyNodes {
                guard let execNode = self.execNodes[node.id] as? CVNodeProcess else {
                    throw ExecutionError.executionNodeNotInitializedProperly
                }
                try await execNode.execute(vars: &self.vars)
            }
            executedNodes.append(contentsOf: readyNodes)
            readyNodes = checkReadyNodes(nodes: nodes, executedNodes: executedNodes, vars: self.vars)
        }
        
        let res = self.pipeline?.outputs.enumerated().map { i, output in
            let newVar = CVVariable(id: output.connection!.id, name: output.connection!.name, dataType: DataType(rawValue: (output.connection?.dataType)!.rawValue) ?? DataType.AnyType, value: self.vars[output.connection!.id])
            let newOutput = CVVariableConnection(id: output.id, connection: newVar, dataType: output.dataType)
            return newOutput
        }
        
        // return results
        return res!
    }
    
    private func checkReadyNodes(nodes: [CVNode], executedNodes: [CVNode], vars: [String: Any]) -> [CVNode] {
        let notExecuted = nodes.filter { n in
            let eN = executedNodes.filter { e in
                return e.id == n.id
            }
            return eN.count == 0
        }
        let ready = notExecuted.filter { n in
            let ins = n.inputs.filter { input in
                return self.vars[input.connection!.id] != nil
            }
            return ins.count == n.inputs.count
        }
        return ready
    }
    
}

enum ExecutionError: String, Error {
    case incorrectNumInputs
    case pipelineNotInitialized
    case noNodesToExecute
    case executionNodeNotInitializedProperly
    case nodeInputNotFound
}
