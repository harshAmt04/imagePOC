//
//  Extensions.swift
//  imageGenationDemo
//
//  Created by Harsh on 04/12/24.
//

import Foundation
import UIKit

extension NSObject {
    var className: String {
        return String(describing: type(of: self))
    }
    
    class var className: String {
        return String(describing: self)
    }
}

extension UIViewController{
    
    static func rootVC<viewController : UIViewController>(storyboard : UIStoryboard, viewController : viewController.Type = UIViewController.self, passData: ( (viewController) -> Void )? = nil) {
        if let vc = storyboard.instantiateViewController(withIdentifier: Self.className) as? viewController{
            passData?(vc)
            AppDelegate.getAppDelegateRef()?.setRootViewController(initialViewController: vc)
        }else{
            print("ViewController not found in storyboard while insantiating.")
        }
    }
    
}

extension UIView{
    
    func showPopUpViewin(in view: UIView, with animationTime: TimeInterval = 0.25){
        self.alpha = 0
        self.frame = view.bounds

        UIView.animate(withDuration: animationTime, animations: { [ weak self ] in
            guard let self else { return }
            view.addSubview(self)
            self.frame = view.bounds
            view.bringSubviewToFront(self)
            self.alpha = 1
            self.layoutSubviews()
            
            AppDelegate.getAppDelegateRef()?.getActiveVC()?.view.endEditing(true)
        })
    }
    
}

extension UIView{
    
    func addTapGesture(configGesture: (UITapGestureRecognizer) -> Void = { _ in }, action: @escaping (UITapGestureRecognizer) -> Void = { _ in }){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_ : )))
        configGesture(tapGesture)
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(tapGesture)

        guard let key = AssociatedTapGestureActionKeys.singleTapAction else {
            fatalError("AssociatedTapGestureActionKeys.singleTapAction is nil.")
        }
        objc_setAssociatedObject(self, key, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

    }

    @objc private func handleTapGesture(_ gesture: UITapGestureRecognizer){
        guard let key = AssociatedTapGestureActionKeys.singleTapAction else {
            fatalError("AssociatedTapGestureActionKeys.singleTapAction is nil.")
        }
        if let action = objc_getAssociatedObject(self, key) as? (UITapGestureRecognizer) -> Void {
            action(gesture)
        }
        print("Tap")
    }

    private struct AssociatedTapGestureActionKeys{
        static let singleTapAction = UnsafeRawPointer(bitPattern: "singleTapAction".hashValue)
    }
    
}


extension UIImage {
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return rotatedImage ?? self
        }

        return self
    }
}
