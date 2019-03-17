//
//  UIView+Extensions.swift
//  Bancor
//
//  Created by Matias Gualino on 10/5/17.
//  Copyright © 2017 Opits. All rights reserved.
//

import Foundation
import UIKit


extension UIView {

    @discardableResult func addConstraintEqualToSuperView(anchors: [ViewAnchors]) -> [NSLayoutConstraint] {
        guard let container = self.superview else {
            return [NSLayoutConstraint]()
        }
        self.translatesAutoresizingMaskIntoConstraints = false

        var constraints = [NSLayoutConstraint]()
        anchors.forEach { (anchor) in
            switch anchor {
            case .top(let value):
                constraints.append(self.topAnchor.constraint(equalTo: container.topAnchor, constant: value))
                break
            case .bottom(let value):
                constraints.append(self.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: value))
                break
            case .right(let value):
                constraints.append(self.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: value))
                break
            case .left(let value):
                constraints.append(self.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: value))
                break
            case .width(let value):
                constraints.append(self.widthAnchor.constraint(equalTo: container.widthAnchor, multiplier: value))
                break
            case .height(let value):
                constraints.append(self.heightAnchor.constraint(equalTo: container.heightAnchor, multiplier: value))
                break
            case .centerX(let value):
                constraints.append(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: value, constant: 0))
                break
            case .centerY(let value, let constant):
                let anchorConstant = constant != nil ? constant! : 0
                constraints.append(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: value, constant: anchorConstant))
                break
            }
        }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

    func layoutToFillSuperview() {
        guard self.superview != nil else {
            return
        }
        self.translatesAutoresizingMaskIntoConstraints = false

        self.addConstraintEqualToSuperView(anchors: [.width(1.0), .centerX(1.0), .height(1.0), .centerY(1.0, 0.0)])

    }

    @discardableResult func addFixedConstraints(_ fixedConstraints: [ViewFixedConstraint]) -> [NSLayoutConstraint] {
        var heightConstraint : NSLayoutConstraint?
        var widthConstraint : NSLayoutConstraint?

        self.translatesAutoresizingMaskIntoConstraints = false

        fixedConstraints.forEach { (fixedConstraint) in
            switch fixedConstraint {
            case .height(let value):
                heightConstraint = self.heightAnchor.constraint(equalToConstant: value)
                break
            case .width(let value):
                widthConstraint = self.widthAnchor.constraint(equalToConstant: value)
                break
            }

        }

        let constraints = [heightConstraint, widthConstraint].flatMap{ $0 }

        NSLayoutConstraint.activate(constraints)
        return constraints
    }

}

enum ViewAnchors {
    case top(CGFloat)
    case bottom(CGFloat)
    case left(CGFloat)
    case right(CGFloat)
    case width(CGFloat)
    case height(CGFloat)
    case centerX(CGFloat)
    case centerY(CGFloat, CGFloat?)
}

enum ViewFixedConstraint {
    case height(CGFloat)
    case width(CGFloat)
}
