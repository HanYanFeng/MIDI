//
//  ViewController.swift
//  MIdi-parsing
//
//  Created by 韩艳锋 on 2017/12/6.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        var musicsquence: MusicSequence?
        NewMusicSequence(&musicsquence)
        //带变速的
        let dataPath = Bundle.main.path(forResource: "waiguoshaonian333bianpaihao", ofType: "mid")
        let data = try? Data(contentsOf: URL(fileURLWithPath: dataPath!))
        MusicSequenceFileLoadData(musicsquence!, data! as CFData, .midiType, .smf_PreserveTracks)
        
        var tc: UInt32 = 0
        MusicSequenceGetTrackCount(musicsquence!, &tc);

        var dddd: CABarBeatTime = CABarBeatTime()
        
        MusicSequenceBeatsToBarBeatTime(musicsquence!, 0, 0, &dddd)
        
        tc += 1
        var noteMessage: MIDINoteMessage?
        for index in 0..<tc {
            var track: MusicTrack?
            var _iterator: MusicEventIterator?
            if index == tc - 1 {
                MusicSequenceGetTempoTrack(musicsquence!, &track)
            }else{
                MusicSequenceGetIndTrack(musicsquence!, index, &track);
            }
            NewMusicEventIterator(track!, &_iterator);
            var hasCurrentEvent: DarwinBoolean = false
            var type: MusicEventType = kMusicEventType_NULL
            var timeInBeat: MusicTimeStamp = 0
            var size: UInt32 = 0
            var data: UnsafeRawPointer?
            repeat{
                MusicEventIteratorGetEventInfo(_iterator!, &timeInBeat, &type, &data, &size)
//                print(type)
                print(timeInBeat)
                switch type {
                case kMusicEventType_ExtendedNote:
                    print(OCFunction.kMusicEventType_ExtendedNote(Data(bytes: data!, count: Int(size))))
                    break
                case kMusicEventType_ExtendedTempo:
                    // 127 页有速度的东西
                    // FF 51 03 tt tt tt 六个t为一个四分音符所需要的时间，例：07 A1 20为500000微秒 0.5秒
                    // 事件仅存在于TempoTrack
                    // 例：ExtendedTempoEvent(bpm: 96.0)
                    print(OCFunction.kMusicEventType_ExtendedTempo(Data(bytes: data!, count: Int(size))))
                    break
                case kMusicEventType_User:
                    print(OCFunction.kMusicEventType_User(Data(bytes: data!, count: Int(size))))
                    break
                case kMusicEventType_Meta:
                    let meatEvent = OCFunction.kMusicEventType_Meta(Data(bytes: data!, count: Int(size)))
                    print(meatEvent)
                    if meatEvent.metaEventType == 88 {
                        print("拍号变了")
                    }
                    break
                case kMusicEventType_MIDINoteMessage:
                    // 0x80~0x8f
                    // 0x90~0x9f
                    let msg = OCFunction.kMusicEventType_MIDINoteMessage(Data(bytes: data!, count: Int(size)))
                    print(msg)
                    var endTimeInSecond: Double = 0
                    MusicSequenceGetSecondsForBeats(musicsquence!, timeInBeat + Float64(msg.duration), &endTimeInSecond);
                    break
                case kMusicEventType_MIDIChannelMessage:
                    // 0xb0~0xbf
                    // 0xc0~0xcf
                    print(OCFunction.kMusicEventType_MIDIChannelMessage(Data(bytes: data!, count: Int(size))))
                    break
                case kMusicEventType_MIDIRawData:
                    print(OCFunction.kMusicEventType_MIDIRawData(Data(bytes: data!, count: Int(size))))
                    break
                case kMusicEventType_Parameter:
                    print(OCFunction.kMusicEventType_Parameter(Data(bytes: data!, count: Int(size))))
                    break
                case kMusicEventType_AUPreset:
                    print(OCFunction.kMusicEventType_AUPreset(Data(bytes: data!, count: Int(size))))
                    break
                default:
                    print("未知")
                    break
                }
                MusicEventIteratorNextEvent(_iterator!);
                MusicEventIteratorHasCurrentEvent(_iterator!, &hasCurrentEvent);
            }while(hasCurrentEvent.boolValue)
//            (lldb) p kMusicEventType_ExtendedNote
//            (UInt32) $R0 = 1
//            (lldb) p kMusicEventType_ExtendedTempo
//            (UInt32) $R1 = 3
//            (lldb) p kMusicEventType_User
//            (UInt32) $R2 = 4
//            (lldb) p kMusicEventType_Meta
//            (UInt32) $R3 = 5
//            (lldb) p kMusicEventType_MIDINoteMessage
//            (UInt32) $R4 = 6
//            (lldb) p kMusicEventType_MIDIChannelMessage
//            (UInt32) $R5 = 7
//            (lldb) p kMusicEventType_MIDIRawData
//            (UInt32) $R6 = 8
//            (lldb) p kMusicEventType_Parameter
//            (UInt32) $R7 = 9
//            (lldb) p kMusicEventType_AUPreset
//            (UInt32) $R8 = 10
        }

    }
}

