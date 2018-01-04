//
//  MidiRecordModel.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/2.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import AVKit

class MidiRecordModel: NSObject {
    // 产生音符
    private var midi消息创建者 = MidiMessageCreater()
    // 标记是否在记录
    private var 是否在记录 : Bool = false
    // 记录文件的存储位置
    private var itemModel:VideoMidiItemModel?
    // 音符序列
    private var sequence : MusicSequence?
    // 音轨
    private var track : MusicTrack?
    
    var 记录音符 : [MIDINoteMessageStamp] = []

    func 收到蓝牙进来的事件(data: Data) {
        MidiTransfer.transToMidiComment(data: data) {
            [unowned self] (uInt8Arr) in
            print(uInt8Arr)
            if self.是否在记录 {
                midi消息创建者.receiveMessage(data: uInt8Arr)
            }
        }
    }
    func 开始录制(model:VideoMidiItemModel) {
        是否在记录 = true
        记录音符 = []
        itemModel = model
        midi消息创建者.设置相对时间()
        midi消息创建者.noteMessageBack = {
            [unowned self] (message : MIDINoteMessageStamp) in
            self.记录音符.append(message)
        }
    }
    // 返回错误录制失败
    func 停止录制() -> Bool {
        是否在记录 = false
        var osstatus  = NewMusicSequence(&sequence)
        var data:Unmanaged<CFData>?
        print(osstatus)
        var track : MusicTrack?
        osstatus = MusicSequenceNewTrack(sequence!, &track)
        print("q \(osstatus)")
        /// 时间
        for var item in 记录音符 {
            osstatus = MusicTrackNewMIDINoteEvent(track!,item.musicTimeStamp, &item.noteMessage)
            print("q \(osstatus)")
        }
        osstatus = MusicSequenceFileCreateData (sequence!,
                                                .midiType,
                                                .eraseFile,
                                                480, &data)
        print("q \(osstatus)")
        let midiData = data!.takeRetainedValue() as Data
        if osstatus != 0 {
            print("转换为midi失败")
            return false
        }
        try? FileManager.default.removeItem(atPath: (itemModel?.midiFilePath)!)
        do {
            try midiData.write(to: URL(fileURLWithPath: (itemModel?.midiFilePath)!))
            return true
        } catch let reason {
            print(reason)
            return false
        }
    }
}

class MidiMessageCreater : NSObject {
    var noteMessageBack : ((_ message : MIDINoteMessageStamp) -> Void)?
    
    var unInitNoteMessages : [MIDINoteMessageStamp] = []
    
    var 相对时间 : Date!
    
    func receiveMessage(data: [UInt8]){
        if data[0] >> 4 == 0x8 {
            for var item in unInitNoteMessages.enumerated() {
                if item.element.noteMessage.note == data[1] {
                    item.element.noteMessage.releaseVelocity = data[2]
                    let du = Date().timeIntervalSince(相对时间) * 2 - item.element.musicTimeStamp
                    item.element.noteMessage.duration = Float32(du)
                    if let noteBack = noteMessageBack {
                        print("返回音符")
                        noteBack(item.element)
                    }
                    unInitNoteMessages.remove(at: item.offset)
                    return
                }
            }
        }else if data[0] >> 4 == 0x9 {
            if data[2] == 0 {
                for var item in unInitNoteMessages.enumerated() {
                    if item.element.noteMessage.note == data[1] {
                        item.element.noteMessage.releaseVelocity = data[2]
                        let du = Date().timeIntervalSince(相对时间) * 2 - item.element.musicTimeStamp
                        item.element.noteMessage.duration = Float32(du)
                        if let noteBack = noteMessageBack {
                            print("返回音符")
                            noteBack(item.element)
                        }
                        unInitNoteMessages.remove(at: item.offset)
                        return
                    }
                }
            }else{
                var noteMessage = MIDINoteMessageStamp(Date().timeIntervalSince(相对时间) * 2)
                noteMessage.noteMessage.note = data[1]
                noteMessage.noteMessage.velocity = data[2]
                unInitNoteMessages.append(noteMessage)
            }
        }else{
            var str = "收到其它数据"
            for item in data {
                str += "\(item)"
            }
            print(str)
        }
    }
    
    func 设置相对时间() {
        相对时间 = Date()
    }
}

struct MIDINoteMessageStamp {
    var noteMessage = MIDINoteMessage()
    var musicTimeStamp : MusicTimeStamp
    init(_ usicTimeStamp : MusicTimeStamp) {
        musicTimeStamp = usicTimeStamp
    }
}
