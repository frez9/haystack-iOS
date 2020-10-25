//
//  CameraViewController.swift
//  LoginKitSample
//
//  Created by Frezghi Noel on 9/3/20.
//  Copyright © 2020 Snap Inc. All rights reserved.
//

import UIKit
import AVFoundation
import SCSDKCreativeKit
import Firebase

var productImageURL: String!

class CameraViewController: UIViewController, AVCapturePhotoCaptureDelegate, UIGestureRecognizerDelegate {
    
    var cameraView: UIView!
    var captureButton: UIButton!
    var dismissButton: UIButton!
    var deleteButton: UIButton!
    var postButton: UIButton!
    
    var usernameView: UIView!
    var titleLabel: UILabel!
    var subtitleLabel: UILabel!
    var usernameField: UITextField!
    var doneButton: UIButton!
    
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var capturedImageView: UIImageView?
    
    var viewTranslation = CGPoint(x: 0, y: 0)
    var panGestureRecognizer: UIPanGestureRecognizer!
    
    var uploadData: Data!
    
    var snapAPI: SCSDKSnapAPI?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        self.panGestureRecognizer.delegate = self
        self.view.addGestureRecognizer(self.panGestureRecognizer)
        
        snapAPI = SCSDKSnapAPI()
        
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(true, animated: false)

        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        cameraView = UIView()
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cameraView)
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        dismissButton = UIButton()
        let dismissButtonImage = UIImage(named: "dismiss")
        dismissButton.setImage(dismissButtonImage, for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dismissButton)
        
        captureButton = UIButton()
        let captureButtonImage = UIImage(named: "capture")
        captureButton.setImage(captureButtonImage, for: .normal)
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        
        capturedImageView = UIImageView()
        capturedImageView!.contentMode = .scaleAspectFill
        capturedImageView!.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(capturedImageView!)
        
        deleteButton = UIButton()
        let deleteButtonImage = UIImage(named: "xmark")
        deleteButton.setImage(deleteButtonImage, for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        deleteButton.isHidden = true
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deleteButton)
        
        postButton = UIButton()
        postButton.setTitle("Post", for: .normal)
        postButton.addTarget(self, action: #selector(postButtonTapped), for: .touchUpInside)
        postButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 23)
        postButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        postButton.layer.cornerRadius = 25
        postButton.isHidden = true
        postButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(postButton)
        
        usernameView = UIView()
        usernameView.alpha = 0
        usernameView.layer.borderWidth = 0.5
        usernameView.backgroundColor = .white
        usernameView.layer.cornerRadius = 20
        usernameView.frame.size.height = 185
        usernameView.frame.size.width = 275
        usernameView.center = view.center
        view.addSubview(usernameView)
        
        titleLabel = UILabel()
        titleLabel.font = UIFont.init(name: "AvenirNext-DemiBold", size: 17)
        titleLabel.text = "Enter Your Snapchat Username"
        titleLabel.textColor = .black
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(titleLabel)
        
        subtitleLabel = UILabel()
        subtitleLabel.font = UIFont.init(name: "AvenirNext-Medium", size: 15)
        subtitleLabel.text = "(this is how buyers will reach you)"
        subtitleLabel.textColor = .black
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(subtitleLabel)
        
        usernameField = UITextField()
        usernameField.autocapitalizationType = .none
        usernameField.autocorrectionType = .no
        let atLabel = UILabel()
        atLabel.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        atLabel.text = "@ "
        atLabel.textColor = .black
        usernameField.leftView = atLabel
        usernameField.leftViewMode = .always
        usernameField.font = UIFont.init(name: "AvenirNext-Medium", size: 17)
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(usernameField)
        
        doneButton = UIButton()
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.titleLabel?.font = UIFont.init(name: "AvenirNext-DemiBold", size: 17)
        doneButton.backgroundColor = UIColor(red: 155.0/255.0, green: 085.0/255.0, blue: 160.0/255.0, alpha: 1.0)
        doneButton.layer.cornerRadius = 15
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        usernameView.addSubview(doneButton)
        
        setUpConstraints()
        
    }
    
    func setUpConstraints() {
        NSLayoutConstraint.activate([cameraView.topAnchor.constraint(equalTo: view.topAnchor), cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor), cameraView
            .trailingAnchor.constraint(equalTo: view.trailingAnchor), cameraView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)])
        
        NSLayoutConstraint.activate([dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15), dismissButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 25)])
        
        NSLayoutConstraint.activate([captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10), captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)])
        
        NSLayoutConstraint.activate([capturedImageView!.topAnchor.constraint(equalTo: view.topAnchor), capturedImageView!.leadingAnchor.constraint(equalTo: view.leadingAnchor), capturedImageView!
            .trailingAnchor.constraint(equalTo: view.trailingAnchor), capturedImageView!.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
        
        NSLayoutConstraint.activate([deleteButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10), deleteButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20)])
        
        NSLayoutConstraint.activate([postButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -150), postButton.topAnchor.constraint(equalTo: postButton.bottomAnchor, constant: -50), postButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20), postButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 150)])
        
        NSLayoutConstraint.activate([titleLabel.centerXAnchor.constraint(equalTo: usernameView.centerXAnchor), titleLabel.topAnchor.constraint(equalTo: usernameView.topAnchor, constant: 15)])
        
        NSLayoutConstraint.activate([subtitleLabel.centerXAnchor.constraint(equalTo: usernameView.centerXAnchor), subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5)])
        
        NSLayoutConstraint.activate([usernameField.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 20), usernameField.leadingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: -60), usernameField.trailingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: 60)])
        
        NSLayoutConstraint.activate([doneButton.leadingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: -65), doneButton.topAnchor.constraint(equalTo: doneButton.bottomAnchor, constant: -35), doneButton.bottomAnchor.constraint(equalTo: usernameView.bottomAnchor, constant: -15), doneButton.trailingAnchor.constraint(equalTo: usernameView.centerXAnchor, constant: 65)])
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        switch sender.state {
        case .changed:
            viewTranslation = sender.translation(in: view)
            UIView.animate(withDuration: 0.0, delay: 0, options: .beginFromCurrentState, animations: {
                if self.viewTranslation.y >= 0.0 {
                    self.view.transform = CGAffineTransform(translationX: 0, y: self.viewTranslation.y)
                }
            })
        case .ended:
            if viewTranslation.y < 100 {
                UIView.animate(withDuration: 0.0, delay: 0, options: .beginFromCurrentState, animations: {
                    self.view.transform = .identity
                })
            } else {
                dismiss(animated: true, completion: nil)
                self.captureSession.stopRunning()
            }
        default:
            break
        }
    }
    
    @objc func dismissButtonTapped() {
        dismiss(animated: true)
        self.captureSession.stopRunning()
    }
    
    @objc func deleteButtonTapped() {
        self.capturedImageView!.image = nil
        deleteButton.isHidden = true
        dismissButton.isHidden = false
        postButton.isHidden = true
        captureButton.isHidden = false
        panGestureRecognizer.isEnabled = true
    }
    
    @objc func postButtonTapped() {
        if defaults.bool(forKey: "did_show_username_view") == false {
            UIView.animate(withDuration: 0.15, animations: {
                self.usernameView.alpha = 1
                self.deleteButton.isUserInteractionEnabled = false
            })
        } else {
            Analytics.logEvent("photo_posted", parameters: nil)
            guard let snapImage = capturedImageView!.image else {
                return
            }

            let snapPhoto = SCSDKSnapPhoto(image: snapImage)
            let snapContent = SCSDKPhotoSnapContent(snapPhoto: snapPhoto)
            snapContent.attachmentUrl = "https://www.google.com/?client=safari"
            let sticker = SCSDKSnapSticker(stickerUrl: URL(string: "https://iili.io/2al1OG.png")!, isAnimated: false)
            snapContent.sticker = sticker
            sticker.posX = 0.5
            sticker.posY = 0.85

            view.isUserInteractionEnabled = false

            let storage = Storage.storage()
            let storageRef = storage.reference()
            let productImageRef = storageRef.child("\(defaults.string(forKey: "external_id")!)/\(defaults.integer(forKey: "image_storage_id")).jpg")
            productImageRef.putData(self.uploadData, metadata: nil) { (metadata, error) in
                productImageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        return
                    }
                    productImageURL = "\(downloadURL)"
                    
                    NetworkManager.createListing() {

                        self.snapAPI?.startSending(snapContent) { error in
                            
                            if let error = error {
                                print(error.localizedDescription)
                                
                            } else {
                                self.view.isUserInteractionEnabled = true
                                self.dismiss(animated: true)
                                self.captureSession.stopRunning()
                                defaults.set(defaults.integer(forKey: "image_storage_id")+1, forKey: "image_storage_id")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func doneButtonTapped() {
        if defaults.bool(forKey: "did_show_username_view") == false {
            defaults.set(true, forKey: "did_show_username_view")
        }
        UIView.animate(withDuration: 0.15, animations: {
            self.usernameView.alpha = 0
            self.usernameView.endEditing(true)
            self.deleteButton.isUserInteractionEnabled = true
        })
        defaults.set(usernameField.text, forKey: "snapchat_username")
        NetworkManager.updateSnapchatUsername()
    }
    
    @objc func captureButtonTapped() {
        Analytics.logEvent("photo_captured", parameters: nil)
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
        captureButton.isHidden = true
        dismissButton.isHidden = true
        deleteButton.isHidden = false
        postButton.isHidden = false
        panGestureRecognizer.isEnabled = false
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        uploadData = imageData
        
        let image = UIImage(data: imageData)
        self.capturedImageView!.image = image
        

    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspectFill
        videoPreviewLayer.connection?.videoOrientation = .portrait
        cameraView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.cameraView.bounds
            }
        }
    }

}
