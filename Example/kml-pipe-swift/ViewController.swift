//
//  ViewController.swift
//  kml-pipe-swift
//
//  Created by MadeWithStone on 08/07/2023.
//  Copyright (c) 2023 MadeWithStone. All rights reserved.
//

import UIKit
import kml_pipe_swift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await createPipeline()
        }
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func createPipeline() async {
        do {
            let pipe = KMLPipeline(projectName: "Swift Test Project", projectVersion: 1, apiKey: "79705c77-f57b-449d-b856-03138e8859a7")
            try await pipe.initialize()
            let results = try await pipe.execute(inputValues: [buffer(from: UIImage(named: "test.webp")!)])
            print(results)
        } catch {
            print(error)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

