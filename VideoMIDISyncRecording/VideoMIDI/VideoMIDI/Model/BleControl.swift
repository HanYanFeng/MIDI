//
//  BleControl.swift
//  琴加
//
//  Created by 韩艳锋 on 2017/6/5.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BleControldelegate : NSObjectProtocol {
    func 展示搜索到的蓝牙(peripheral: [CBPeripheral])
}
protocol BleControlProtocol : NSObjectProtocol  {
    func 开始查找蓝牙设备() -> String? //返回空则可以正常查找
    func 停止搜索()
    func 连接设备(peripheral : CBPeripheral)  -> String?
    func 断开设备(peripheral : CBPeripheral)
    var delegate : BleControldelegate? { get set}
//    var receiveDelegate : BleControlReceiveDatadelegate?{get set}

    var connect : Bool{ get}
    func sendData(data: Data)
}

let serviceid = CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")
let characteristicid1 = CBUUID(string: "7772E5DB-3868-4112-A1A9-F2669D106BF3")
let bleconnectchange = "BleControlbleconnectchange"
class BleControl: NSObject,CBCentralManagerDelegate ,CBPeripheralDelegate ,BleControlProtocol{
    var centerManager : CBCentralManager!
    var connectPeripheral : CBPeripheral?
    var lastPeripheral : CBPeripheral?
    var peripherals : [CBPeripheral]?
    weak var delegate : BleControldelegate?
//    weak var receiveDelegate : BleControlReceiveDatadelegate?
    
    static var shard : BleControlProtocol = BleControl()
    var 任务队列 : [Data] = []
    override init() {
        super.init()
        centerManager  = CBCentralManager(delegate: self, queue: nil)
        peripherals = []
    }
    var connect : Bool {
        get {
            if let connectPeripheral = connectPeripheral {
                if connectPeripheral.state == .connected {
                    return true
                }else{
                    return false
                }
            }else{
                return false
            }
        }
        set(newValue){
            NotificationCenter.default.post(name: Notification.Name(rawValue:bleconnectchange), object: false)
        }
    }
    func centralManagerDidUpdateState(_ central: CBCentralManager){
        if centerManager.state != .poweredOn {
        }
    }

    func 开始查找蓝牙设备() -> String?{
        if centerManager.state != .poweredOn {
            return "蓝牙不可用，请打开蓝牙"
        }else{
            peripherals = []
            if self.connectPeripheral != nil {
                peripherals?.append(self.connectPeripheral!)
            }
            centerManager.scanForPeripherals(withServices: [serviceid], options: nil)
            self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
            return nil
        }
    }
    func 停止搜索()
    {
        centerManager.stopScan()
    }
    func 连接设备(peripheral : CBPeripheral)  -> String?
    {
        if centerManager.state != .poweredOn {
            return "蓝牙不可用，请打开蓝牙"
        }else{
            if self.connectPeripheral != nil && self.connectPeripheral?.state == .connected {
                lastPeripheral = peripheral
                self.centerManager.cancelPeripheralConnection(self.connectPeripheral!)
            }else{
                
            }
            centerManager.connect(peripheral, options: nil)
            self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
            return nil
        }
    }
    func 断开设备(peripheral : CBPeripheral)
    {
        if peripheral ==  self.connectPeripheral {
            self.centerManager.cancelPeripheralConnection(self.connectPeripheral!)
        }
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !(self.peripherals?.contains(peripheral))! {
            self.peripherals?.append(peripheral)
            self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
        }
    }
    ///
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices([serviceid])
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        self.delegate?.展示搜索到的蓝牙(peripheral: peripherals!)
    }
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("蓝牙断了")
        if peripheral.identifier.uuidString == self.connectPeripheral?.identifier.uuidString {
            self.connectPeripheral = nil
            self.connect = false
            if self.delegate != nil {
                self.delegate?.展示搜索到的蓝牙(peripheral: self.peripherals!)
            }
        }
//        showErrorWithAlert2(string: "")
    }
    
    
    ///
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error == nil {
            peripheral.discoverCharacteristics(nil, for: (peripheral.services?.first)!)
        }else{
            print("出错了1")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error == nil {
            for characteristic in service.characteristics! {
                if characteristic.uuid == characteristicid1{
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
        }else{
            print("出错了2")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error == nil {
            self.connectPeripheral = peripheral
            self.connect = true
            self.delegate?.展示搜索到的蓝牙(peripheral: self.peripherals!)
        }else{
            print("出错了3")
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let data = characteristic.value {
//            dele.bleReceiveData(data: data)
//            MIDILinkManager.shard.收到蓝牙数据(data: data)
            VideoMidiModel.shard.midiRecordModel.收到蓝牙进来的事件(data: data)
//            for index in data {
//                print(index)
//            }
//            print("-----------")
        }
    }
  
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
//        if error != nil{
//            print("出现发送错误");
//        }else{
//            
//        }
//        var sss = "完成任务"
//        for indd in (任务队列.first)! {
//            sss += "\(indd)"
//        }
//        print(sss)
//        任务队列.remove(at: 0)
//        if 任务队列.count != 0 {
//            self.senData(data: 任务队列.first!)
//            
//        }
    }
   
//    var 基准时间 : Date?
//    var 序列 : Int?
//    var label = UITextView(frame: CGRect(x: 0, y: 0, width: 1024, height: 100))
    func sendData(data: Data) {
//        if 基准时间 == nil {
//            基准时间 = Date()
//            序列 = 0
//            label.text = ""
//        }
////        let 差 = Date().timeIntervalSince(基准时间!)
////        print("第\(序列)次发 时间：\(差)")
//        var 差 = String()
//        for intt in data {
//            差 = 差 + " \(intt)"
//        }
//        DispatchQueue.main.async {
//            self.label.text = self.label.text! + "||\(差)"
//            self.label.textColor = UIColor.red
//            self.label.backgroundColor = UIColor.white
//            (ScorePlayer.shard.controView as! UIView).addSubview(self.label)
//        }
//        
//        序列! += 1
        
//        var sendDate = Data()
//        for dat in data {
//            if sendDate.count == 5 {
//                var str = "添加任务"
//                for indd in sendDate {
//                    str += "\(indd)"
//                }
//                print(str)
//                任务队列.append(sendDate)
//                if 任务队列.count == 1 {
//                    self.senData(data: 任务队列.first!)
//                }
//                sendDate = Data()
//            }else{
//                sendDate.append(dat)
//            }
//        }
        self.senData(data: data)

//        var str = "添加任务"
//        for indd in data {
//            str += "\(indd)"
//        }
//        print(str)
//        任务队列.append(data)
//        if 任务队列.count == 1 {
//            self.senData(data: 任务队列.first!)
//        }
    }
    func senData(data: Data){

        
        if let services = self.connectPeripheral?.services {
            for serve in services {
                if serve.uuid == serviceid {
                    if let characteristics = serve.characteristics {
                        for characteristic in characteristics {
                            if characteristic.uuid ==  characteristicid1{
                                DispatchQueue.global().async {
                                    self.connectPeripheral?.writeValue(data, for: characteristic, type: .withoutResponse)
                                }
//                                self.connectPeripheral?.writeValue(data, for: (self.connectPeripheral?.services?.first?.characteristics?.first)!, type: .withoutResponse)
                            }
                        }
                    }
                }
            }
        }
        
    }
}

