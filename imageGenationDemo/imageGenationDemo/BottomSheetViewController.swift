//
//  BottomSheetViewController.swift
//  imageGenationDemo
//
//  Created by Harsh on 04/12/24.
//

import Foundation
import UIKit


class BottomSheetViewController: UIViewController {
    
    var text : String? = nil
    
    var takeViewDidDissappearEventClosure: (() -> Void)? = nil
    
    init(text: String) {
        super.init(nibName: nil, bundle: nil)
        self.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print(#function)
        takeViewDidDissappearEventClosure?()
    }
    
    func setUI(){
        
        self.view.backgroundColor = .white
        
        let view = UIView(frame: view.bounds)
        
        view.backgroundColor = .clear
        
        view.translatesAutoresizingMaskIntoConstraints = true
        
        self.view.addSubview(view)
        
        NSLayoutConstraint.activate([
            
            view.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
            view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
            view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
            view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0)
            
        ])
        
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 14)
        label.textAlignment = .natural
        label.textColor = .black
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 10),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            
        ])
        
        label.text = self.text?.replacingOccurrences(of: "*", with: "")
        
        
    }
    
}


//func setupCamera() {
//    
//    captureSession = AVCaptureSession()
//    captureSession.sessionPreset = .photo
//    
//    guard let videoCaptureDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) else { return }
//    let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice)
//    
//    do {
//        try videoCaptureDevice.lockForConfiguration()
//        videoCaptureDevice.focusMode = .continuousAutoFocus
//        videoCaptureDevice.unlockForConfiguration()
//    } catch {
//        fatalError("Camera lockConfiguration failed")
//    }
//    
//    if captureSession.canAddInput(videoInput!) {
//        captureSession.addInput(videoInput!)
//    }
//    
//    photoOutput = AVCapturePhotoOutput()
//    
//    if captureSession.canAddOutput(photoOutput) {
//        captureSession.addOutput(photoOutput)
//    }
//    
//    let videoOutput = AVCaptureVideoDataOutput()
//    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//    captureSession.addOutput(videoOutput)
//    
//    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//    previewLayer.frame = view.layer.bounds
//    previewLayer.videoGravity = .resizeAspectFill
//    view.layer.addSublayer(previewLayer)
//    
//    DispatchQueue.global(qos: .background).async { [weak self] in
//        guard let self else { return }
//        captureSession.startRunning()
//    }
//    
//}
//
//func setupTargetView() {
//    
//    targetView = UIView()
//    targetView.layer.borderColor = UIColor.clear.cgColor
//    targetView.layer.borderWidth = 2
//    // Adjust as needed
//    targetView.frame = CGRect(x: view.frame.width / 2 - 150, y: view.frame.height/2 - 300, width: 300, height: 600)
//    view.addSubview(targetView)
//    
//    targetView.translatesAutoresizingMaskIntoConstraints = true
//    
//    NSLayoutConstraint.activate([
//        
//        targetView.topAnchor.constraint(equalTo: view.topAnchor, constant: 200),
//        targetView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
//        targetView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
//        targetView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -200)
//        
//    ])
//    
//    textView = UIView(frame: CGRect(x: Int(view.frame.width)/2 - 150, y: Int(view.frame.height) - 100, width: 300, height: 40))
//    
//    textView.backgroundColor = .clear
//    
//    view.addSubview(textView)
//    
//    textView.translatesAutoresizingMaskIntoConstraints = true
//    
//    targetedText = UILabel()
//    targetedText.layer.borderColor = UIColor.white.cgColor
//    targetedText.layer.borderWidth = 2
//    targetedText.clipsToBounds = true
//    targetedText.layer.masksToBounds = true
//    targetedText.layer.cornerRadius = 20
//    targetedText.textAlignment = .center
//    targetedText.backgroundColor = .red
//    targetedText.textColor = .white
//    
//    textView.addSubview(targetedText)
//    
//    targetedText.translatesAutoresizingMaskIntoConstraints = false
//    
//    NSLayoutConstraint.activate([
//    
//        targetedText.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0),
//        targetedText.topAnchor.constraint(equalTo: textView.topAnchor, constant: 0),
//        targetedText.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 0),
//        targetedText.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 0)
//        
//    ])
//    
//}
//
//func scanTextFromTarget(text : String){
//    
//    if text == falseDetection{
//        textView.isHidden = false
//        targetedText.text = text
//    }else{
//        textView.isHidden = true
//        print(text)
//    }
//    
//}
//
//func validateTextPosition(_ observations: [VNRecognizedTextObservation]) {
//    var isAligned = false
//    
//    detectedText = ""
//    
//    for observation in observations {
//        let boundingBox = observation.boundingBox // Normalized coordinates
//        let textRect = VNImageRectForNormalizedRect(boundingBox, Int(targetView.frame.width), Int(targetView.frame.height))
//        
//        // Check if detected text falls within the targetView bounds
//        if targetView.frame.contains(textRect) {
//            
//            isAligned = true
//            
//            // Extract the text from the observation
//            if let topCandidate = observation.topCandidates(1).first {
//                detectedText += "\(topCandidate.string)\n"
//            }
//            
//        }
//        
//    }
//    
//    // Provide user feedback
//    if isAligned {
//        isProcessing = true
//        scanTextFromTarget(text: detectedText)
//        captureImage()
//        targetView.layer.borderColor = UIColor.clear.cgColor
//        // Optionally, capture the frame
//    } else {
//        scanTextFromTarget(text: falseDetection)
//        targetView.layer.borderColor = UIColor.clear.cgColor
//    }
//}
//
//func captureImage() {
//    let settings = AVCapturePhotoSettings()
//    settings.flashMode = .off
//    photoOutput.capturePhoto(with: settings, delegate: self)
//}



//func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
//
//        let request = VNRecognizeTextRequest { (request, error) in
//            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
//
//            DispatchQueue.main.async { [weak self] in
//                guard let self else { return }
//                // Validate text position within the target view
//                if !self.isProcessing{
//                    self.validateTextPosition(observations)
//                    textView.isHidden = false
//                }else{
//                    textView.isHidden = true
//                }
//
//            }
//
//        }
//
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//        try? handler.perform([request])
//        //        detectStickersWithCoreML(pixelBuffer: pixelBuffer)
//
//
//    }
//
//    func detectStickersWithCoreML(pixelBuffer: CVPixelBuffer) {
//
//        let model: VNCoreMLModel
//        do {
//            let configuration = MLModelConfiguration()
//            model = try VNCoreMLModel(for: YOLOv3(configuration: configuration).model)
//        } catch {
//            print("Failed to load YOLOv3 model: \(error)")
//            return
//        }
//
//        let request = VNCoreMLRequest(model: model) { (request, error) in
//            guard let results = request.results as? [VNRecognizedObjectObservation] else { return }
//
//            DispatchQueue.main.async {
//                self.processDetectedStickers(results)
//            }
//        }
//
//        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: .up, options: [:])
//        try? handler.perform([request])
//    }
//
//    func processDetectedStickers(_ observations: [VNRecognizedObjectObservation]) {
//        for observation in observations {
//            let boundingBox = observation.boundingBox
//            let rect = VNImageRectForNormalizedRect(
//                boundingBox,
//                Int(view.frame.width),
//                Int(view.frame.height)
//            )
//
//            // Print sticker label and confidence
//            if let label = observation.labels.first {
//                self.drawBoundingBox(rect: rect, label: label.identifier, confidence: label.confidence)
//                print("Detected sticker: \(label.identifier) with confidence \(label.confidence)")
//            }
//        }
//    }
//
//    func drawBoundingBox(rect: CGRect, label: String, confidence: Float) {
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.frame = rect
//        shapeLayer.borderColor = UIColor.red.cgColor
//        shapeLayer.borderWidth = 2
//
//        let textLayer = CATextLayer()
//        textLayer.string = "\(label) (\(Int(confidence * 100))%)"
//        textLayer.fontSize = 14
//        textLayer.foregroundColor = UIColor.white.cgColor
//        textLayer.backgroundColor = UIColor.black.withAlphaComponent(0.7).cgColor
//        textLayer.frame = CGRect(x: rect.origin.x, y: rect.origin.y - 20, width: rect.width, height: 20)
//
//        view.layer.addSublayer(shapeLayer)
//        view.layer.addSublayer(textLayer)
//    }
