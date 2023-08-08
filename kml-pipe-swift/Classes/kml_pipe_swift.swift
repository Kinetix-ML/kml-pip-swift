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
        
        print("got here")
        self.project = response.project
        self.version = response.version
        
        self.pipeline = self.version?.pipeline
        self.nodes = self.version?.pipeline.nodes ?? []
        
        
        print(self.nodes)
        for node in self.nodes! {
            if self.execNodes[node.id] == nil {
                let newExecNode = initProcess(cvnode: node, vars: self.vars)
                try await newExecNode.initialize()
                self.execNodes[node.id] = newExecNode
                print("adding exec node: \(node.id) \(newExecNode)")
            
            }
        }
        
        
    }
    
    public func execute(inputValues: [Any]) async throws -> [CVVariableConnection] {
        
        // check inputs
        if inputValues.count != self.pipeline?.inputs.count {
            throw ExecutionError.incorrectNumInputs
        }
        
        
        // reset execution state
        self.vars = [:]
        
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
            print("[Node Exeuction] running for \(readyNodes.count) ready nodes")
            for node in readyNodes {
                print("[Node Execution] execution node \(node.id)")
                print("node to execute: \(self.execNodes[node.id])")
                guard let execNode = self.execNodes[node.id] as? CVNodeProcess else {
                    throw ExecutionError.executionNodeNotInitializedProperly
                }
                try await execNode.execute(vars: &self.vars)
            }
            executedNodes.append(contentsOf: readyNodes)
            print("executed nodes: \(executedNodes)")
            readyNodes = checkReadyNodes(nodes: nodes, executedNodes: executedNodes, vars: self.vars)
            print("[Node Exeuction] adding \(readyNodes.count) new ready nodes ")
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
        print("nodes \(nodes)")
        let notExecuted = nodes.filter { n in
            let eN = executedNodes.filter { e in
                return e.id == n.id
            }
            return eN.count == 0
        }
        print("executedNodes \(notExecuted)")
        let ready = notExecuted.filter { n in
            let ins = n.inputs.filter { input in
                print("input val: \(input.connection?.id) \(self.vars[input.connection!.id])")
                return self.vars[input.connection!.id] != nil
            }
            return ins.count == n.inputs.count
        }
        
        print("read: \(ready) vars: \(vars)")
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
