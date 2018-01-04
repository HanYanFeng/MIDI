//
//  ScoreSimplModel.swift
//  琴加
//
//  Created by 袁银花 on 2017/5/16.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
class ScoreSimpl : NSObject {
    
    /// 曲谱ID
    var iden : NSNumber
    /// 大类
    var musicSort : String
    /// 小类
    var musicLevel : String
    /// 曲谱名称
    var musicName : String
    /// 作者
    var author : String
    /// 书名
    var bookName : String
    /// 曲谱封面url 废弃
    var musicPicUrl : String
    /// 曲目风格
    var style : String

    /// 搜索结果的优先级
    var searchPriority : Int64 = Int64.max
    /// 全拼
    var 全拼 : String = ""
    var 简拼 : String = ""
    var 无空格全拼 : String = ""
    var 单拼 : [String] = []
    init?(dic:[String:AnyObject]) {
    
        guard let iden = dic["id"] ,
            let musicLevel =  dic["musicLevel"] ,
            let musicName = dic["musicName"] ,
            let musicPicUrl = dic["musicPicUrl"] ,
            let musicSort = dic["musicSort"],
            let author = dic["musicAuthor"],
            let style = dic["musicStyle"],
            let bookName = dic["musicBookName"],
            let 全拼 = dic["mnQp"],
            let 简拼 = dic["mnSzm"]
            else{
                return nil
        }
        self.iden = iden as! NSNumber
        self.musicLevel = musicLevel  as! String
        self.musicName = musicName  as! String
        self.musicPicUrl = musicPicUrl  as! String
        self.musicSort = musicSort  as! String
        self.author = author  as! String
        self.style = style  as! String
        self.bookName = bookName as! String
        self.全拼 = 全拼 as! String
        self.全拼 = self.全拼.lowercased()
        
        self.简拼 = 简拼 as! String
        self.简拼 = self.简拼.lowercased()
        
        self.无空格全拼 = self.全拼.replacingOccurrences(of: " ", with: "")
        self.单拼 = self.全拼.components(separatedBy: " ")
        self.单拼 = self.单拼.filter({ (str) -> Bool in
            return !str.isEmpty
        })
        super.init()
    }
    override var description:String {
        return "iden:\(self.iden) musicLevel:\(self.musicLevel) musicName:\(self.musicName) musicPicUrl:\(self.musicPicUrl) musicSort:\(self.musicSort) \n"
    }
    func 搜索(str:String) -> Bool {
        
        if self.musicName.contains(str) {
            let subStrRange : Range<String.Index> = self.musicName.range(of: str)!
            self.searchPriority = Int64(subStrRange.lowerBound.encodedOffset)
            return true
        }else{
            var newStr = str.lowercased().replacingOccurrences(of: " ", with: "")
            if self.简拼.contains(newStr)  {
                let subStrRange : Range<String.Index> = self.简拼.range(of: newStr)!
                self.searchPriority = Int64(subStrRange.lowerBound.encodedOffset)
                return true
            }else{
                var first = true
                for string in self.单拼 {
                    if newStr.hasPrefix(string) {
                        newStr.removeSubrange(..<string.endIndex)
                        if first {
                            first = false
                            let subStrRange : Range<String.Index> = self.全拼.range(of: string)!
                            self.searchPriority = Int64(subStrRange.lowerBound.encodedOffset)
                        }
                    }
                    else{
                        if !first {
                            self.searchPriority = self.searchPriority + 10
                        }
                    }
                    if newStr.isEmpty {
                        return true
                    }
                }
            }
        }
        return false
    }
}
class RelationMusic: NSObject {
    var musicMidiUrl : String
    var id : NSNumber
    var musicPdfUrl : String
    var musicMp3Url : String?
    var musicName : String
    var musicDbUrl : String
    var musicPicUrl : String
    init?(dic :[String:AnyObject]) {
        if let musicMidiUrl = dic["musicMidiUrl"],let id = dic["id"],let musicPdfUrl = dic["musicPdfUrl"],let musicName = dic["musicName"],let musicDbUrl = dic["musicDbUrl"],let musicPicUrl = dic["musicPicUrl"] {
            self.musicMidiUrl = musicMidiUrl as! String
            self.id = id as! NSNumber
            self.musicPdfUrl = musicPdfUrl as! String
            self.musicMp3Url  = dic["musicMp3Url"] as? String
            self.musicName = musicName as! String
            self.musicDbUrl = musicDbUrl as! String
            self.musicPicUrl = musicPicUrl as! String
        }else{
         return nil
        }
    }
    static func 创建relationMusic数组(arr : [[String:AnyObject]]) -> [RelationMusic]? {
        var backarr : [RelationMusic] = []
        for relationMusicDic  in arr {
            let relationMusic = RelationMusic(dic: relationMusicDic)
            if  let relationMusic = relationMusic {
                backarr.append(relationMusic)
            }else{
                return nil
            }
        }
        return backarr
    }
}
class ScoreDetail: NSObject {
    ///曲谱ID
    var  id : NSNumber
    ///书名
    var  musicBookName : String
    ///文件名
    var  fileName : String
//    ///曲谱名称
    var  musicname : String
    ///曲谱作者
    var  musicAuthor : String
    ///曲谱地区
    var  musicAuthorDiatrict : String
    ///曲谱难度
    var  musicDifficultLevel : String
    ///作者简介
    var  musicAuthorIntroduce : String
    ///曲谱风格
    var  musicStyle : String
    ///曲谱PDF
    var   musicPdfUrl : String
    ///曲谱DB
    var  musicDbUrl : String
    ///曲谱MIDI
    var musicMidiUrl : String
    ///曲谱MP3
    //    var   musicMp3Url : String
    ///相关曲目ID
    var  relationMusic : [RelationMusic]
    
    var score: Score?
    var midiData: Data?
    
    var 是否收藏: Bool
    var musicDetailIntroduce : String
    var musicMp3Url : String
    
    init?(dic : [String: AnyObject]) {
        if let id = dic["id"], let musicAuthorIntroduce = dic["musicAuthorIntroduce"], let musicBookName = dic["musicBookName"], let musicAuthorDiatrict = dic["musicAuthorDiatrict"],let  musicDifficultLevel = dic["musicDifficultLevel"] ,let musicDetailIntroduce = dic["musicDetailIntroduce"], let musicStyle = dic["musicStyle"], let musicMidiUrl = dic["musicMidiUrl"], let fileName = dic["fileName"], let musicAuthor = dic["musicAuthor"], let musicPdfUrl = dic["musicPdfUrl"],let musicMp3Url = dic["musicMp3Url"], let musicDbUrl = dic["musicDbUrl"] , let relationMusic = dic["relationMusic"], let isCollect = dic["isCollect"]{
            self.id = id as! NSNumber
            self.musicAuthorIntroduce = musicAuthorIntroduce as! String
            self.musicBookName = musicBookName as! String
            self.musicAuthorDiatrict = musicAuthorDiatrict as! String
            self.musicDifficultLevel = musicDifficultLevel as! String
            self.musicDetailIntroduce = musicDetailIntroduce as! String
            self.musicStyle = musicStyle as! String
            self.musicMidiUrl = musicMidiUrl as! String
            self.fileName = fileName as! String
            self.musicAuthor = musicAuthor as! String
            self.musicPdfUrl = musicPdfUrl as! String
            self.musicMp3Url = musicMp3Url as! String
            self.musicDbUrl = musicDbUrl as! String
            self.是否收藏 = isCollect as! Int == 1
            /// 后台是大哥 不给我返回来就自己想办法吧
            self.musicname = DataControl.单例.通过id返回曲谱(scoreId: self.id).musicName
            if let arr = RelationMusic.创建relationMusic数组(arr: relationMusic as! [[String : AnyObject]]) {
                self.relationMusic = arr
            }else{
                return nil
            }
        }else{
            return nil
        }
    }
    
    func 获取midiDb数据(back: @escaping (Bool) -> Void)  {
   
        DataControl.单例.下载任务BackData(urlString: "http://121.41.128.49:9081/cs" + musicMidiUrl) { (succed, reason, midiData) in
            if succed {
                self.midiData = midiData
                
                DataControl.单例.下载任务BackString(urlString: "http://121.41.128.49:9081/cs" + self.musicDbUrl) { (succed, reason, string) in
                    if succed {
                        let nativeModel = NativeDBModel(path: string)
                        if nativeModel?.xmlMessage.count == 0 {
                            // 失败
                            back(false)
                        }else{
                            self.score = Score(nativeDBModel: nativeModel!)
                            let  backStr = self.score?.initialize()
                            if (backStr?.isEmpty)! {
                                back(true)
                            }else{
                                back(false)
                            }
                        }
                    }else{
                        back(false)
                    }
                }
            }else{
                back(false)
            }
        }
    }
    
    var 速度 = 120
    var 拍号分子 = 4
    var 拍号分母 = 4
    
    func 对比() {
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
                    break
                case kMusicEventType_MIDINoteMessage:
                    // 0x80~0x8f
                    // 0x90~0x9f
                    let msg = OCFunction.kMusicEventType_MIDINoteMessage(Data(bytes: data!, count: Int(size)))
                    //                    print(msg)
                    var endTimeInSecond: Double = 0
                    MusicSequenceGetSecondsForBeats(musicsquence!, timeInBeat + Float64(msg.duration), &endTimeInSecond);
                    break
                case kMusicEventType_MIDIChannelMessage:
              
                    break
                case kMusicEventType_MIDIRawData:
                    break
                case kMusicEventType_Parameter:
                    break
                case kMusicEventType_AUPreset:
                    break
                default:
                    print("未知")
                    break
                }
                MusicEventIteratorNextEvent(_iterator!);
                MusicEventIteratorHasCurrentEvent(_iterator!, &hasCurrentEvent);
            }while(hasCurrentEvent.boolValue)
            
        }
    }
}
