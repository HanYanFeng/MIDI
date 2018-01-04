//
//  MidiTransfer.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/10/17.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit

class MidiTransfer: NSObject {
    static  func transToMidiComment(data:Data ,back : ([UInt8]) -> Void)  {
        var str = "收到钢琴蓝牙 "
        for item  in data {
            str += "\(item) "
        }
        
        print(str)
        var 偏移 = 2
        // 第一个字节的第一位为1 第二位保留 后面6位为时间戳
        if data[0] & 0b10000000 == 0b10000000 {
            // 第二个字节 第一位为1 后面7位为时间戳
            if data[1] & 0b10000000 == 0b10000000 {
                var 命令头 : UInt8 = 0x0
                while true {
                    if data.count - 1 < 偏移 + 1 {
                        return
                    }
                    if (data[偏移] & 0b10000000 == 0b10000000) && (data[偏移 + 1] & 0b10000000 == 0b10000000) {
                        ///-------------包头 时间戳                时间戳
                        /// 第一种传输方式 0x80 0x80 0x90 0x21 0x35 0x80 0x90 0x22 0x35
                        if data.count - 1 < 偏移 + 3 {
                            return
                        }
                        back([data[偏移 + 1],data[偏移 + 2],data[偏移 + 3]])
                        偏移 += 4
                    }else if data[偏移] & 0b10000000 == 0b10000000 {
                        命令头 = data[偏移]
                        if data[偏移] >> 4 == 0x8 ||
                            data[偏移] >> 4 == 0x8 ||
                            data[偏移] >> 4 == 0x9 ||
                            data[偏移] >> 4 == 0xa ||
                            data[偏移] >> 4 == 0xb ||
                            data[偏移] >> 4 == 0xe {
                            if data.count - 1 < 偏移 + 2 {
                                return
                            }
                            back([data[偏移],data[偏移 + 1],data[偏移 + 2]])
                            偏移 += 3
                        }else if data[偏移] >> 4 == 0x8 ||
                            data[偏移] >> 4 == 0x8  {
                            if data.count - 1 < 偏移 + 1 {
                                return
                            }
                            back([data[偏移],data[偏移 + 1]])
                            偏移 += 2
                        }else{
                            print("怪事")
                            return
                        }
                    }else{
                        ///-------------包头 时间戳
                        /// 第二种传输方式 0x80 0x80 0x90 0x21 0x35 0x22 0x35
                        if 命令头 >> 4 == 0x8 ||
                            命令头 >> 4 == 0x8 ||
                            命令头 >> 4 == 0x9 ||
                            命令头 >> 4 == 0xa ||
                            命令头 >> 4 == 0xb ||
                            命令头 >> 4 == 0xe {
                            if data.count - 1 < 偏移 + 1 {
                                return
                            }
                            back([命令头,data[偏移],data[偏移 + 1]])
                            偏移 += 2
                        }else if 命令头 >> 4 == 0x8 ||
                            命令头 >> 4 == 0x8  {
                            if data.count - 1 < 偏移 {
                                return
                            }
                            back([命令头,data[偏移]])
                            偏移 += 1
                        }else{
                            print("怪事")
                            return
                        }
                        return
                    }
                }
            }else{
                print("怪事")
                return
            }
        }
    }
    static  func usbTransToMidiComment(data:Data ,back : ([UInt8]) -> Void)  {
        var 偏移 = 0
        while true {
            if data.count - 1 < 偏移 + 1 {
                return
            }
            if  data[偏移] >> 4 == 0x8 ||
                data[偏移] >> 4 == 0x9 ||
                data[偏移] >> 4 == 0xa ||
                data[偏移] >> 4 == 0xb ||
                data[偏移] >> 4 == 0xe
            {
                back([data[偏移],data[偏移 + 1],data[偏移 + 2]])
                偏移 += 3
            }else if data[偏移] >> 4 == 0xc ||
                data[偏移] >> 4 == 0xd
            {
                back([data[偏移],data[偏移 + 1]])
                偏移 += 2
            }else{
                print("奇怪了")
                return
            }
        }
    }
}
