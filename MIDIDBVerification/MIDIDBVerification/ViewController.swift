//
//  ViewController.swift
//  MIDIDBVerification
//
//  Created by 韩艳锋 on 2017/12/25.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        NetWorkControl.加载所有曲谱信息 { (succed, reason, data) in
            DataControl.单例.简单曲谱模型数组 = data as! [ScoreSimpl]
            print("加载简单模型成功")
        }
    }
    
    func 比对() {
        if let samp = DataControl.单例.getCurrentScoreSimpl() {
            DataControl.单例.通过id获取曲谱详情(scoreID: samp.iden, back: { (succed, reason, object) in
              let detail = object as! ScoreDetail
                detail.获取midiDb数据(back: { [unowned detail,unowned self] (succed) in
                    if succed {
                        detail.对比()
                        self.比对()
                    }else{
                        print(detail.musicname + "获取失败")
                    }
                })
            })
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        比对()
    }
}

