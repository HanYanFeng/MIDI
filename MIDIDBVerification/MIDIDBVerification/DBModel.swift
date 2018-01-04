//
//  DBModel.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/5/17.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
class Note : NSObject{
    var 序号 : Int
    var tick : Int
    var x : Int
    var y : Int
    var pitch : Int
    var hand: HandMode
    override var description: String{
        get{
            return "序号:\(序号) tick:\(tick) x:\(x) y:\(y) pitch:\(pitch) 右手:\(hand)"
        }
    }
    init?(noteOnMessage:NoteOnMessage) {
        if let 序号 = noteOnMessage.id_num {
            self.序号 = 序号.intValue
        }else{return nil}
        if let tick = noteOnMessage.tick {
            self.tick = tick.intValue
        }else{return nil}
        if let x = noteOnMessage.x {
            self.x = x.intValue
        }else{return nil}
        if let y = noteOnMessage.y {
            self.y = y.intValue
        }else{return nil}
        if let pthch = noteOnMessage.value {
            self.pitch = pthch.intValue
        }else{return nil}
        if let 右手 = noteOnMessage.hand {
            hand = 右手 == "R" ? .righ : .lift
        }else{return nil}
    }
    func 开灯(back:(_ midi : Data,_ isLift : Bool)->Void) {
        let arr : [UInt8] = [hand == .righ ? 0x90 : 0x91,UInt8(self.pitch),1]
        back(Data(arr), hand == .lift)
    }
    func 关灯(back:(_ midi : Data,_ isLift : Bool)->Void) {
        let arr : [UInt8] = [hand == .righ ? 0x80 : 0x81,UInt8(self.pitch),1]
        back(Data(arr), hand == .lift)
    }
}

/// 同一时间下的音符
class SlotBlock: NSObject {
    var 序号 : Int
    var tick : Int
    var 所在的小节序号 : Int
    var 包含的音符 : [Note]
    var X : Int
    override var description: String{
        get{
            return "序号:\(序号) tick:\(tick) 所在的小节序号:\(所在的小节序号)" + 包含的音符.description
        }
    }
    func 删除掉相同的多余的音符(){
        var set : Array<Int> = Array()
        for (index,currentNote) in 包含的音符.enumerated() {
            if index + 1 < 包含的音符.count {
                for index2 in index + 1..<包含的音符.count  {
                    if currentNote.pitch == 包含的音符[index2].pitch {
                        set.append(index2)
                    }
                }
            }
        }
        if set.count != 0 {
            for index in set.reversed() {
                包含的音符.remove(at: index)
            }
        }
    }
    override init() {
        序号 = -1
        tick = -1
        所在的小节序号 = -1
        包含的音符 = []
        X = -1
    }
    convenience init?(slotBlock : SlotBlock , 模式 : Int ,示范 : Bool) {
        self.init()
        self.序号 = slotBlock.序号
        self.tick = slotBlock.tick
        self.所在的小节序号 = slotBlock.所在的小节序号
        self.X = slotBlock.X
        for note in slotBlock.包含的音符 {
            if 示范 {
                if 模式 == 2 && note.hand == .righ || 模式 == 1 && note.hand == .lift || 模式 == 0 {
                    self.包含的音符.append(note)
                }
            }else{
                if 模式 == 2 && note.hand == .lift || 模式 == 1 && note.hand == .righ || 模式 == 0 {
                    self.包含的音符.append(note)
                }
            }
        }
        if self.包含的音符.count == 0 {
            return nil
        }
    }
    func addpitch(noteOnMessage:NoteOnMessage) -> String?{
        var backStr : String? = ""
        if let tick = noteOnMessage.tick {
            self.tick = tick.intValue
        }else{
            backStr?.append("/n tick")
        }
        if let 序号 = noteOnMessage.id_num {
            self.序号 = 序号.intValue
        }else{
            backStr?.append("/n 序号")
        }
        if let 所在的小节序号 = noteOnMessage.mea_num {
            self.所在的小节序号 = 所在的小节序号.intValue
        }else{
            backStr?.append("/n 所在的小节序号")
        }
        if let note = Note(noteOnMessage: noteOnMessage) {
            if 包含的音符.isEmpty {
                X = note.x
            }
            if note.pitch == 0 {
                print("碰见同音连线的了")
            }else{
                包含的音符.append(note)
            }
        }else{
            backStr?.append("/n 包含的音符")
        }
        return backStr
    }
    func 开灯(back:(_ midi : Data,_ isLift : Bool)->Void) {
        for note in 包含的音符 {
            note.开灯(back: back)
        }
    }
    func 关灯(back:(_ midi : Data,_ isLift : Bool)->Void) {
        for note in 包含的音符 {
            note.关灯(back: back)
        }
    }
}

/// 储存小节的信息
class Measure : NSObject,NSMutableCopying {
    var 序号 : Int ///
    var tick : Int /// 开始时间
    //    var 结束tick : Int /// 结束时间（不考虑若起最后一小节）
    //    {
    //        return tick + 1024 / 几分音符为一拍 * 小节的拍数
    //    }
    var 是否是新的行 : Bool
    var 是否是新的一页 : Bool
    var X : Int
    var W : Int
    
    //    var 反复到第几小节 : Int // -1是无反复
    //    var 是否已反复 : Bool = false
    var bar_line : String? // 从db里解析出来的反复字段
    
    var 小节的拍数 : Int
    var 几分音符为一拍 : Int
    var 速度 : Int
    var 小节长度 : Int
//    var 下一小节序号 : Int
//    var 上一小节序号 : Int
//    var 下一行小节序号 : Int
//    var 上一行小节序号 : Int
//    var 行的序号 : Int
    var 开始时间 : Double
    var frame : CGRect!
    
    //    unsigned int backNoteIdx;//0-------------
    //    bool newPage;//是否是页开头的小节true
    //    unsigned int ending;//0
    //    double staffTopDistance[STAFF_NUM];//当前小节上下两个线谱的y值[0] = 298, [1] = 423)-------------
    var measureHeight0 : Int
    var measureHeight1 : Int
    var 同时音符 : [SlotBlock]
    
    
    
    override var description: String{
        get{
            //            return "序号:\(序号) 行的序号:\(行的序号) 上一行小节序号:\(上一行小节序号) 上一小节；\(上一小节序号) tick:\(tick)"
            //            return "序号:\(序号) tick:\(tick) X:\(X) W:\(W) 反复到第几小节:\(反复到第几小节) 小节的拍数:\(小节的拍数) 几分音符为一拍:\(几分音符为一拍) 速度:\(速度) measureHeight0\(measureHeight0) measureHeight1:\(measureHeight1) 上节：\(上一小节序号) 下节：\(下一小节序号) 上行：\(上一行小节序号) 下行：\(下一行小节序号)" + 同时音符.description
            //            return "同时音符:\(同时音符.count)"
            return "速度：\(速度)tick:\(tick) :\(几分音符为一拍) :\(小节的拍数) \(开始时间)"
        }
    }
    func mutableCopy(with zone: NSZone? = nil) -> Any {
        let measure = Measure(measure: self, 手模式: 0)
        return measure
    }
    override init() {
        序号 = -1
        tick = -1
        是否是新的行 = false
        是否是新的一页 = false
        X = -1
        W = -1
        //        反复到第几小节 = -1
        小节的拍数 = -1
        几分音符为一拍 = -1
        速度 = -1
        measureHeight0 = -1
        measureHeight1 = -1
        同时音符 = []
//        行的序号 = -1
        开始时间 = -1
        小节长度 = -1
    }
    /// 1 为右手
    convenience init(measure : Measure ,手模式 : Int) {
        self.init()
        序号 = measure.序号
        tick = measure.tick
        是否是新的行 = measure.是否是新的行
        是否是新的一页 = measure.是否是新的一页
        X = measure.X
        W = measure.W
        //        反复到第几小节 = measure.反复到第几小节
        bar_line = measure.bar_line
        小节的拍数 = measure.小节的拍数
        几分音符为一拍 = measure.几分音符为一拍
        速度 = measure.速度
        measureHeight0 = measure.measureHeight0
        measureHeight1 = measure.measureHeight1
        同时音符 = []
        for sloat  in measure.同时音符 {
            if let sl = SlotBlock(slotBlock: sloat, 模式: 手模式, 示范: false) {
                同时音符.append(sl)
            }
        }
//        行的序号 = measure.行的序号
        开始时间 = measure.开始时间
        小节长度 = measure.小节长度
    }
    
    func addpitch(noteOnMessage:NoteOnMessage) -> String?{
        var slotBlock : SlotBlock? = nil
        for item in 同时音符 {
            if item.tick == noteOnMessage.tick.intValue{
                slotBlock = item
            }
        }
        if slotBlock == nil {
            slotBlock = SlotBlock()
            同时音符.append(slotBlock!)
        }
        let str = slotBlock?.addpitch(noteOnMessage: noteOnMessage)
        同时音符.sort { (slotBlock1, slotBlock2) -> Bool in
            return slotBlock1.tick <  slotBlock2.tick
        }
        return str
    }
}


/// 手模式
///
/// - lift: 左手模式
/// - righ: 右手模式
/// - both: 双手模式
enum HandMode {
    case lift
    case righ
    case both
}

/// 曲谱播放模式
enum ScorePlayType {
    /// 示范模式
    case example
    /// 练习模式一
    case practiceOne
    /// 练习模式2
    case practiceTow
}

/// 提示事件包
class RemindeActionBag {
    
    let tick: Int
    
    var remindeAction: [RemindeAction] {
        didSet{
//            sendCodeBag = nil
        }
    }
    
//    private var sendCodeBag: [[UInt8]]?
    
    init(tickf: Int) {
        tick = tickf
        remindeAction = []
    }
    
    func getSendCodeBag(handMode: HandMode) -> [[UInt8]] {
//        if nil != sendCodeBag && handMode == self.handMode {
//            return sendCodeBag!
//        }else{
//
//        }
        var sendCodeBag: [[UInt8]] = []
        for remindeActio in remindeAction {
            if let dd = remindeActio.getSendCode(handMode: handMode) {
                sendCodeBag.append(dd)
            }
        }
        return sendCodeBag
    }
}

/// 提示事件包
struct RemindeAction {
    
    let pitch: Int
    
    let open: Bool
    
    let handMode: HandMode
    
    func getSendCode(handMode: HandMode) -> [UInt8]? {
        if handMode == .both || handMode == self.handMode {
            return [0xB0, open ? 0x69: 0x68, UInt8(pitch)]
        }else{
            return nil
        }
    }
}

class AheadRemindLightManager: NSObject {
//    private var 弹对前进的预先提示事件: [RemindeActionBag] = []
//    private var 练习示范模式的预先提示事件: [RemindeActionBag] = []
    
    /// 标记当前的命令包是否被发送出去
    private var isSend: Bool = false
    
    private var lastTick: Int?
    private var currentBag: RemindeActionBag?
    private var 迭代器: IndexingIterator<[RemindeActionBag]>?
    private var remindeActionArr: [RemindeActionBag] = []

//    func 设置模式播放模式(scorePlayType: ScorePlayType) {
//        switch scorePlayType {
//        case .example:
//            remindeActionArr = 练习示范模式的预先提示事件
//            break
//        case .practiceOne:
//            remindeActionArr = 练习示范模式的预先提示事件
//            break
//        case .practiceTow:
////            remindeActionArr = 弹对前进的预先提示事件
//            break
//        }
//    }
//
    func 初始化事件(score: Score) {
        self.remindeActionArr = []
        
        func getCurrentRemindeActionBag(tick: Int) -> RemindeActionBag {
            var currentRemindeActionBag : RemindeActionBag?
            var 向前查找的次数: Int = 10
            for remindeActionBag in self.remindeActionArr.reversed() {
                向前查找的次数 -= 1
                if remindeActionBag.tick == tick {
                    currentRemindeActionBag = remindeActionBag
                    break
                }else if 向前查找的次数 == 0 {
                    break
                }
            }
            if currentRemindeActionBag == nil {
                currentRemindeActionBag = RemindeActionBag(tickf: tick)
                self.remindeActionArr.append(currentRemindeActionBag!)
            }
            return currentRemindeActionBag!
        }
        
        for measure in score.小节信息Array {
            for slotBlock in measure.同时音符 {
                let openRemindeActionBag = getCurrentRemindeActionBag(tick: slotBlock.tick - 1024 / measure.几分音符为一拍)
                let closeRemindeActionBag = getCurrentRemindeActionBag(tick: slotBlock.tick)
                for note in slotBlock.包含的音符 {
                    closeRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: false, handMode: note.hand))
                    openRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: true, handMode: note.hand))
                }
            }
        }
        self.remindeActionArr.sort { (item1, item2) -> Bool in
            return item1.tick < item2.tick
        }
        /// 处理 亮 亮 灭 就灭灯的情况
        var 桶 = [0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0,
                   0,0,0,0,0,0,0,0,0,0]
        remindeActionArr = self.remindeActionArr.map(){
            let back = $0.remindeAction.filter({ (remandActio) -> Bool in
                if remandActio.open {
                    桶[remandActio.pitch - 21] += 1
                    return 桶[remandActio.pitch - 21] == 1
                }else{
                    桶[remandActio.pitch - 21] -= 1
                    return 桶[remandActio.pitch - 21] == 0
                }
            })
            $0.remindeAction = back
            return $0
        }
//
//        /// 处理弹对前进的预先提示灯的数据
//        self.弹对前进的预先提示事件 = []
//        var firstSlotBlock: SlotBlock?
//        var secondSlotBlock: SlotBlock?
//        for measure in score.小节信息Array {
//            for slotBlock in measure.同时音符 {
//                if firstSlotBlock == nil {
//                    firstSlotBlock = slotBlock
//                }else if secondSlotBlock == nil {
//                    secondSlotBlock = firstSlotBlock
//                    firstSlotBlock = slotBlock
//                }else{
//                    let currentRemindeActionBag = RemindeActionBag(tickf: (secondSlotBlock?.tick)!)
//                    for note in firstSlotBlock!.包含的音符 {
//                        currentRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: true, handMode: note.hand))
//                    }
//
//                    for note in secondSlotBlock!.包含的音符 {
//                        currentRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: false, handMode: note.hand))
//                    }
//                    secondSlotBlock = firstSlotBlock
//                    firstSlotBlock = slotBlock
//                    self.弹对前进的预先提示事件.append(currentRemindeActionBag)
//                }
//            }
//        }
//        let currentRemindeActionBag = RemindeActionBag(tickf: (secondSlotBlock?.tick)!)
//        for note in secondSlotBlock!.包含的音符 {
//            currentRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: false, handMode: note.hand))
//        }
//        self.弹对前进的预先提示事件.append(currentRemindeActionBag)
    }
    
    func getEventPagWithTick(tick: Int) -> RemindeActionBag? {
        if lastTick == nil || lastTick! < tick {
            lastTick = tick
        }
        if lastTick! > tick {
            self.currentBag = nil
            self.迭代器 = nil
            isSend = false
            lastTick = tick
            return self.getEventPagWithTick(tick:tick)
        }else if let currentBag = currentBag  {
            if tick <= currentBag.tick - 32 {
               return nil
            }else if tick <= currentBag.tick + 32 {
                if !isSend {
                    isSend = true
                    return currentBag
                }else{
                    return nil
                }
            }else{
                self.currentBag = 迭代器?.next()
                if self.currentBag == nil {
                    return nil
                }else{
                    isSend = false
                    return self.getEventPagWithTick(tick:tick)
                }
            }
        }else if nil != 迭代器 {
            currentBag = 迭代器?.next()
            if currentBag == nil {
                return nil
            }else{
                return self.getEventPagWithTick(tick:tick)
            }
        }else{
            迭代器 = remindeActionArr.makeIterator()
            return self.getEventPagWithTick(tick:tick)
        }
    }
}

/// 储存整个曲谱的信息
class Score : NSObject {
    var 曲谱PDF宽度 : Int
    var 曲谱PDF高度 : Int
    var 曲谱的总tick : Int
    var 是否若起 : Bool
    var 五线谱的高 : Float
    var 小节数量 : Int
    var 音符组数量 : Int
    var 小节信息Array : [Measure]
    
//    var remindeActionArr: [RemindeActionBag]
    
    var 提前提示灯管理者: AheadRemindLightManager
    
    var faluseReason : String

    override var description: String{
        get{
            return "曲谱PDF宽度:\(曲谱PDF宽度):曲谱PDF高度:\(曲谱PDF高度) 曲谱的总tick:\(曲谱的总tick) 是否若起:\(是否若起) 五线谱的高:\(五线谱的高) 小节数量:\(小节数量) 音符组数量:\(音符组数量)"
        }
    }
    ///在 ScorePlayVCPdfView 中调用
    func 初始化小节的Frame(imageViewWidth : CGFloat,zoomValue : CGFloat) {
        let scale2 = imageViewWidth / CGFloat(self.曲谱PDF宽度)
        for currentMeasure in self.小节信息Array {
            let x = CGFloat(currentMeasure.X) * scale2
            let _scoreSize =  CGFloat(self.五线谱的高) * zoomValue
            let y = CGFloat(currentMeasure.measureHeight0) * scale2 - _scoreSize / 2
            let w = CGFloat(currentMeasure.W) * scale2
            let h = _scoreSize + CGFloat(currentMeasure.measureHeight1 - currentMeasure.measureHeight0) * scale2
            currentMeasure.frame = CGRect(x: x, y: y, width: w, height: h)
        }
    }
    var nativeDBModel : NativeDBModel!
    init(nativeDBModel:NativeDBModel) {
        self.是否若起 = false
        曲谱PDF宽度 = -1
        曲谱PDF高度 = -1
        曲谱的总tick = -1
        小节数量 = -1
        音符组数量 = -1
        五线谱的高 = -1
        小节信息Array = []
        //            有反复的小节 = []
        faluseReason = ""
        self.nativeDBModel = nativeDBModel
//        remindeActionArr = []
        提前提示灯管理者 = AheadRemindLightManager()
    }
    /// 1 右手
    init(score : Score ,手模式 : Int) {
        self.是否若起 = score.是否若起
        曲谱PDF宽度 = score.曲谱PDF宽度
        曲谱PDF高度 = score.曲谱PDF高度
        曲谱的总tick = score.曲谱的总tick
        小节数量 = score.小节数量
        音符组数量 = score.音符组数量
        五线谱的高 = score.五线谱的高
        //        有反复的小节 = score.有反复的小节 /// 没什么用
        小节信息Array = []
        for meas in score.小节信息Array {
            let ms = Measure(measure: meas, 手模式: 手模式)
            小节信息Array.append(ms)
        }
        faluseReason = ""
        self.nativeDBModel = score.nativeDBModel
//        self.remindeActionArr = score.remindeActionArr
        self.提前提示灯管理者 = score.提前提示灯管理者
    }
    public  func initialize() -> String?{
        self.jieXinativeDBModelxmlMessage()
        self.jieXinativeDBModelnoteOnMessage()
        if self.faluseReason.isEmpty {
            解析后处理()
        }
        return self.faluseReason
    }
    func 解析后处理(){
        var index : Int = 0
        var 序号 : Int = 0
        for measure in self.小节信息Array {
            measure.序号 = 序号
            序号 += 1
        }
        for measure in self.小节信息Array {
            var ind : Int = 0
            while measure.几分音符为一拍 == -1 || measure.速度 == -1{
                if index == 0 {
                    ind += 1
                    if measure.几分音符为一拍 == -1 {
                        measure.几分音符为一拍 = self.小节信息Array[index + ind].几分音符为一拍
                    }
                    if measure.小节的拍数 == -1 {
                        measure.小节的拍数 = self.小节信息Array[index + ind].小节的拍数
                    }
                    if measure.速度 == -1 {
                        measure.速度 = self.小节信息Array[index + ind].速度
                    }
                    measure.measureHeight0 = self.小节信息Array[index + ind].measureHeight0
                    measure.measureHeight1 = self.小节信息Array[index + ind].measureHeight1
                    if !self.是否若起 {
                        measure.X = self.小节信息Array[index + ind].X
                        measure.W = self.小节信息Array[index + ind].W
                        measure.同时音符.removeAll()
                    }else{
                        
                    }
                }else{
                    ind -= 1
                    if measure.几分音符为一拍 == -1 {
                        measure.几分音符为一拍 = self.小节信息Array[index + ind].几分音符为一拍
                    }
                    if measure.小节的拍数 == -1 {
                        measure.小节的拍数 = self.小节信息Array[index + ind].小节的拍数
                    }
                    if measure.速度 == -1 {
                        measure.速度 = self.小节信息Array[index + ind].速度
                    }
                }
            }
            index += 1
        }
        self.处理反复()
        
//        index = 0
//        for measure in self.小节信息Array {
//
//            if measure.是否是新的行{
//                if self.是否若起 && measure.序号 == 0 || !self.是否若起 && measure.序号 == 1{
//                }else{
//                    行号 += 1
//                }
//            }
////            measure.行的序号 = 行号
//            /// 下一小节序号
//            /// 上一小节序号
////            if index != 小节信息ArrayCount && 小节信息ArrayCount != 0 {
////                if index + 1 <= (self.小节信息Array.last?.序号)! {
////                    measure.下一小节序号 = index + 1
////                }
////                if index != 0 {
////                    measure.上一小节序号 = index - 1
////                }
////            }
//            index += 1
//        }
        ///下一行小节序号
//        for meas in self.小节信息Array {
//            var next : Int = 0
//            while next + meas.序号 != self.小节信息Array.count {
//                let  nextLine = self.小节信息Array[meas.序号 + next]
//                if nextLine.行的序号 - meas.行的序号 == 1 {
//                    meas.下一行小节序号 = nextLine.序号
//                    break
//                }
//                next += 1
//            }
//        }
//        /// 上一行小节序号
//        for measure in self.小节信息Array {
//            if measure.行的序号 == 0 {
//                continue
//            }
//            var last = 1
//            while true {
//                let  lastLine = self.小节信息Array[measure.序号 - last]
//                if measure.行的序号 - lastLine.行的序号 ==  1 {
//                    measure.上一行小节序号 = lastLine.序号
//                    break
//                }
//                last += 1
//            }
//        }
        ///曲谱的总tick
        if self.是否若起 {
            self.小节信息Array.remove(at: self.小节信息Array.count - 1)
            let addtick = self.小节信息Array.first?.同时音符.first?.tick
            self.曲谱的总tick = (self.小节信息Array.last?.tick)! + (addtick ?? 0)
        }else{
            self.小节信息Array[0].tick = -( 1024 / self.小节信息Array[0].几分音符为一拍 * self.小节信息Array[0].小节的拍数)
            let masure = self.小节信息Array.last!
            self.曲谱的总tick = masure.tick + 1024 / masure.几分音符为一拍 * masure.小节的拍数
        }
        
//        /// 处理小节开始时间
//        let 数组长度 = self.小节信息Array.count - 1
//        for index  in 0...数组长度 {
//            let measureeeeee = self.小节信息Array[index]
//            if measureeeeee.tick < 0  {
//                measureeeeee.开始时间 = 计算一个tick要的时间(小节的速度: measureeeeee.速度) * 1024 / Double(measureeeeee.几分音符为一拍) * Double(measureeeeee.小节的拍数) * -1
//            }else{
//                if self.是否若起 && index == 0{
//                    measureeeeee.开始时间 = 0
//                }else{
//                    let lastMeasure = self.小节信息Array[index - 1]
//                    measureeeeee.开始时间 = lastMeasure.开始时间 + 计算一个tick要的时间(小节的速度: lastMeasure.速度) * 1024 / Double(lastMeasure.几分音符为一拍) * Double(lastMeasure.小节的拍数)
//                }
//            }
//        }
        /// 处理同一音包下有相同pich值的音符去掉多余的
        for meas in self.小节信息Array {
            for slotBlock in meas.同时音符 {
                slotBlock.删除掉相同的多余的音符()
            }
//            print(meas.开始时间)
        }
        /// 处理小节长度
        self.小节信息Array = self.小节信息Array.map(){
            $0.小节长度 = 1024 / $0.几分音符为一拍 * $0.小节的拍数
            return $0
        }
        
        self.提前提示灯管理者.初始化事件(score: self)
    }
    
//    func 处理提示灯数据() {
//        self.提前提示灯管理者.练习示范模式的预先提示事件 = []
//
//        func getCurrentRemindeActionBag(tick: Int) -> RemindeActionBag {
//            var currentRemindeActionBag : RemindeActionBag?
//            var 向前查找的次数: Int = 10
//            for remindeActionBag in self.提前提示灯管理者.练习示范模式的预先提示事件.reversed() {
//                向前查找的次数 -= 1
//                if remindeActionBag.tick == tick {
//                    currentRemindeActionBag = remindeActionBag
//                    break
//                }else if 向前查找的次数 == 0 {
//                    break
//                }
//            }
//            if currentRemindeActionBag == nil {
//                currentRemindeActionBag = RemindeActionBag(tickf: tick)
//                self.提前提示灯管理者.练习示范模式的预先提示事件.append(currentRemindeActionBag!)
//            }
//            return currentRemindeActionBag!
//        }
//
//        for measure in self.小节信息Array {
//            for slotBlock in measure.同时音符 {
//                let openRemindeActionBag = getCurrentRemindeActionBag(tick: slotBlock.tick - 1024 / measure.几分音符为一拍)
//                let closeRemindeActionBag = getCurrentRemindeActionBag(tick: slotBlock.tick)
//                for note in slotBlock.包含的音符 {
//                    closeRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: false, handMode: note.hand))
//                    openRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: true, handMode: note.hand))
//                }
//            }
//        }
//        self.提前提示灯管理者.练习示范模式的预先提示事件.sort { (item1, item2) -> Bool in
//            return item1.tick < item2.tick
//        }
//
//        /// 处理弹对前进的预先提示灯的数据
//        self.提前提示灯管理者.弹对前进的预先提示事件 = []
//        var firstSlotBlock: SlotBlock?
//        var secondSlotBlock: SlotBlock?
//        for measure in self.小节信息Array {
//            for slotBlock in measure.同时音符 {
//                if firstSlotBlock == nil {
//                    firstSlotBlock = slotBlock
//                }else if secondSlotBlock == nil {
//                    secondSlotBlock = firstSlotBlock
//                    firstSlotBlock = slotBlock
//                }else{
//                    let currentRemindeActionBag = RemindeActionBag(tickf: (secondSlotBlock?.tick)!)
//                    for note in firstSlotBlock!.包含的音符 {
//                        currentRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: true, handMode: note.hand))
//                    }
//
//                    for note in secondSlotBlock!.包含的音符 {
//                        currentRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: false, handMode: note.hand))
//                    }
//                    secondSlotBlock = firstSlotBlock
//                    firstSlotBlock = slotBlock
//                    self.提前提示灯管理者.弹对前进的预先提示事件.append(currentRemindeActionBag)
//                }
//            }
//        }
//        let currentRemindeActionBag = RemindeActionBag(tickf: (secondSlotBlock?.tick)!)
//        for note in secondSlotBlock!.包含的音符 {
//            currentRemindeActionBag.remindeAction.append(RemindeAction(pitch: note.pitch, open: false, handMode: note.hand))
//        }
//        self.提前提示灯管理者.弹对前进的预先提示事件.append(currentRemindeActionBag)
//    }
    
    func 处理反复(){
        
        var 序号 : Int = 0
        var 反复的位置 : Int = 0
        var 新的小节信息 : [Measure] = []
        for mes in self.小节信息Array {
            
            新的小节信息.append(self.处理新的小节到新的数组里 (数组: 新的小节信息, mes: mes))
            if mes.bar_line != nil && mes.bar_line == "backward" {
                反复的位置 = 序号
                var 找到前面的 = false
                var 结束位置 : Int = 0
                var 当前位置 : Int = 反复的位置
                if !self.是否若起 {
                    结束位置 = 1
                }
                while !找到前面的 && (当前位置 >= 结束位置){
                    let mes1 = self.小节信息Array[当前位置]
                    if mes1.bar_line != nil && mes1.bar_line == "forward" {
                        找到前面的 = true
                        mes1.bar_line = nil
                        for 哎取什么名字呢 in 当前位置...反复的位置 {
                            let 新创见的小节 = self.小节信息Array[哎取什么名字呢].mutableCopy() as! Measure
                            新的小节信息.append(self.处理新的小节到新的数组里(数组: 新的小节信息, mes: 新创见的小节))
                        }
                    }
                    当前位置 -= 1
                }
                if !找到前面的 {
                    if self.是否若起 {
                        当前位置 = 0
                    }else{
                        当前位置 = 1
                    }
                    for 哎取什么名字呢 in 当前位置...反复的位置 {
                        let 新创见的小节 = self.小节信息Array[哎取什么名字呢].mutableCopy() as! Measure
                        新的小节信息.append(self.处理新的小节到新的数组里(数组: 新的小节信息, mes: 新创见的小节))
                    }
                }
                mes.bar_line = nil
            }
            序号 += 1
        }
        self.小节信息Array = 新的小节信息
    }
    func 处理新的小节到新的数组里(数组 : [Measure] ,mes : Measure) -> Measure{
        let mes之前的Tick = mes.tick
        if  数组.count != 0 {
            let 上一小节 = 数组.last!
            mes.tick = 上一小节.tick + 1024 / 上一小节.几分音符为一拍 * 上一小节.小节的拍数
            mes.序号 = 数组.count
        }else{
            mes.序号 = 0
            if self.是否若起 {
                mes.tick = 0
            }else{
                mes.tick = -(1024 / mes.几分音符为一拍 * mes.小节的拍数)
            }
        }
        if mes.同时音符.count != 0 {
            let 差 = mes之前的Tick - mes.tick
            if 差 != 0 {
                for slot in mes.同时音符 {
                    slot.tick -= 差
                    slot.所在的小节序号 = mes.序号
                }
            }
        }
        return mes
    }
    
    //MARK:解析音符信息
    func jieXinativeDBModelnoteOnMessage(){
        for noteOnMessage in self.nativeDBModel.noteOnMessage {
            if noteOnMessage.name == "pitch" {
                self.addpitch(noteOnMessage: noteOnMessage)
            }else if noteOnMessage.name == "slot-block-amount" {
                
            }
        }
    }
    func addpitch(noteOnMessage:NoteOnMessage) {
        if let str = self.小节信息Array[noteOnMessage.mea_num.intValue].addpitch(noteOnMessage: noteOnMessage) {
            self.faluseReason.append(str)
        }
    }
    //MARK:解析小节信息
    func jieXinativeDBModelxmlMessage(){
        for smlMessage in self.nativeDBModel.xmlMessage {
            
            if smlMessage.name == "page-width" {
                self.曲谱PDF宽度 = Int(smlMessage.status)!
            }else if smlMessage.name == "page-height" {
                self.曲谱PDF高度 = Int(smlMessage.status)!
            }else if smlMessage.name == "measure-width" {
                if smlMessage.measure_num == 0{
                    self.是否若起 = true
                }
                self.addmeasure_width(xmlMessage: smlMessage)
            }else if smlMessage.name == "beat-type" {
                self.addBeatType(xmlMessage: smlMessage)
            }else if smlMessage.name == "beats" {
                self.addBeats(xmlMessage: smlMessage)
            }else if smlMessage.name == "font-size" {
                if let 五线谱的高 = Float(smlMessage.status) {
                    self.五线谱的高 = 五线谱的高
                }else{
                    self.faluseReason.append("/n缺 五线谱的高")
                }
            }else if smlMessage.name == "measure-height" {
                self.addmeasure_height(xmlMessage: smlMessage)
            }else if smlMessage.name == "measure-left-x" {
                self.addmeasure_left_x(xmlMessage: smlMessage)
            }else if smlMessage.name == "new-page—measure-no" {
                self.addnew_page_measure_no(xmlMessage: smlMessage)
            }else if smlMessage.name == "per-minute" {
                self.addper_minute(xmlMessage: smlMessage)
            }else if smlMessage.name == "score-partwise" {
            }else if smlMessage.name == "sign" {
            }else if smlMessage.name == "slot-amount" {
                self.addslot_amount(xmlMessage: smlMessage)
            }else if smlMessage.name == "staff-amount" {
            }else if smlMessage.name == "staff-distance" {
            }else if smlMessage.name == "step" {
            }else if smlMessage.name == "system-distance" {
            }else if smlMessage.name == "system-left-margin" {
            }else if smlMessage.name == "tick-for-measure" {
                self.addtick_for_measure(xmlMessage: smlMessage)
            }else if smlMessage.name == "top-system-distance" {
            }else if smlMessage.name == "voice-amount" {
            }else if smlMessage.name == "absolute-tick-in-meausure-note-off" {
            }else if smlMessage.name == "alter" {
            }else if smlMessage.name == "octave" {
            }else if smlMessage.name == "page-left-margin" {
            }else if smlMessage.name == "page-top-margin" {
            }else if smlMessage.name == "instrument-amount" {
            }else if smlMessage.name == "line" {
            }else if smlMessage.name == "line-width-staff" {
            }else if smlMessage.name == "measure-amount" {
            }else if smlMessage.name == "default-x" {
            }else if smlMessage.name == "default-y" {
            }else if smlMessage.name == "duration" {
            }else if smlMessage.name == "new-row—measure-no" {
                self.addnew_row_measure_no(xmlMessage: smlMessage)
            }else if smlMessage.name == "absolute-tick-in-meausure-note-on"{
            }else if smlMessage.name == "words" {
            }else if smlMessage.name == "grace-step" {
            }else if smlMessage.name == "grace-alter" {
            }else if smlMessage.name == "grace-octave" {
            }else if smlMessage.name == "tie-start" { //月亮河
            }else if smlMessage.name == "tie-stop" { //月亮河
            }else if smlMessage.name == "measure-0-existence" {
            }else if smlMessage.name == "octave-shift" { // 圆舞曲
            }else if smlMessage.name == "bar-line"{
                self.addbar_line(xmlMessage: smlMessage)
            }else{
                print("未知：\(smlMessage.name)")
            }
        }
    }
    
    func addMeasureTo(index : Int) {
        if self.小节信息Array.count - 1 < index {
            //            let measure = Measure()
            //            measure.序号 = self.小节信息Array.count
            self.小节信息Array.append(Measure())
            self.addMeasureTo(index: index)
        }
    }
    func addmeasure_width(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if let W = Int(xmlMessage.status) {
            self.小节信息Array[xmlMessage.measure_num.intValue].W = W
        }else{
            self.faluseReason.append("/n measure.W")
        }
    }
    func addBeatType(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if let 几分音符为一拍 =  Int(xmlMessage.status){
            self.小节信息Array[xmlMessage.measure_num.intValue].几分音符为一拍 = 几分音符为一拍
        }else{
            self.faluseReason.append("/n 几分音符为一拍")
        }
    }
    func addBeats(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if let 小节的拍数 =  Int(xmlMessage.status){
            self.小节信息Array[xmlMessage.measure_num.intValue].小节的拍数 = 小节的拍数
        }else{
            self.faluseReason.append("/n 小节的拍数")
        }
    }
    
    func addmeasure_left_x(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if let x = Int(xmlMessage.status) {
            self.小节信息Array[xmlMessage.measure_num.intValue].X = x
        }else{
            self.faluseReason.append("/n measure.X")
        }
    }
    func addper_minute(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if let 速度 =  Int(xmlMessage.status){
            self.小节信息Array[xmlMessage.measure_num.intValue].速度 = 速度
        }else {
            self.faluseReason.append("/n measure.速度")
        }
    }
    func addmeasure_height(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if xmlMessage.staff_num == 1 {
            if let measureHeight0 =  Int(xmlMessage.status){
                self.小节信息Array[xmlMessage.measure_num.intValue].measureHeight0 = measureHeight0
            }else {
                self.faluseReason.append("/n measureHeight0")
            }
        }else if xmlMessage.staff_num == 2 {
            if let measureHeight1 =  Int(xmlMessage.status){
                self.小节信息Array[xmlMessage.measure_num.intValue].measureHeight1 = measureHeight1
            }else {
                self.faluseReason.append("/n measureHeight1")
            }
        }
    }
    
    func addnew_page_measure_no(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if xmlMessage.status == "YES" {
            self.小节信息Array[xmlMessage.measure_num.intValue].是否是新的一页 = true
        }else {
            self.小节信息Array[xmlMessage.measure_num.intValue].是否是新的一页 = false
        }
    }
    func addnew_row_measure_no(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if xmlMessage.status == "YES" {
            self.小节信息Array[xmlMessage.measure_num.intValue].是否是新的行 = true
        }else {
            self.小节信息Array[xmlMessage.measure_num.intValue].是否是新的行 = false
        }
        
    }
    func addtick_for_measure(xmlMessage:XmlMessage){
        self.addMeasureTo(index: xmlMessage.measure_num.intValue)
        if let tick = Int(xmlMessage.status) {
            self.小节信息Array[xmlMessage.measure_num.intValue].tick = tick
        }else{
            self.faluseReason.append("/n measure.tick")
        }
    }
    func addbar_line(xmlMessage:XmlMessage){
        let index = xmlMessage.measure_num.intValue
        self.addMeasureTo(index: index)
        let measure = self.小节信息Array[index]
        measure.bar_line = String(xmlMessage.status)
        //        self.有反复的小节.append(measure)
    }
    func addslot_amount(xmlMessage:XmlMessage) {
        self.音符组数量 = Int(xmlMessage.status)!
    }
    
    
}
//absolute-tick-in-meausure-note-off
//alter
//beat-type
//beats
//default-x
//default-y
//duration
//font-size
//instrument-amount
//line
//line-width-staff
///measure-amount
//measure-height
//measure-left-x
//measure-width
//new-page—measure-no
//octave
//page-height
//page-left-margin
//page-top-margin
//page-width
//per-minute
//score-partwise
//sign
//slot-amount
//staff-amount
//staff-distance
//step
//system-distance
//system-left-margin
//tick-for-measure
//top-system-distance
//voice-amount

//slot-block-amount
//pitch
//window-open
