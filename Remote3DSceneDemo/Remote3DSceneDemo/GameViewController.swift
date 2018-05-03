//
//  GameViewController.swift
//  Remote3DSceneDemo
//
//  Created by mac126 on 2018/4/28.
//  Copyright © 2018年 mac126. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit
import Alamofire
import Zip

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // 下载zip
        // downloadZip()
        
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let destinationPath = documentDirectory.appendingPathComponent("artTest.scnassets/Menchi.dae")
        var scene: SCNScene!
        do {
            scene = try SCNScene(url: destinationPath, options: nil)
        } catch {
            print("noscene--")
        }

        let menchiNode = scene.rootNode.childNodes.first
        menchiNode?.transform = SCNMatrix4MakeScale(5, 5, 5)
        // create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 0, y: 3, z: 15)
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = .omni
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = .ambient
        ambientLightNode.light!.color = UIColor.darkGray
        scene.rootNode.addChildNode(ambientLightNode)
        
        // retrieve the ship node 旋转
        // let ship = scene.rootNode.childNode(withName: "Menchi", recursively: true)!
        let ship = scene.rootNode.childNodes.first!
        // animate the 3d object
        ship.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))

        let scnView = self.view as! SCNView
        
        // set the scene to the view
        // scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = true
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor.black
        
        scnView.scene = scene
        
        // add a tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        scnView.addGestureRecognizer(tapGesture)
        
    }
    
    func downloadZip() {
        // http://192.168.1.149/art.zip
        print("downloadZip")
        // 下载zip
        let destination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory, in: .userDomainMask)
        
        Alamofire.download("http://192.168.1.149/artTest.scnassets.zip", to: destination).downloadProgress { (progress) in
            if progress.isFinished {
                print("开始解压")
                // 解压
                let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let inputPath = documentDirectory.appendingPathComponent("artTest.scnassets.zip")
                
                print("--\(documentDirectory), --\(inputPath)")
                do {
                    try Zip.unzipFile(inputPath, destination: documentDirectory, overwrite: true, password: nil)
                } catch {
                    print("unzipwrong")
                }
            }
        }
    }
    
    @objc
    func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // check what nodes are tapped
        let p = gestureRecognize.location(in: scnView)
        let hitResults = scnView.hitTest(p, options: [:])
        // check that we clicked on at least one object
        if hitResults.count > 0 {
            // retrieved the first clicked object
            let result = hitResults[0]
            
            // get its material
            let material = result.node.geometry!.firstMaterial!
            
            // highlight it
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 0.5
            
            // on completion - unhighlight
            SCNTransaction.completionBlock = {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.5
                
                material.emission.contents = UIColor.black
                
                SCNTransaction.commit()
            }
            
            material.emission.contents = UIColor.red
            
            SCNTransaction.commit()
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
