//
//  Copyright (c) 2016 Daniel Rhodes <rhodes.daniel@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
//  DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
//  USE OR OTHER DEALINGS IN THE SOFTWARE.
//
import Foundation
import UIKit
import SnapKit

class ChatView : UIView {
    
    var tableView: UITableView
    var textField: UITextField
    var bottomLayoutConstraint: Constraint? = nil
    
    required override init(frame: CGRect) {
        self.tableView = UITableView()
        self.textField = UITextField()
        
        super.init(frame: frame)
        
        self.tableView.frame = CGRect.zero
        self.tableView.contentInset = UIEdgeInsetsMake(0, -5, 0, 0);
        self.addSubview(self.tableView)
        
        self.textField.frame = CGRect.zero
        self.textField.borderStyle = UITextBorderStyle.bezel
        self.textField.returnKeyType = UIReturnKeyType.send
        self.textField.placeholder = "Say something..."
        self.addSubview(self.textField)
        
        self.backgroundColor = UIColor.white
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatView.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChatView.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        
        tableView.snp.remakeConstraints { (make) -> Void in
            make.top.left.right.equalTo(self)
            make.bottom.equalTo(textField.snp.top)
        }
        
        textField.snp.remakeConstraints { (make) -> Void in
            make.left.right.equalTo(self)
            make.top.equalTo(tableView.snp.bottom)
            make.height.equalTo(50.0)
            self.bottomLayoutConstraint = make.bottom.equalTo(self).constraint
        }
    }
    
    func requiresConstraintBasedLayout() -> Bool {
        return true
    }
}


//MARK: Notifications
extension ChatView {
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let rawAnimationCurve = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.bottomLayoutConstraint?.update(offset: 0)
            self.updateConstraintsIfNeeded()
            }, completion: nil)
    }
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let keyboardEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let convertedKeyboardEndFrame = self.convert(keyboardEndFrame, from: self.window)
        let rawAnimationCurve = ((notification as NSNotification).userInfo![UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).uint32Value << 16
        let animationCurve = UIViewAnimationOptions(rawValue: UInt(rawAnimationCurve))
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: [.beginFromCurrentState, animationCurve], animations: {
            self.bottomLayoutConstraint?.update(offset: -convertedKeyboardEndFrame.height)
            self.updateConstraintsIfNeeded()
        }, completion: nil)
    }
}

