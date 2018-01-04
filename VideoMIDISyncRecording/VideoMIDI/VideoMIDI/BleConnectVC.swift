//
//  BleConnectVC.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/1.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit

class BleConnectVCCell : UITableViewCell {
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addData(pp:CBPeripheral) {
        self.textLabel?.text = pp.name
        self.detailTextLabel?.text = pp.state == .connected ? "已连接" : "未连接"
    }
}
import CoreBluetooth

class BleConnectVC: UITableViewController,BleControldelegate {

    var dataSource : [CBPeripheral] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(BleConnectVCCell.self, forCellReuseIdentifier: "BleConnectVCCell")
        
        NotificationCenter.default.addObserver(self, selector: #selector(bleChange), name: Notification.Name.init(bleconnectchange), object: nil)

        BleControl.shard.delegate = self
        self.view.backgroundColor = UIColor.white
        self.tableView.tableFooterView = UIView()
    }
    
    @objc func bleChange() {
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        _ = BleControl.shard.开始查找蓝牙设备()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        BleControl.shard.停止搜索()
    }
    
    func 展示搜索到的蓝牙(peripheral: [CBPeripheral])
    {
        dataSource = peripheral.sorted(by: { (p1, p2) -> Bool in
            return p1.state == .connected
        })
        self.tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let pp = dataSource[indexPath.row]
        if pp.state == .connected {
            BleControl.shard.断开设备(peripheral: pp)
        }else{
            _ = BleControl.shard.连接设备(peripheral: pp)
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : BleConnectVCCell = tableView.dequeueReusableCell(withIdentifier: "BleConnectVCCell", for: indexPath) as! BleConnectVCCell
        cell.addData(pp: dataSource[indexPath.row])
        return cell
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
