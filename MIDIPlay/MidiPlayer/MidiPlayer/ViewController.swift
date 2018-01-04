//
//  ViewController.swift
//  MidiPlayer
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
        let filePatch = Bundle.main.path(forResource: "xiaobuwuqu", ofType: "mid")
        let sfTowPatch = Bundle.main.path(forResource: "TimGM6mb", ofType: "sf2")
        let data = try? Data(contentsOf: URL(fileURLWithPath: filePatch!))
        avplayer = try? AVMIDIPlayer(data: data!, soundBankURL: URL(fileURLWithPath: sfTowPatch!))
        avplayer?.prepareToPlay()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        avplayer?.currentPosition = 0
        avplayer?.play({
            print("播放结束")
        })
        print(avplayer?.isPlaying)
    }

}

