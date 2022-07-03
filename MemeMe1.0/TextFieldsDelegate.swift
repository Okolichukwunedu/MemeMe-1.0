//
//  TextFieldsDelegate.swift
//  MemeMe1.0
//
//  Created by user on 02/07/2022.
//  Copyright © 2022 OkoliChinedu. All rights reserved.
//

import Foundation
import UIKit

class TextFieldsDelegate: NSObject, UITextFieldDelegate {
    
    //MARK: Text Field Delegate Methods
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        // Figure out what the new text will be, if we return true
        var newText = textField.text! as NSString
        newText = newText.replacingCharacters(in: range, with: string) as NSString
        return true
    }

    let orignialText: [String: String] = [
        "top": "TYPE HERE",
        "bottom": "TYPE HERE"
    ]

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == orignialText["top"] || textField.text == orignialText["bottom"] {
            textField.text = " "
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}



