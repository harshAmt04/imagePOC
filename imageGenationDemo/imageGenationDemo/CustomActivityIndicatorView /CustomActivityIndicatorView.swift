//
//  CustomActivityIndicatorView.swift
//  Sportskeyz
//
//  Created by Dev on 17/05/24.
//

import Foundation
import UIKit

class CustomActivityIndicatorView : UIView{
    
    @IBOutlet private weak var activityLoaderView: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialCommit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialCommit()
    }
    
    deinit{
        activityLoaderView.stopAnimating()
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
        
        activityLoaderView.startAnimating()
        
    }
}


extension UIView{
    
    func fromNib<T : UIView>() -> T? {
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(type(of: self).className, owner: self, options: nil)?.first as? T else {
            return nil
        }
        addSubview(contentView)
        contentView.fillSuperview(bounds: bounds)
        return contentView
    }
    
    func fillSuperview(bounds: CGRect) {
        self.frame = bounds
        self.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    func showPopUpViewin(in view: UIView,customAnimations : (()->Void)? = nil , with animationTime: TimeInterval = 0.25){
        
        self.alpha = 0
        self.frame = view.bounds
        view.addSubview(self)
        view.bringSubviewToFront(self)
        self.layoutSubviews()
        
        if let customAnimation = customAnimations{
            customAnimation()
        }else{
            UIView.animate(withDuration: animationTime, animations: { [ weak self ] in
                guard let self = self else { return }
                
                self.alpha = 1
                
            })
        }
    }
    
}

fileprivate var activityIndicatorView : CustomActivityIndicatorView?

extension UIViewController{
    
    func showActivityIndicator(){
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
        activityIndicatorView = CustomActivityIndicatorView()
        activityIndicatorView?.showPopUpViewin(in: self.view)
    }
    
    func hideActivityIndicator(){
        activityIndicatorView?.removeFromSuperview()
        activityIndicatorView = nil
    }
    
}
