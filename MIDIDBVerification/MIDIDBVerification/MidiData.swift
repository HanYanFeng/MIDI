//
//  ViewController.swift
//  MIdi-parsing
//
//  Created by 韩艳锋 on 2017/12/6.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import AudioToolbox

class MidiData: NSObject {
    
    
    var measures: [MidiMeasure] = []
    
    var 速度事件: [(拍数: Int, 速度: Int)] = []
    var 拍号事件: [(拍数: Int, 分子: Int, 分母: Int)] = []
    var 音符事件: [(拍数: Int, ptch: Int, track: Int)] = []
    
    func 更改速度(拍数: Int, 速度: Int) {
        速度事件.append((拍数: 拍数, 速度: 速度))
    }

    func 变拍号(拍数: Int, 分子: Int, 分母: Int)  {
        拍号事件.append((拍数: 拍数, 分子: 分子, 分母: 分母))
    }
    
    func 加音符(拍数: Int, ptch: Int, track: Int) {
        音符事件.append((拍数: 拍数, ptch: ptch, track: track))
    }
    
    var 速度: Int = 120
    var 分子: Int = 4
    var 分母: Int = 4
    
    func 生产() {
        var currentMeasure: MidiMeasure = MidiMeasure()
        for index in 0...音符事件.last!.拍数 {
            if let 拍号事件s = 拍号事件.first {
                if 拍号事件s.拍数 == index {
                    self.分母 = 拍号事件s.分母
                    self.分子 = 拍号事件s.分子
                }
            }
            
            if let 速度事件s = 速度事件.first {
                
            }
        }
    }
}

class MidiMeasure: NSObject {
    
    var beats: [MidiSlotBlock] = []
    var 速度: Int = 120
    var 分子: Int = 4
    var 分母: Int = 4
    var 启始拍号: Int = 0
}

class MidiSlotBlock: NSObject {
    var note: [ModiNote] = []
    var 拍号: Int = 0
}

class ModiNote: NSObject {
    var ptch: Int = 0
    var 右手: Bool = true
}
