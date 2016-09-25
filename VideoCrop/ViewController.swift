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
        videoComposition.renderSize = CGSize(width: 320, height: 240)

        let parentLayer = CALayer()
        parentLayer.frame = CGRect(x :0, y :0, width :320, height :240)
        let videoLayer = CALayer()
        let diameter = min(parentLayer.frame.size.width, parentLayer.frame.size.height) * 0.8;
        videoLayer.frame = CGRect(x :(parentLayer.frame.size.width - diameter) / 2,
                                      y :(parentLayer.frame.size.height - diameter) / 2,
                                      width :diameter, height :diameter);
        videoLayer.cornerRadius = diameter / 2;
        videoLayer.masksToBounds = true;
        videoLayer.contentsGravity = kCAGravityResizeAspectFill
        parentLayer.addSublayer(videoLayer) 
        self.view.layer.addSublayer(parentLayer)
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)

        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)
        let videoLayerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: clipVideoTrack)
        let videoTransform = getResizeAspectFillTransform(videoSize: clipVideoTrack.naturalSize, outputSize: self.view.frame.size)
        videoLayerInstruction.setTransform(videoTransform, at: kCMTimeZero)
        instruction.layerInstructions = [videoLayerInstruction]
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
    

    private func getResizeAspectFillTransform(videoSize: CGSize, outputSize: CGSize) -> CGAffineTransform {

        let widthRatio = outputSize.width / videoSize.width
        let heightRatio = outputSize.height / videoSize.height
        let scale = widthRatio >= heightRatio ? widthRatio : heightRatio
        let newWidth = videoSize.width * scale
        let newHeight = videoSize.height * scale
        let translateX = (outputSize.width - newWidth) / 2 / scale
        let translateY = (outputSize.height - newHeight) / 2 / scale
        let resizeTransform = CGAffineTransform(scaleX: scale, y: scale)
        let finalTransform = resizeTransform.translatedBy(x: translateX, y: translateY)

        return finalTransform
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}



