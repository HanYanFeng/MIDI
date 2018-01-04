//
//  VideoMidiModel.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/2.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
struct VideoMidiItemModel {
    var midiFilePath : String
    var videoFilePath : String
    var nameNumber : Int
    init(midi:String ,video:String) {
        midiFilePath = midi
        videoFilePath = video
        let nsstr =  videoFilePath as NSString
        let arr = nsstr.components(separatedBy: "/")
        let last = arr.last?.filter({ (char) -> Bool in
            return Int("\(char)") != nil
        })
        nameNumber = Int(last!)!
    }
    
    init(number : Int,baseStr : String) {
        nameNumber = number
        midiFilePath = baseStr + "/a\(nameNumber)" + "mid.mid"
        videoFilePath = baseStr + "/a\(nameNumber)" + "mov.mov"
    }
}

class VideoMidiModel: NSObject {
    let videoMidiItemModelPath = NSHomeDirectory() + "/Documents"
    var videoMidiItemModelList : [VideoMidiItemModel] = []
    static let shard : VideoMidiModel = VideoMidiModel()
    
    var midiRecordModel = MidiRecordModel()
    var videoRecordModel = VideoRecordModel()

    override init() {
        super.init()
        刷新videoMidi列表()
    }
    func 刷新videoMidi列表() {
        var midArr : [String] = []
        var movArr : [String] = []
        if let arr = try? FileManager.default.contentsOfDirectory(atPath: videoMidiItemModelPath) {
            for item in arr {
                if item.hasSuffix(".mid") {
                    midArr.append(videoMidiItemModelPath + "/" + item)
                }else if item.hasSuffix(".mov") {
                    movArr.append(videoMidiItemModelPath + "/" + item)
                }
            }
        }
        videoMidiItemModelList = []
        for item in midArr {
            var str = item
            str.removeSubrange(str.index(str.endIndex, offsetBy: -7)..<str.endIndex)
            str.append("mov.mov")
            if movArr.contains(str) {
                let dd = VideoMidiItemModel(midi: item, video: str)
                videoMidiItemModelList.append(dd)
            }
        }
    }
    
    func 开始录制() {
        let new = self.newVideoMidiItemModel()
        self.videoRecordModel.开始录制(model: new)
        self.midiRecordModel.开始录制(model: new)
    }
    
    func 停止录制() {
        self.videoRecordModel.停止录制()
        _ = self.midiRecordModel.停止录制()
    }
    
    private func newVideoMidiItemModel() -> VideoMidiItemModel {
        videoMidiItemModelList.sort { (model1, model2) -> Bool in
            return model1.nameNumber < model2.nameNumber
        }
        if videoMidiItemModelList.isEmpty {
            return VideoMidiItemModel(number: 100, baseStr: videoMidiItemModelPath)
        }else{
            let number = videoMidiItemModelList.last!.nameNumber + 1
            return VideoMidiItemModel(number: number, baseStr: videoMidiItemModelPath)
        }
    }
}
