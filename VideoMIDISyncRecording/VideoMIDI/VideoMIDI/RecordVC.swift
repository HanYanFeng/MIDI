//
//  RecordVC.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/1.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import AVFoundation

let videoFrame = CGRect(x: 5, y: 64 + 5, width: 758, height: 502)

class RecordVC: UIViewController {

    var videoMidiModel = VideoMidiModel.shard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        creatUI()
        videoMidiModel.videoRecordModel.startRunning()
    }
    
    func creatUI(){
        
        self.view.backgroundColor = UIColor.white

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "蓝牙", style: .done, target: self, action: #selector(RecordVC.蓝牙按钮点击事件))

        self.view.backgroundColor = UIColor.white
        videoMidiModel.videoRecordModel.captureVideoPreviewLayer.frame = videoFrame
        self.view.layer.addSublayer(videoMidiModel.videoRecordModel.captureVideoPreviewLayer)
        
        let 开始录制按钮 = UIButton(frame: CGRect(x: 100, y: 521 + 64 + 5 + 20, width: 150, height: 44))
        开始录制按钮.setTitle("开始录制按钮", for: .normal)
        开始录制按钮.backgroundColor = UIColor.red
        开始录制按钮.addTarget(self, action: #selector(开始录制按钮点击), for: .touchUpInside)
        开始录制按钮.layer.cornerRadius = 10
        self.view.addSubview(开始录制按钮)
        
        let 停止录制按钮 = UIButton(frame: CGRect(x: 768 - 开始录制按钮.frame.width - 开始录制按钮.frame.minX, y: 开始录制按钮.frame.minY, width: 开始录制按钮.frame.width, height: 开始录制按钮.frame.height))
        停止录制按钮.setTitle("停止录制按钮", for: .normal)
        停止录制按钮.backgroundColor = UIColor.green
        停止录制按钮.addTarget(self, action: #selector(停止录制按钮点击), for: .touchUpInside)
        停止录制按钮.layer.cornerRadius = 10
        self.view.addSubview(停止录制按钮)
    }

    @objc func 停止录制按钮点击() {
        videoMidiModel.停止录制()
    }
    
    @objc func 开始录制按钮点击() {
         videoMidiModel.开始录制()
    }
    
    @objc func 蓝牙按钮点击事件() {
        self.navigationController?.pushViewController(BleConnectVC(), animated: true)
    }
    deinit {
        print("RecordVC销毁")
    }
}
