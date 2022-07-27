//
//  MemeEditorViewController.swift
//  memeMe1.0 Project
//
//  Created by Okoli-Chinedu on 18/07/2022.
//  Copyright © 2022 Okoli-Chinedu. All rights reserved.
//
import Foundation
import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    //MARK: Define Outlets
    @IBOutlet weak var shareImage: UIBarButtonItem!
    @IBOutlet weak var cancelImage: UIBarButtonItem!
    @IBOutlet weak var topTextMenu: UITextField!
    @IBOutlet weak var pickAnImage: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var bottomTextMenu: UITextField!
    @IBOutlet weak var NavigationBar: UINavigationBar!
    @IBOutlet weak var ToolBar: UIToolbar!
    @IBOutlet weak var ImagePickerView: UIImageView!
    
    
    //MARK: Declare variables
    var meme: memeMe!
    var memedImage = UIImage()
    let textFieldsDelegate = TextFieldsDelegate()
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth: -3.0]
    
    func prepareTextField (textField: UITextField, defaultText: String) {
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .center
        self.topTextMenu.delegate = textFieldsDelegate
        self.bottomTextMenu.delegate = textFieldsDelegate
    }
    
    //MARK: define the views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = nil
        prepareTextField(textField: topTextMenu, defaultText: "TOP")
        prepareTextField(textField: bottomTextMenu, defaultText: "BOTTOM")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //MARK: Disable Share button when there is nothing to share
        if let _ = ImagePickerView.image {
            shareImage.isEnabled = true
        } else {
            shareImage.isEnabled = false
        }
        
        //MARK: Disable Camera if there is no camera in the device
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        
        //MARK: Subscribe to Keyboard Notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //MARK: Unsubscribe to Keyboard Notifications
        unsubscribeToKeyboardNotifications()
    }

    //MARK: Set UIImagePickerController Delegate Function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            ImagePickerView.image = image
            shareImage.isEnabled = true
            self.view.layoutIfNeeded()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func hideTopAndBottomBars(isHidden: Bool){
        NavigationBar.isHidden = isHidden
        ToolBar.isHidden = isHidden
    }
    
    //MARK: Selecting Image from PhotoLibrary or Camera
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    enum ButtonType: Int { case camera = 0, album }
    
    @IBAction func camerButtonAndGallery(_ sender: Any) {
        switch(ButtonType(rawValue: (sender as AnyObject).tag)!) {
        case .camera:
            chooseImageFromCameraOrPhoto(source: .camera)
        case .album:
            chooseImageFromCameraOrPhoto(source: .photoLibrary)
        }
    }
    
    //MARK: Functions for the Keyboard Notifications
    @objc func keyboardWillShow(_ notification: Notification) {
        if bottomTextMenu.isEditing{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        if view.frame.origin.y != 0 {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications () {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToKeyboardNotifications () {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Sharing and Saving the memeMe Images
    func generateMemedImage() -> UIImage {
        hideTopAndBottomBars(isHidden: true)
        
        //MARK: Render View to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideTopAndBottomBars(isHidden: false)
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        //MARK: Create the meme Image
        let image = memeMe(topText: topTextMenu.text!, bottomText: bottomTextMenu.text!, originalImage: ImagePickerView.image!, memeMeImage: memedImage)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(image)
    }

    @IBAction func shareImage(_ sender: Any) {
        //MARK: Generate the memeMe image
        let memedImage = generateMemedImage()
        let memeController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        memeController.completionWithItemsHandler = { (activity, completed, returnedItems, error) in
            if completed {
                self.save(memedImage: memedImage)
            }
        }
        present(memeController, animated: true, completion: nil)
    }

    @IBAction func cancelImage(_ sender: Any) {
        shareImage.isEnabled = false
        ImagePickerView.image = nil
        prepareTextField(textField: topTextMenu, defaultText: "TOP")
        prepareTextField(textField: bottomTextMenu, defaultText: "BOTTOM")
    }
}

