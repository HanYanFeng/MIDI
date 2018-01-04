//
//  PlayerVideoMidiVC.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/2.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
import AVKit
class PlayerVideoMidiVC: UIViewController ,WWMIDIPlayerDelegate{
    
    
    var avPlayervVC : AVPlayerViewController!
//    var avMidiplayer : AVMIDIPlayer!
    var midiPlayer : WWMIDIPlayer!
    var itemModel : VideoMidiItemModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        avPlayervVC = AVPlayerViewController()
        let url = URL(fileURLWithPath: itemModel.videoFilePath)
        avPlayervVC.player = AVPlayer(url: url)
//        avPlayervVC.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue;
        avPlayervVC.showsPlaybackControls = true;
        avPlayervVC.view.frame = videoFrame
        self.view.addSubview(avPlayervVC.view)
        self.addChildViewController(avPlayervVC)
        self.view.backgroundColor = UIColor.white
        
        let data = try! Data(contentsOf: URL(fileURLWithPath: itemModel.midiFilePath))
//        avMidiplayer = try? AVMIDIPlayer(data: data, soundBankURL: URL(fileURLWithPath: sfTowPatch!))
//        avMidiplayer.prepareToPlay()
        midiPlayer = WWMIDIPlayer()
        midiPlayer.delegate = self
        midiPlayer.sendToDelegate = true
        midiPlayer.midiData = data

        let 播放 = UIButton(frame: CGRect(x: 100, y: 521 + 64 + 5 + 20, width: 150, height: 44))
        播放.setTitle("播放", for: .normal)
        播放.backgroundColor = UIColor.red
        播放.addTarget(self, action: #selector(PlayerVideoMidiVC.播放), for: .touchUpInside)
        播放.layer.cornerRadius = 10
        self.view.addSubview(播放)
        
        let 暂停 = UIButton(frame: CGRect(x: 768 - 播放.frame.width - 播放.frame.minX, y: 播放.frame.minY, width: 播放.frame.width, height: 播放.frame.height))
        暂停.setTitle("暂停", for: .normal)
        暂停.backgroundColor = UIColor.green
        暂停.addTarget(self, action: #selector(PlayerVideoMidiVC.暂停), for: .touchUpInside)
        暂停.layer.cornerRadius = 10
        self.view.addSubview(暂停)
    }
    @objc func 播放() {

        avPlayervVC.player?.play()
        midiPlayer.play()
        
    }
    func midiPacketsReceived(_ pktlist: UnsafePointer<MIDIPacketList>!) {
        WWMIDIPlayer.midiPacketsReceived(pktlist, sendToble: BleControl.shard.connect, midiEngine: midiPlayer) { (data, track) in
            var datta = Data(bytes: [0x80,0x80])
            datta.append(data!)
            var str = ""
            for item in data! {
                str += " \(item)"
            }
            print(str)
            if data![0] >> 4 == 0x90 && data![2] == 0 {
                BleControl.shard.sendData(data: Data(bytes: [0x80,0x80,0x80,data![1],0]))
            }else{
                BleControl.shard.sendData(data: datta)
            }
        }
    }
    
    @objc func 暂停() {
        avPlayervVC.player?.pause()
        midiPlayer.stop()
    }
}
