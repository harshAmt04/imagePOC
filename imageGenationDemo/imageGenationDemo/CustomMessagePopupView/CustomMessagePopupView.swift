//
//  CustomMessagePopupView.swift
//  imageGenationDemo
//
//  Created by Harsh on 02/12/24.
//

import Foundation
import UIKit

class CustomMessagePopupView : UIView{
    
    @IBOutlet weak var lblMessageLabel: UILabel!
    @IBOutlet weak var vwMessageView: UIView!
    
    var onTapActionClosure: (() -> Void)? = nil
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialCommit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialCommit()
    }
    deinit{
        print("Removed \(className) automatically from memory.")
    }
    private func initialCommit(){
        fromNib()
        updateUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI(){
        self.accessibilityIdentifier = className
        self.backgroundColor = .clear
        addTapGesture(action:  { [weak self] action in
            guard let self else { return }
            onTapActionClosure?()
        })
        
        vwMessageView.clipsToBounds = true
        vwMessageView.layer.masksToBounds = true
        vwMessageView.layer.cornerRadius = 20
    }
    
    func showMessage(message : String){
        lblMessageLabel.text = message.replacingOccurrences(of: "*", with: " ")
    }
    
}
