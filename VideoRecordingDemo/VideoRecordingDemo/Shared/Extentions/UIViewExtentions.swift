//
//  UIViewExtentions.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright © 2017 Dima Tsurkan. All rights reserved.
//

import UIKit

@IBDesignable extension UIView {
    
    @IBInspectable var borderColor: UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            else {
                return nil
            }
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
}

extension UIView {
    
    func g_addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 1
    }
    
    func g_addRoundBorder() {
        layer.borderWidth = 1
        layer.borderColor = Config.Grid.FrameView.borderColor.cgColor
        layer.cornerRadius = 3
        clipsToBounds = true
    }
    
    func g_quickFade(visible: Bool = true) {
        UIView.animate(withDuration: 0.1, animations: {
            self.alpha = visible ? 1 : 0
        })
    }
    
    func g_fade(visible: Bool) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = visible ? 1 : 0
        })
    }
}

extension UIView {
    
    func g_ancestors() -> [UIView] {
        var current = self
        var views = [current]
        while let superview = current.superview {
            views.append(superview)
            current = superview
        }
        
        return views
    }
    
    func g_commonAncestor(view: UIView) -> UIView? {
        let viewAncestors = view.g_ancestors()
        
        return g_ancestors()
            .filter {
                return viewAncestors.contains($0)
            }.first
    }
    
    @discardableResult func g_pin(on type1: NSLayoutAttribute,
                                  view: UIView? = nil, on type2: NSLayoutAttribute? = nil,
                                  constant: CGFloat = 0,
                                  priority: Float? = nil) -> NSLayoutConstraint? {
        guard let view = view ?? superview,
            let commonAncestor = g_commonAncestor(view: view)
            else { return nil }
        
        translatesAutoresizingMaskIntoConstraints = false
        let type2 = type2 ?? type1
        let constraint = NSLayoutConstraint(item: self, attribute: type1,
                                            relatedBy: .equal,
                                            toItem: view, attribute: type2,
                                            multiplier: 1, constant: constant)
        if let priority = priority {
            constraint.priority = UILayoutPriority(rawValue: priority)
        }
        
        commonAncestor.addConstraint(constraint)
        
        return constraint
    }
    
    func g_pinEdges(view: UIView? = nil) {
        g_pin(on: .top, view: view)
        g_pin(on: .bottom, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
    
    func g_pin(size: CGSize) {
        g_pin(width: size.width)
        g_pin(height: size.height)
    }
    
    func g_pin(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width))
    }
    
    func g_pin(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    func g_pin(greaterThanHeight height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: height))
    }
    
    func g_pinHorizontally(view: UIView? = nil, padding: CGFloat) {
        g_pin(on: .left, view: view, constant: padding)
        g_pin(on: .right, view: view, constant: -padding)
    }
    
    func g_pinUpward(view: UIView? = nil) {
        g_pin(on: .top, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
    
    func g_pinDownward(view: UIView? = nil) {
        g_pin(on: .bottom, view: view)
        g_pin(on: .left, view: view)
        g_pin(on: .right, view: view)
    }
    
    func g_pinCenter(view: UIView? = nil) {
        g_pin(on: .centerX, view: view)
        g_pin(on: .centerY, view: view)
    }
    
    func g_pinXCenter(view: UIView? = nil) {
        g_pin(on: .centerX, view: view)
    }
}
