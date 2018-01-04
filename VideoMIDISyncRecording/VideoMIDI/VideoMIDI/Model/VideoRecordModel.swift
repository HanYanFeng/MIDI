//
//  VideoRecordModel.swift
//  VideoMIDI
//
//  Created by 韩艳锋 on 2017/11/1.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//


import UIKit
import AVFoundation
import Photos

class VideoRecordModel: NSObject,AVCaptureFileOutputRecordingDelegate {
    
    
    /// 负责输入和输出设备之间的数据传递
    private var captureSession : AVCaptureSession!
    
    /// 负责从AVCaptureDevice获得输入数据
    private var captureDeviceInput : AVCaptureDeviceInput!
    
    /// 视频输出流
    private var captureMovieFileOutput : AVCaptureMovieFileOutput!
    
    /// 相机拍摄预览图层
    var captureVideoPreviewLayer : AVCaptureVideoPreviewLayer!
    
    var 记录模型:VideoMidiItemModel?
    
    override init() {
        super.init()
        // 初始化会话
        captureSession = AVCaptureSession()
        // 设置分辨率
        captureSession.sessionPreset = .low
        
        let captureDevice = self.获取设备(position: .back)
        if captureDevice == nil {
            print("获取摄像头出错")
            return
        }
        // 根据输入设备初始化设备输入对象，用于获得输入数据
        captureDeviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        
        // 初始化输出对象
        captureMovieFileOutput = AVCaptureMovieFileOutput()
        //** 可以设置输出
        
        // 将设备输入添加到会话中
        if captureSession.canAddInput(captureDeviceInput) {
            captureSession.addInput(captureDeviceInput)
        }else{
            print("添加输入设备错误")
        }
        
        // 添加输出设备
        if captureSession.canAddOutput(captureMovieFileOutput) {
            captureSession.addOutput(captureMovieFileOutput)
            //            let captureConnection = captureMovieFileOutput.connection(with: .video)
            //            if captureConnection!.isVideoStabilizationSupported {
            //                captureConnection?.preferredVideoStabilizationMode = .auto
            //            }
        }else{
            print("添加输出设备失败")
        }
        
        // 创建视频预览层，用于实时展示摄像头状态
        captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        captureVideoPreviewLayer.backgroundColor = UIColor.red.cgColor
        captureVideoPreviewLayer.videoGravity = .resizeAspectFill
        }
    
    func startRunning(){
        captureSession.startRunning()
    }
    
    func 开始录制(model:VideoMidiItemModel) {
        self.记录模型 = model
        _ = captureMovieFileOutput.connection(with: .video)
        if !captureMovieFileOutput.isRecording {
            let filePath = self.记录模型!.videoFilePath
            let fileUrl = URL(fileURLWithPath: filePath, isDirectory: true)
            try? FileManager.default.removeItem(at: fileUrl)
            captureMovieFileOutput.startRecording(to: fileUrl, recordingDelegate: self)
        }else{
        }
    }
    func 停止录制() {
        captureMovieFileOutput.stopRecording()
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print(outputFileURL)
//        let ala = AlAss
        var message:String!
        //将录制好的录像保存到照片库中
//        PHPhotoLibrary.shared().performChanges({
//            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)
//        }, completionHandler: { (isSuccess: Bool, error: Error?) in
//            if isSuccess {
//                message = "保存成功!"
//            } else{
//                message = "保存失败：\(error!.localizedDescription)"
//            }
//
//            print(message)
//        })
    }
    
    private func 获取设备(position:AVCaptureDevice.Position) -> AVCaptureDevice! {
        var devices : [AVCaptureDevice]!
        if #available(iOS 10.2,*) {
            devices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera,.builtInDualCamera,.builtInTelephotoCamera], mediaType: nil, position: position)
                .devices
        }else{
            devices = AVCaptureDevice.devices()
        }
        for item  in devices where item.position == position {
            return item
        }
        return nil
    }
    
}
