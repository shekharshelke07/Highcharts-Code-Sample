//
//  UIView + extension.swift
//  Highcharts-Code-Sample
//
//  Created by Shekhar Shelke on 03/11/22.
//

import Foundation
import UIKit

extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat = 6.0)
    {
        clipsToBounds = true
        layer.cornerRadius = radius
        layer.maskedCorners = CACornerMask(rawValue: corners.rawValue)
    }
    
    /// for corner radius to all corners
    func roundAllCorners(radius: CGFloat = 6.0)
    {
        roundCorners(corners: .allCorners, radius: radius)
    }
    
    /// for border to all sides with specified corner radius
    func applyBorderWithCornerRadius(_ radius: CGFloat = 6.0, borderWidth: CGFloat = 1.0, borderColor: UIColor = .black)
    {
        layer.cornerRadius = radius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }

    func bindFrameToSuperviewBounds()
    {
        bindFrameToSuperviewBounds(top: 0, bottom: 0, leading: 0, trailing: 0)
    }

    func bindFrameToSuperviewBounds(top: CGFloat, bottom: CGFloat, leading: CGFloat, trailing: CGFloat)
    {
        bindFrameToSuperviewConditionally(top: top, bottom: bottom, leading: leading, trailing: trailing)
    }
    
    func bindFrameToSuperviewConditionally(top: CGFloat?, bottom: CGFloat?, leading: CGFloat?, trailing: CGFloat?)
    {
        guard let superview = self.superview else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false
        if let top = top {
            self.topAnchor.constraint(equalTo: superview.topAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            self.bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -bottom).isActive = true
        }
        if let leading = leading {
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: leading).isActive = true
        }
        
        if let trailing = trailing {
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -trailing).isActive = true
        }
    }
}
