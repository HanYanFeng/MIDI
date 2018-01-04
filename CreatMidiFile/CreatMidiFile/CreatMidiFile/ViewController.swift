//
//  ViewController.swift
//  CreatMidiFile
//
//  Created by 韩艳锋 on 2017/10/27.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import AVKit
class ViewController: UIViewController {
    var avplayer : AVMIDIPlayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var sequence : MusicSequence?
        var osstatus  = NewMusicSequence(&sequence)
//        let xiaobudata = try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "xiaobuwuqu (1)", ofType: "mid")!)) as CFData
//x
//        MusicSequenceFileLoadData(sequence!, xiaobudata as CFData, .midiType, .smf_PreserveTracks)
        var data:Unmanaged<CFData>?

        print(osstatus)
        var track : MusicTrack?
        osstatus = MusicSequenceNewTrack(sequence!, &track)
        print(osstatus)
        // 设置音色
        var channelMessage = MIDIChannelMessage(status: 192, data1: 1, data2: 0, reserved: 0)
        MusicTrackNewMIDIChannelEvent(track!, 0, &channelMessage)
        // All Controllers Off（控制器全关闭
        channelMessage = MIDIChannelMessage(status: 176, data1: 121, data2: 0, reserved: 0)
        MusicTrackNewMIDIChannelEvent(track!, 0, &channelMessage)
        // 10, Pan（相位)
        channelMessage = MIDIChannelMessage(status: 176, data1: 10, data2: 51, reserved: 0)
        MusicTrackNewMIDIChannelEvent(track!, 0, &channelMessage)
        // 7,Volume（音量）
        channelMessage = MIDIChannelMessage(status: 176, data1: 7, data2: 200, reserved: 0)
        MusicTrackNewMIDIChannelEvent(track!, 0, &channelMessage)
        
        // 添加音符
        for index in 0...10 {
            var meassage = MIDINoteMessage()
            // 这里面持续的节拍不是时间
            meassage.duration = 1
            meassage.note = UInt8(60 + index % 2)
            meassage.velocity = 127
            meassage.releaseVelocity = 0
            // 这里面的MusicTimeStamp为开始的节拍而不是时间
            osstatus = MusicTrackNewMIDINoteEvent(track!, MusicTimeStamp(index), &meassage)
            print(osstatus)
        }
        /// 找到速度通道设置速度
        MusicSequenceGetTempoTrack(sequence!, &track)
        MusicTrackNewExtendedTempoEvent(track!, 0, 60)
        
        osstatus = MusicSequenceFileCreateData (sequence!,
                                             .midiType,
                                              .eraseFile,
                                              480, &data)
        print(osstatus)
        let sfTowPatch = Bundle.main.path(forResource: "TimGM6mb", ofType: "sf2")
        let midiData = data!.takeRetainedValue() as Data
        try? midiData.write(to: URL(fileURLWithPath: "/Users/hanyanfeng/Desktop/未命名文件夹/creatmid2.mid"))
        avplayer = try? AVMIDIPlayer(data: midiData, soundBankURL: URL(fileURLWithPath: sfTowPatch!))
        avplayer?.prepareToPlay()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        avplayer?.currentPosition = 0
        avplayer?.play({
            print("播放结束")
        })
        print(avplayer?.isPlaying)
    }
}

