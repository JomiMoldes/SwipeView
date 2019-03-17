//
// Created by Miguel Moldes on 26/09/2018.
// Copyright (c) 2018 Brubank. All rights reserved.
//

import Foundation
import UIKit

class SwipeEventHandler {

    unowned let delegate : SwipeManagerProtocol

    fileprivate var swipeGestures = [UISwipeGestureRecognizer]()
    var panGesture : UIPanGestureRecognizer!

    let scrollSpeedAllowed: CGFloat = 20.0

    init(delegate : SwipeManagerProtocol) {
        self.delegate = delegate
    }

    @objc func swiped(_ gesture: UISwipeGestureRecognizer) {

    }

    func addSwipeGesture(view: UIView) {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(_:)))
        for gesture in self.swipeGestures {
            pan.require(toFail: gesture)
        }
        view.addGestureRecognizer(pan)
        self.panGesture = pan
    }

    var initialCenter = CGPoint()
    var lastTranslation: CGFloat?

    var frozen = false

    fileprivate func handleVerticalPan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else {
            return
        }

        let piece = gesture.view!
        let translation = gesture.translation(in: piece.superview)

        func scrolledTooFast() {
            gesture.isEnabled = false
            if translation.y < 0 {
                self.delegate.incrementStep()
            } else {
                self.delegate.decrementStep()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gesture.isEnabled  = true
                self.lastTranslation = nil
            }
        }

        guard gesture.state != .ended else {
            if let last = self.lastTranslation {
                self.delegate.releaseScroll(diff: translation.y - last)
            }
            self.lastTranslation = nil
            return
        }

        if gesture.state == .began {
            self.initialCenter = piece.center
        }

        if gesture.state != .cancelled {
            if let last = self.lastTranslation {
                if abs(last - translation.y) > self.scrollSpeedAllowed {
                    scrolledTooFast()
                } else {
                    self.panVertically(diff: translation.y - last)
                }
            } else {
                self.panVertically(diff: translation.y)
            }
            self.lastTranslation = translation.y
        }

    }

    fileprivate func handleHorizontalPan(_ gesture: UIPanGestureRecognizer) {
        guard gesture.view != nil else {
            return
        }

        let piece = gesture.view!
        let translation = gesture.translation(in: piece.superview)

        func scrolledTooFast() {
            gesture.isEnabled = false
            if translation.x < 0 {
                self.delegate.incrementStep()
            } else {
                self.delegate.decrementStep()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                gesture.isEnabled  = true
                self.lastTranslation = nil
            }
        }

        guard gesture.state != .ended else {
            if let last = self.lastTranslation {
                self.delegate.releaseScroll(diff: translation.x - last)
            }
            self.lastTranslation = nil
            return
        }

        if gesture.state == .began {
            self.initialCenter = piece.center
        }

        if gesture.state != .cancelled {
            if let last = self.lastTranslation {
                if abs(last - translation.x) > self.scrollSpeedAllowed {
                    scrolledTooFast()
                } else {
                    self.panHorizontally(diff: translation.x - last)
                }
            } else {
                self.panHorizontally(diff: translation.x)
            }
            self.lastTranslation = translation.x
        }
    }

    @objc func pan(_ gesture: UIPanGestureRecognizer) {
        guard self.frozen == false else {
            return
        }
    }

    func panVertically(diff: CGFloat) {
        guard self.frozen == false else {
            return
        }
        self.delegate.scroll(diff: diff)
    }

    func panHorizontally(diff: CGFloat) {
        guard self.frozen == false else {
            return
        }
        self.delegate.scroll(diff: diff)
    }
}

class SwipeEventHandlerBottomToTop : SwipeEventHandler {

    override func swiped(_ gesture: UISwipeGestureRecognizer) {
        let direction = gesture.direction
        guard direction == .up || direction == .down && self.frozen == false else {
            return
        }

        if direction == .up {
            self.delegate.incrementStep()
            return
        }
        self.delegate.decrementStep()
    }

    override func pan(_ gesture: UIPanGestureRecognizer) {
        guard self.frozen == false else {
            return
        }
        super.handleVerticalPan(gesture)
    }

    override func addSwipeGesture(view: UIView) {
        super.addSwipeGesture(view: view)
        let upGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        upGesture.direction = .up
        upGesture.require(toFail: self.panGesture)
        view.addGestureRecognizer(upGesture)

        let downGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        downGesture.direction = .down
        view.addGestureRecognizer(downGesture)

        upGesture.require(toFail: self.panGesture)
        downGesture.require(toFail: self.panGesture)

        self.swipeGestures = [upGesture, downGesture]

    }
}

class SwipeEventHandlerTopToBottom : SwipeEventHandler {

    override func swiped(_ gesture: UISwipeGestureRecognizer) {
        let direction = gesture.direction
        guard direction == .up || direction == .down && self.frozen == false else {
            return
        }

        if direction == .down {
            self.delegate.incrementStep()
            return
        }
        self.delegate.decrementStep()
    }

    override func pan(_ gesture: UIPanGestureRecognizer) {
        guard self.frozen == false else {
            return
        }
        super.handleVerticalPan(gesture)
    }

    override func addSwipeGesture(view: UIView) {
        let upGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        upGesture.direction = .up
        view.addGestureRecognizer(upGesture)

        let downGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        downGesture.direction = .down
        view.addGestureRecognizer(downGesture)

        self.swipeGestures = [upGesture, downGesture]

        super.addSwipeGesture(view: view)
    }

}

class SwipeEventHandlerLeftToRight : SwipeEventHandler {

    override func swiped(_ gesture: UISwipeGestureRecognizer) {
        let direction = gesture.direction
        guard direction == .left || direction == .right && self.frozen == false else {
            return
        }

        if direction == .right {
            self.delegate.incrementStep()
            return
        }
        self.delegate.decrementStep()
    }

    override func pan(_ gesture: UIPanGestureRecognizer) {
        guard self.frozen == false else {
            return
        }
        super.handleHorizontalPan(gesture)
    }

    override func addSwipeGesture(view: UIView) {
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        leftGesture.direction = .left
        view.addGestureRecognizer(leftGesture)

        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        rightGesture.direction = .right
        view.addGestureRecognizer(rightGesture)

        self.swipeGestures = [leftGesture, rightGesture]

        super.addSwipeGesture(view: view)
    }

}

class SwipeEventHandlerRightToLeft : SwipeEventHandler {

    override func swiped(_ gesture: UISwipeGestureRecognizer) {
        let direction = gesture.direction
        guard direction == .left || direction == .right && self.frozen == false else {
            return
        }

        if direction == .left {
            self.delegate.incrementStep()
            return
        }
        self.delegate.decrementStep()
    }

    override func pan(_ gesture: UIPanGestureRecognizer) {
        guard self.frozen == false else {
            return
        }
        super.handleHorizontalPan(gesture)
    }

    override func addSwipeGesture(view: UIView) {
        let leftGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        leftGesture.direction = .left
        view.addGestureRecognizer(leftGesture)

        let rightGesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swiped(_:)))
        rightGesture.direction = .right
        view.addGestureRecognizer(rightGesture)

        self.swipeGestures = [leftGesture, rightGesture]

        super.addSwipeGesture(view: view)
    }

}

