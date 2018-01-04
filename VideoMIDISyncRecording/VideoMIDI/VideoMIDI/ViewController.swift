//
//  ViewController.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/1.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit

class ViewControllerCell: UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func addData(model:VideoMidiItemModel){
        self.textLabel?.text = "\( model.nameNumber)"
    }
}

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "录制", style: .done, target: self, action: #selector(ViewController.录制点击事件))
        self.view.backgroundColor = UIColor.white
        tableView.delegate = self
        tableView.dataSource = self
        self.view.addSubview(tableView)
        tableView.frame = CGRect(x: 0, y: 64, width: 768, height: 1024)
        tableView.register(ViewControllerCell.self, forCellReuseIdentifier: "ViewControllerCell")
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        VideoMidiModel.shard.刷新videoMidi列表()
        self.tableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return VideoMidiModel.shard.videoMidiItemModelList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewControllerCell", for: indexPath) as! ViewControllerCell
        cell.addData(model: VideoMidiModel.shard.videoMidiItemModelList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = PlayerVideoMidiVC()
        vc.itemModel = VideoMidiModel.shard.videoMidiItemModelList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    @objc func 录制点击事件() {
        self.navigationController?.pushViewController(RecordVC(), animated: true)
    }
}

