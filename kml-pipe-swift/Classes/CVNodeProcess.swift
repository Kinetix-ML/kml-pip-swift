//
//  CVNodeProcess.swift
//  
//
//  Created by Maxwell Stone on 8/7/23.
//

import Foundation

public class CVNodeProcess {
    var cvnode: CVNode
    var vars: [String:Any]
    
    required init(cvnode: CVNode, vars: [String:Any]
    ) {
        self.cvnode = cvnode
        self.vars = vars
    }
    
    func initialize() async throws {
    }
    
    func execute(vars: inout [String:Any]) async throws {
        
    }
    
    
    
}
