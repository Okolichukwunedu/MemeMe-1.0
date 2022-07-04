//
//  ViewController.swift
//  MemeMe1.0
//
//  Created by user on 02/07/2022.
//  Copyright © 2022 OkoliChinedu. All rights reserved.
//

import Foundation
import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    // MARK: Define outlets
    @IBOutlet weak var ImagePickerView: UIImageView!
    @IBOutlet weak var topTextMenu: UITextField!
    @IBOutlet weak var bottomTextMenu: UITextField!
    @IBOutlet weak var PickAnImage: UIBarButtonItem!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var ShareImage: UIBarButtonItem!
    @IBOutlet weak var CancelImage: UIBarButtonItem!
    @IBOutlet weak var ToolBar: UIToolbar!
    @IBOutlet weak var NavigationBar: UINavigationBar!
    
    
    var meme: memeMe!
    var memedImage = UIImage()
    
    //MARK: TextField Delegates
    let textFieldsDelegate = TextFieldsDelegate()
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.backgroundColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 52)!,
        NSAttributedString.Key.strokeWidth: -3.0]
    
    func TextFieldProperties (textField: UITextField, text: String) {
        // Top and Bottom Text Menu Field
        topTextMenu.text = text
        topTextMenu.defaultTextAttributes = memeTextAttributes
        topTextMenu.textAlignment = .center
        self.topTextMenu.delegate = textFieldsDelegate
        bottomTextMenu.text = text
        bottomTextMenu.defaultTextAttributes = memeTextAttributes
        bottomTextMenu.textAlignment = .center
        self.bottomTextMenu.delegate = textFieldsDelegate

    }

    // MARK: Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set the delegate and properties
        TextFieldProperties(textField: topTextMenu, text: "TYPE HERE")
        TextFieldProperties(textField: bottomTextMenu, text: "TYPE HERE")
    }
    
    //set camera disbaled if no camera in the device
    override func viewWillAppear(_ animated: Bool) {
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        super.viewWillAppear(animated)
        //Disable Share Button
        if ImagePickerView.image == nil {
            ShareImage.isEnabled = false
        } else {
            ShareImage.isEnabled = true
        }
        // Subscribe to Keyboard Notifications
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Unsubscribe to Keyboard Notifications
        unsubscribeFromKeyboardNotifications()
    }

    //MARK: Set UIImagePickerController Delegate Function
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            ImagePickerView.image = image
            ShareImage.isEnabled = true
            self.view.layoutIfNeeded()
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func hideTopAndButtonBars(isHidden: Bool) {
        NavigationBar.isHidden = isHidden
        ToolBar.isHidden = isHidden
    }
    
    //MARK: Selecting Image From PhotoLibrary or Camera
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickAnImage(_ sender: UIImagePickerController.SourceType) {
        chooseImageFromCameraOrPhoto(source: .photoLibrary)
    }
    
    //MARK: Selecting Image From Camera
    @IBAction func cameraButton(_ sender: Any) {
        chooseImageFromCameraOrPhoto(source: .camera)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: Functions for KeyBoard Notifications
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextMenu.isFirstResponder{
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: Sharing and Saving the memeMe Images
    
    func generateMemedImage() -> UIImage {
        hideTopAndButtonBars(isHidden: true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        hideTopAndButtonBars(isHidden: false)
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        // Create the meme
        let image = memeMe(topText: topTextMenu.text!, bottomText: bottomTextMenu.text!, originalImage: ImagePickerView.image!, memeMeImage: memedImage)
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(image)
    }
    
    @IBAction func ShareImage(_ sender: Any) {
        
        //Generate the memeMe image
        let memedImage = generateMemedImage()
        let memeController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        memeController.completionWithItemsHandler = { (activity, completed, returnedItems, error) in
            if completed {
                self.save(memedImage: memedImage)
            }
        }
        present(memeController, animated: true, completion: nil)
    }
    
    @IBAction func CancelImage(_ sender: Any) {
        ShareImage.isEnabled = false
        ImagePickerView.image = nil
        TextFieldProperties(textField: topTextMenu, text: "TYPE HERE")
        TextFieldProperties(textField: bottomTextMenu, text: "TYPE HERE")    }
}

