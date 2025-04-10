//
//  ViewController.swift
//  imageGenationDemo
//
//  Created by Harsh on 26/11/24.
//

import UIKit
import AVFoundation
import Vision
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var imgSelectedImage: UIImageView!
    
    var openAiService : OpenAIService!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    private let textDetectionRequest = VNRecognizeTextRequest()
    var currentVideoFrame: CVPixelBuffer?
    
    var targetView: UIView!
    var targetedText: UILabel!
    var textView : UIView!
    var photoOutput: AVCapturePhotoOutput!
    var isProcessing: Bool = false
    let falseDetectiontxt : String = "Point Towards The Rack"
    let correctDetectiontxt : String = "If Rack and Sticker is Aligned Than good to go"
    var detectedText: String = ""
    var croppedImageView : UIImageView!
    var stackView : UIStackView!
    var backView : UIView!
    
    private var popUp : CustomMessagePopupView?
    
    var selectedImg: UIImage? = nil{
        didSet{
            guard let selectedImg else { return }
            showCroppedImage(selectedImg)
        }
    }
    
    lazy var captureButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "document.circle"), for: .normal)
        button.tintColor = .yellow
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(captureButtonPressed), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        openAiService = OpenAIService()
    }
    
    func apiCall(){
        
        guard let selectedImg else {
            print("No Image Selected!")
            return
        }
        
        showActivityIndicator()
        
        Task{
            try await openAiService.takeGroqResponse(image: selectedImg) { message in
                DispatchQueue.main.async { [weak self] in
                    guard let self else { return }
                    
                    resetPreviews()
                    
                    popUp?.removeFromSuperview()
                    
                    popUp = nil
                    
                    popUp = CustomMessagePopupView(frame: view.bounds)
                    
                    hideActivityIndicator()
                    
                    popUp?.showPopUpViewin(in: view)
                    
                    popUp?.showMessage(message: message)
                    
                    popUp?.onTapActionClosure = { [weak self] in
                        guard let self else { return }
                        popUp?.removeFromSuperview()
                        popUp = nil
                        isProcessing = false
                    }
                    
//                    if message.contains(detectedText){
//                        
//                    }else{
//                        hideActivityIndicator()
//                        
//                        popUp?.showPopUpViewin(in: view)
//                        
//                        popUp?.showMessage(message: "Scanning Image Failed")
//                        
//                        popUp?.onTapActionClosure = { [weak self] in
//                            guard let self else { return }
//                            popUp?.removeFromSuperview()
//                            popUp = nil
//                            isProcessing = false
//                        }
//                        
//                    }
                }
            }
        }
        
    }
//    frame: CGRect(x: Int(view.frame.width)/2 - 150, y: Int(view.frame.height) - 100, width: 300, height: 40)
    func addTextView(){
        textView = UIView()
        
        textView.backgroundColor = .clear
        
        view.addSubview(textView)
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
        
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            textView.trailingAnchor.constraint(equalTo: captureButton.leadingAnchor, constant: -20),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 40)
            
        ])
        
            targetedText = UILabel()
            targetedText.layer.borderColor = UIColor.white.cgColor
            targetedText.layer.borderWidth = 2
            targetedText.numberOfLines = 0
            targetedText.clipsToBounds = true
            targetedText.layer.masksToBounds = true
            targetedText.layer.cornerRadius = 20
            targetedText.textAlignment = .center
        
            textView.addSubview(targetedText)
        
            targetedText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            
            targetedText.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: 0),
            targetedText.topAnchor.constraint(equalTo: textView.topAnchor, constant: 0),
            targetedText.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 5),
            targetedText.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: 5)
            
        ])
    }
    
    func updateProceedAndCancelButton(){
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.spacing = 16
        
        // Create buttons
        let proceedButton = UIButton(type: .system)
        proceedButton.setTitle("Proceed", for: .normal)
        proceedButton.backgroundColor = .systemGreen
        proceedButton.setTitleColor(.white, for: .normal)
        proceedButton.layer.cornerRadius = 8
        proceedButton.addTarget(self, action: #selector(proceedButtonTapped), for: .touchUpInside)
        
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.backgroundColor = .systemRed
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.layer.cornerRadius = 8
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // Add buttons to the stack view
        stackView.addArrangedSubview(proceedButton)
        stackView.addArrangedSubview(cancelButton)
        
        // Add the stack view to the view hierarchy
        view.addSubview(stackView)
        
        // Enable Auto Layout
        stackView.translatesAutoresizingMaskIntoConstraints = false
        proceedButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        
        // Add constraints
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.topAnchor.constraint(equalTo: croppedImageView.bottomAnchor, constant: 20),
            proceedButton.widthAnchor.constraint(equalToConstant: 120),
            proceedButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.widthAnchor.constraint(equalToConstant: 120),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc func proceedButtonTapped() {
        print("Proceed button tapped")
        apiCall()
    }
    
    @objc func cancelButtonTapped() {
        print("Cancel button tapped")
        resetPreviews()
        isProcessing = false
    }
    
    func resetPreviews(){
        croppedImageView.removeFromSuperview()
        croppedImageView.image = nil
        stackView.removeFromSuperview()
        stackView = nil
        backView.removeFromSuperview()
        backView = nil
    }
    
    func falseDetection(){
        targetedText.backgroundColor = .red
        targetedText.textColor = .white
        targetedText.text = falseDetectiontxt
    }
    
    func correctDetection(){
        targetedText.backgroundColor = .green
        targetedText.textColor = .white
        targetedText.text = correctDetectiontxt
    }
    
    func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        
        guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice) else { return }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        photoOutput = AVCapturePhotoOutput()
        
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "VideoOutputQueue"))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.frame = view.bounds
        videoPreviewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(videoPreviewLayer)
        
        // Add a button to capture an image
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            updateUIForButton()
            addTextView()
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self else { return }
            captureSession.startRunning()
        }
    }
    
    func captureImage() {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func updateUIForButton(){
        
        view.addSubview(captureButton)
        captureButton.isHidden = true
        captureButton.imageEdgeInsets = UIEdgeInsets(top: 40, left: 40, bottom: 40, right: 40)
        captureButton.frame = CGRect(x: 0, y: 0, width: 55, height: 55)
        // Position the button
        NSLayoutConstraint.activate([
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: view.frame.width/2 - 60),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
        
    }
    
    @objc func captureButtonPressed() {
        captureImage()
        isProcessing = true
    }
    
    @IBAction func btnSelectImageButton(_ sender: UIButton) {
        print(#function)
        setupCamera()
        setupVision()
    }
    
    
}

extension ViewController {
    func setupVision() {
        textDetectionRequest.recognitionLevel = .accurate
        textDetectionRequest.usesLanguageCorrection = true
    }

    func detectText(in frame: CVImageBuffer) {
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: frame, options: [:])
        try? requestHandler.perform([textDetectionRequest])
        guard let observations = textDetectionRequest.results else {
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.drawMergedBoundingBox(for: observations)
        }
    }

    func drawMergedBoundingBox(for observations: [VNRecognizedTextObservation]) {
        // Remove existing boxes
        view.layer.sublayers?.removeAll(where: { $0.name == "BoundingBox" })

        guard !observations.isEmpty else {
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                captureButton.isHidden = true
                falseDetection()
            }
            return
        }

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            captureButton.isHidden = false
            correctDetection()
        }
        // Calculate the encompassing rectangle
        var unionRect = CGRect.null
        for observation in observations {
            
            if let topCandidate = observation.topCandidates(1).first {
                detectedText = "\(topCandidate.string)\n"
            }
            
            let boundingBox = observation.boundingBox
            let convertedRect = videoPreviewLayer.layerRectConverted(fromMetadataOutputRect: boundingBox)
            unionRect = unionRect.union(convertedRect)
        }

        // Draw a single rectangle
        let boxLayer = CALayer()
        boxLayer.frame = unionRect
        boxLayer.borderColor = UIColor.yellow.cgColor
        boxLayer.borderWidth = 2
        boxLayer.name = "BoundingBox"
        view.layer.addSublayer(boxLayer)
    }

    
    func addPopupButton(with text: String, at frame: CGRect) {
        let button = UIButton(frame: CGRect(x: frame.midX - 25, y: frame.midY - 25, width: 50, height: 50))
        button.backgroundColor = .yellow
        button.layer.cornerRadius = 25
        button.setImage(UIImage(systemName: "doc.text.viewfinder"), for: .normal)
        button.addTarget(self, action: #selector(showTextPreview(_:)), for: .touchUpInside)
        button.tag = 1001 // Unique identifier
        view.addSubview(button)
    }

    @objc func showTextPreview(_ sender: UIButton) {
        // Fetch the text associated with the bounding box (if needed)
        let previewLabel = UILabel()
        previewLabel.text = "Extracted Text Here"
        previewLabel.frame = CGRect(x: 20, y: view.bounds.height - 200, width: view.bounds.width - 40, height: 100)
        previewLabel.backgroundColor = .white
        previewLabel.textColor = .black
        previewLabel.textAlignment = .center
        previewLabel.layer.cornerRadius = 10
        previewLabel.layer.masksToBounds = true
        view.addSubview(previewLabel)
    }
    
}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !isProcessing else { return }
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        detectText(in: pixelBuffer)
        currentVideoFrame = pixelBuffer
    }
}


extension ViewController : AVCapturePhotoCaptureDelegate{
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: (any Error)?){
        if let data = photo.fileDataRepresentation(), let image = UIImage(data: data) {
            // Save or display the captured image
            print("Captured Image: \(image)")
            
            selectedImg = image
            
        }
    }
}

extension ViewController{
    
    func captureCurrentFrame() -> UIImage? {
        guard let frame = currentVideoFrame else { return nil } // Replace with your video buffer source
        let ciImage = CIImage(cvImageBuffer: frame)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
    
    func processFrame(_ image: UIImage) {
        // Perform text detection
        let ciImage = CIImage(image: image)!
        let requestHandler = VNImageRequestHandler(ciImage: ciImage, options: [:])

        let textDetectionRequest = VNRecognizeTextRequest { (request, error) in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            // Merge bounding boxes
            var unionRect = CGRect.null
            for observation in observations {
                unionRect = unionRect.union(observation.boundingBox)
            }

            // Crop the image
            if let croppedImage = self.cropImage(to: unionRect, from: image) {
                DispatchQueue.main.async {
                    self.showCroppedImage(croppedImage)
                }
            }
        }

        textDetectionRequest.recognitionLevel = .accurate
        try? requestHandler.perform([textDetectionRequest])
    }

    
    func cropImage(to boundingBox: CGRect, from image: UIImage) -> UIImage? {
        // Convert boundingBox to image coordinates
        let scale = image.size
        let scaledRect = CGRect(
            x: boundingBox.origin.x * scale.width,
            y: (1 - boundingBox.origin.y - boundingBox.height) * scale.height, // Flip y-axis
            width: boundingBox.width * scale.width,
            height: boundingBox.height * scale.height
        )

        // Crop the image
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    func showCroppedImage(_ image: UIImage) {
        
        backView = UIView(frame: view.frame)
        
        view.addSubview(backView)
        
        backView.backgroundColor = .black.withAlphaComponent(0.5)
        
        let imageHeight = view.frame.height - 300
        let imageWidth = view.frame.width - 40
        
        croppedImageView = UIImageView(image: image)
        croppedImageView.contentMode = .scaleAspectFit
        croppedImageView.clipsToBounds = true
        croppedImageView.layer.masksToBounds = true
        croppedImageView.layer.cornerRadius = 20
        croppedImageView.frame = CGRect(x: view.center.x - (imageWidth/2), y: 50, width: imageWidth, height: imageHeight)
        backView.addSubview(croppedImageView)
        updateProceedAndCancelButton()
    }
    
}
