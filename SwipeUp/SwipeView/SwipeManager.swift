//
// Created by Miguel Moldes on 26/09/2018.
// Copyright (c) 2018 Brubank. All rights reserved.
//

import Foundation
import UIKit

class SwipeManager {

    fileprivate unowned let swipeView: SwipeView
    var forceBackToZero = true
    fileprivate var doLayout = true

    fileprivate var _currentSwipeStep : Int = 0
    var currentSwipeStep : Int {
        get {
            return self._currentSwipeStep
        }
        set {
            self.doLayout = false
            if newValue >= self.swipeView.stickyCount - 1 {
                self._currentSwipeStep = self.swipeView.stickyCount - 1
                return
            }
            if newValue <= 0 {
                self._currentSwipeStep = 0
                return
            }
            self._currentSwipeStep = newValue
        }
    }

    fileprivate var swipeHandler : SwipeEventHandler!
    fileprivate var orientationManager : SwipeOrientationManager!

    init(swipeView: SwipeView, initialStep: Int = 0) {
        self._currentSwipeStep = initialStep
        self.swipeView = swipeView
        self.setupOrientationManager()
        self.setupSwipeHandler()
        self.addListeners()
    }

    func refreshView() {
        let x = self.swipeView.getStickyPointForXCenter(index: self.currentSwipeStep)
        let y = self.swipeView.getStickyPointForYCenter(index: self.currentSwipeStep)

        self.setPosition(x: x, y: y)
    }

    func doEntranceAnimation() {
        self.setPosition(x: self.orientationManager.initialEntranceX, y: self.orientationManager.initialEntranceY)
        UIView.animate(withDuration: 0.5) {
            self.refreshView()
        }
    }

    //MARK - Private

    fileprivate func setupOrientationManager() {
        self.orientationManager = isVertical() ? SwipeVerticalManager(swipeView: self.swipeView, delegate: self) : SwipeHorizontalManager(swipeView: self.swipeView, delegate: self)
    }

    fileprivate func isVertical() -> Bool {
        return self.swipeView.direction == .bottomToTop || self.swipeView.direction == .topToBottom
    }

    fileprivate func setupSwipeHandler() {
        switch self.swipeView.direction {
        case .bottomToTop:
            self.swipeHandler = SwipeEventHandlerBottomToTop(delegate: self)
        case .topToBottom:
            self.swipeHandler = SwipeEventHandlerTopToBottom(delegate: self)
        case .leftToRight:
            self.swipeHandler = SwipeEventHandlerLeftToRight(delegate: self)
        case .rightToLeft:
            self.swipeHandler = SwipeEventHandlerRightToLeft(delegate: self)
        }
    }

    fileprivate var lastViewFrame : CGRect?
    fileprivate func setPosition(x: CGFloat, y: CGFloat) {
        guard let superview = self.swipeView.superview else {
            return
        }
        self.swipeView.frame = CGRect(x: superview.frame.width * x, y: superview.frame.height * y, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
        self.lastViewFrame = self.swipeView.frame
    }


    fileprivate func addListeners() {
        self.swipeHandler.addSwipeGesture(view: self.swipeView)
        self.addTapGesture()
    }

    fileprivate var tapGesture : UITapGestureRecognizer?
    fileprivate func addTapGesture() {
        if let gesture = self.tapGesture {
            self.swipeView.removeGestureRecognizer(gesture)
            self.tapGesture = nil
        }
        guard self.currentSwipeStep == 0 else {
            return
        }
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapped(_:)))
        self.tapGesture = gesture
        self.swipeView.addGestureRecognizer(gesture)
    }

    @objc fileprivate func tapped(_ gesture: UITapGestureRecognizer) {
        guard self._frozen == false else {
            return
        }
        self.doLayout = false
        self.incrementStep()
    }

    fileprivate func updateView() {
        UIView.animate(withDuration: 0.3) {
            self.refreshView()
        }

    }

    fileprivate var _frozen: Bool = false

}

extension SwipeManager: SwipeManagerProtocol {

    var frozen: Bool {
        get {
            return self._frozen
        }
        set {
            self._frozen = newValue
            self.swipeHandler.frozen = newValue
        }
    }

    func incrementStep() {
        self.currentSwipeStep += 1
        self.updateView()
        self.addTapGesture()
    }

    func decrementStep() {
        defer {
            self.updateView()
            self.addTapGesture()
        }
        if self.forceBackToZero {
            self.currentSwipeStep = 0
            return
        }
        self.currentSwipeStep -= 1
    }

    func scroll(diff: CGFloat) {
        self.orientationManager.scroll(diff: diff)
    }

    func releaseScroll(diff: CGFloat) {
        defer {
            self.lastViewFrame = self.swipeView.frame
            self.addTapGesture()
        }
        if self.isVertical() {
            let nextY = self.swipeView.frame.origin.y + diff
            self.orientationManager.updateCurrentStepAfterScrolling(value: nextY)
            return
        }
        let nextX = self.swipeView.frame.origin.x + diff
        self.orientationManager.updateCurrentStepAfterScrolling(value: nextX)
    }

    func didLayoutSubviews() {
        guard self.doLayout else {
            if let frame = self.lastViewFrame {
                self.swipeView.frame = frame
            }
            return
        }
        self.refreshView()
    }

    func doOutAnimation(completion: @escaping () -> Void) {
        self.doLayout = false
        UIView.animate(withDuration: 0.3, animations: {
            self.setPosition(x: self.orientationManager.initialEntranceX, y: self.orientationManager.initialEntranceY)
        }, completion: {
            _ in
            completion()
        })
    }

    func animateTo(factor: CGFloat) {
        guard factor >= -1 && factor <= 1 else {
            return
        }
        self.doLayout = false
        let realFactor = self.swipeView.realCenterBy(factor)
        UIView.animate(withDuration: 0.3) {
            self.setPosition(x: self.orientationManager.horizontalMovement * realFactor, y: self.orientationManager.verticalMovement * realFactor)
        }
        if self.isVertical() {
            self.orientationManager.updateCurrentStepAfterScrolling(value: self.orientationManager.verticalMovement * realFactor)
            return
        }
        self.orientationManager.updateCurrentStepAfterScrolling(value: self.orientationManager.horizontalMovement * realFactor)
        self.addTapGesture()
    }

}

fileprivate class SwipeOrientationManager {

    fileprivate unowned let swipeView : SwipeView
    fileprivate unowned let delegate : SwipeManagerProtocol

    var initialEntranceX : CGFloat {
        get {
            return 0.0
        }
    }

    var initialEntranceY : CGFloat {
        get {
            return 0.0
        }
    }

    var horizontalMovement : CGFloat { get { return 0.0 } }

    var verticalMovement : CGFloat { get { return 0.0 } }

    init(swipeView: SwipeView,delegate: SwipeManagerProtocol) {
        self.swipeView = swipeView
        self.delegate = delegate
    }

    func scroll(diff: CGFloat) {

    }

    func updateCurrentStepAfterScrolling(value: CGFloat) {

    }

    func filterByBounds(next: CGFloat, size: CGFloat) -> CGFloat {
        let max: CGFloat = self.swipeView.getHighestPoint() * size
        let min: CGFloat = self.swipeView.getLowestPoint() * size

        let absmax: CGFloat = abs(max)
        let absmin: CGFloat = abs(min)
        let absNext: CGFloat = abs(next)
        if absNext <= absmax {
            return max
        }
        return absNext >= absmin ? min : next
    }

}

fileprivate class SwipeVerticalManager : SwipeOrientationManager {

    override var initialEntranceY : CGFloat {
        get {
            return self.swipeView.direction == .bottomToTop ? 1.0 : -1.0
        }
    }

    override var verticalMovement : CGFloat { get { return 1.0 } }

    override func scroll(diff: CGFloat) {
        var nextY = self.swipeView.frame.origin.y + diff
        nextY = self.filterByBounds(next: nextY, size: self.swipeView.frame.height)
        self.swipeView.frame = CGRect(x: self.swipeView.frame.origin.x, y: nextY, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
    }

    override func updateCurrentStepAfterScrolling(value: CGFloat) {
        let nextValue: CGFloat = abs(self.filterByBounds(next: value, size: self.swipeView.frame.height))
        for i in 0..<self.swipeView.stickyCount {
            var stickY: CGFloat = self.swipeView.getStickyPointForYCenter(index: i)
            stickY = abs(self.swipeView.frame.height * stickY)
            if nextValue >= stickY {
                break
            }
            if nextValue < stickY {
                self.delegate.currentSwipeStep = i
            }
        }
    }

}

fileprivate class SwipeHorizontalManager : SwipeOrientationManager {

    override var initialEntranceX : CGFloat {
        get {
            return self.swipeView.direction == .leftToRight ? -1.0 : 1.0
        }
    }

    override var horizontalMovement : CGFloat { get { return 1.0 } }

    override func scroll(diff: CGFloat) {
        var nextX = self.swipeView.frame.origin.x + diff
        nextX = self.filterByBounds(next: nextX, size: self.swipeView.frame.width)
        self.swipeView.frame = CGRect(x: nextX, y: self.swipeView.frame.origin.y, width: self.swipeView.frame.width, height: self.swipeView.frame.height)
    }

    override func updateCurrentStepAfterScrolling(value: CGFloat) {
        let nextValue: CGFloat = abs(self.filterByBounds(next: value, size: self.swipeView.frame.width))
        for i in 0..<self.swipeView.stickyCount {
            var stickX: CGFloat = self.swipeView.getStickyPointForXCenter(index: i)
            stickX = abs(self.swipeView.frame.width * stickX)
            if nextValue >= stickX {
                break
            }
            if nextValue < stickX {
                self.delegate.currentSwipeStep = i
            }
        }

    }

}

protocol SwipeManagerProtocol : class {

    var frozen: Bool { get set }

    var currentSwipeStep : Int { get set }

    func incrementStep()

    func decrementStep()

    func scroll(diff: CGFloat)

    func releaseScroll(diff: CGFloat)

    func doOutAnimation(completion: @escaping () -> Void)

    func animateTo(factor: CGFloat)

    func didLayoutSubviews()

}
