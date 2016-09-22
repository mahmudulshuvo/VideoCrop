//
//  ViewController.swift
//  VideoCrop
//
//  Created by SHUVO on 9/21/16.
//  Copyright © 2016 SHUVO. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import CoreMedia

class ViewController: UIViewController {
    
    var exporter: AVAssetExportSession!
    var mPlayer: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cropVideo()
    }
    
    
    
    func cropVideo() {

        let asset = AVAsset.init(url: URL(fileURLWithPath: Bundle.main.path(forResource: "sample", ofType: "mov")!))
        let clipVideoTrack = asset.tracks(withMediaType: AVMediaTypeVideo)[0]
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(1, 30)
        videoComposition.renderSize = CGSize(width: clipVideoTrack.naturalSize.height, height: clipVideoTrack.naturalSize.height)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(120, 60))
        let transformer = AVMutableVideoCompositionLayerInstruction.init(assetTrack: clipVideoTrack)
        let t1 = CGAffineTransform(translationX: clipVideoTrack.naturalSize.height, y: 0)
        let t2 = t1.rotated(by: CGFloat(M_PI_2))
        let finalTransform = t2
        transformer.setTransform(finalTransform, at: kCMTimeZero)
        instruction.layerInstructions = [transformer]
        videoComposition.instructions = [instruction]
        
 
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let exportPath = documentsPath.appendingFormat("/CroppedVideo.mp4")
        let exportUrl = URL(fileURLWithPath: exportPath)
        print("export url  = \(exportUrl)")
        
        
        do {
            try FileManager.default.removeItem(at: exportUrl)
        }
        catch _ {
        }

        exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
        exporter.videoComposition = videoComposition
        exporter.outputURL = exportUrl
        exporter.outputFileType = AVFileTypeQuickTimeMovie
        exporter.exportAsynchronously(completionHandler: {() -> Void in
            DispatchQueue.main.async(execute: {() -> Void in
                self.exportDidFinish(self.exporter)
            })
        })
    }
    
    func exportDidFinish(_ session: AVAssetExportSession) {
        let outputURL = session.outputURL
        print("outputurl  = \(outputURL)")
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



