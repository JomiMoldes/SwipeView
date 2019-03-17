//
// Created by Miguel Moldes on 26/09/2018.
// Copyright (c) 2018 Brubank. All rights reserved.
//

import Foundation
import UIKit

enum SwipeDirection: Int {
    case bottomToTop, topToBottom, leftToRight, rightToLeft
}

class SwipeVerticalView: SwipeView {

    override var direction : SwipeDirection {
        get {
            return self._direction == .bottomToTop || self._direction == .topToBottom ? self._direction : .bottomToTop
        }
        set {
            self._direction = newValue
        }
    }

    override func getStickyPointForXCenter(index: Int) -> CGFloat {
        return 0.0
    }

    override var directionMultiplier : CGFloat {
        get {
            return self.direction == .bottomToTop ? 1.0 : -1.0
        }
    }

    override var maxCenterPoint : CGFloat {
        get {
            return self.direction == .bottomToTop ? super.maxCenterPoint : 1.0
        }
    }

}

class SwipeHorizontalView : SwipeView {

    override var direction : SwipeDirection {
        get {
            return self._direction == .leftToRight || self._direction == .rightToLeft ? self._direction : .leftToRight
        }
        set {
            self._direction = newValue
        }
    }

    override var directionMultiplier : CGFloat {
        get {
            return self.direction == .rightToLeft ? super.directionMultiplier : -1.0
        }
    }

    override var maxCenterPoint : CGFloat {
        get {
            return self.direction == .rightToLeft ? super.maxCenterPoint : 1.0
        }
    }

    override func getStickyPointForYCenter(index: Int) -> CGFloat {
        return 0.0
    }

    override func setupBackgroundConstraints(view: UIView) {
        view.addConstraintEqualToSuperView(anchors: [.width(1.0), .centerY(1.0, 0.0), .height(1.0)])
        view.addConstraintEqualToSuperView(anchors: [ self.direction == .leftToRight ? .left(0.0) : .right(0.0)])
    }

    override func setupSwipeLineConstraints(view: UIView) {
        view.addConstraintEqualToSuperView(anchors: [.height(0.15), .centerY(1.0, 0.0), self.direction == .leftToRight ? .right(-5.0) : .left(5.0)])
        view.addFixedConstraints([.width(5.0)])
    }

}

class SwipeView: UIView, SwipeableViewProtocol {

    fileprivate var _stickyPoints: [CGFloat] = [0.0, 1.0]

    fileprivate var minPoint: CGFloat = 0.05
    var roundedBackgroundColor = UIColor.white

    fileprivate var _direction : SwipeDirection = .bottomToTop
    var direction : SwipeDirection {
        get {
            return self._direction
        }
        set {
            self._direction = newValue
        }
    }

    var stickyCount : Int {
        get {
            return self._stickyPoints.count
        }
    }

    var directionMultiplier : CGFloat {
        get {
            return 1.0
        }
    }

    var maxCenterPoint : CGFloat {
        get {
            return 3.0
        }
    }

    var stickyPoints: [CGFloat] {
        get {
            return self._stickyPoints
        }
        set {
            self._stickyPoints = newValue.map ({
                value in
                if value > 1 {
                    return 1
                }
                if value < self.minPoint {
                    return self.minPoint
                }
                return value
            })
        }
    }

    var animateEntrance = true

    var frozen : Bool {
        get { return self.swipeManager?.frozen ?? false }
        set { self.swipeManager.frozen = newValue }
    }

    fileprivate var swipeManager : SwipeManager!

    init(stickyPoints: [CGFloat], direction: SwipeDirection, initialStep: Int) {
        super.init(frame: CGRect.zero)
        self.stickyPoints = stickyPoints
        self.direction = direction
        self.setupContentContainer()
        self.swipeManager = SwipeManager(swipeView: self, initialStep: initialStep)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    fileprivate (set) var contentContainer : UIView!
    private func setupContentContainer() {
        let view = UIView()
        self.addSubview(view)

        view.layoutToFillSuperview()
        self.contentContainer = view
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        self.bg?.removeFromSuperview()
        self.swipeLine?.removeFromSuperview()
        self.addSwipeLine()
        self.addBackground()
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        guard self.animateEntrance else {
            self.swipeManager.refreshView()
            return
        }
        self.swipeManager.doEntranceAnimation()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.swipeManager.didLayoutSubviews()
    }

    fileprivate var bg : UIView?
    fileprivate func addBackground() {
        let view = UIView()
        view.backgroundColor = UIColor.white
        self.addSubview(view)

        self.setupBackgroundConstraints(view: view)
        view.layer.cornerRadius = 10.0
        view.layer.masksToBounds = false

        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: -1, height: 1)
        view.layer.shadowRadius = 3
        view.layer.shadowPath = UIBezierPath(rect: bounds).cgPath
        view.layer.shouldRasterize = true
        view.layer.rasterizationScale = UIScreen.main.scale

        self.sendSubview(toBack: view)
        self.bg = view
    }

    fileprivate func setupBackgroundConstraints(view: UIView) {
        view.addConstraintEqualToSuperView(anchors: [.width(1.0), .centerX(1.0), .height(1.0)])
        view.addConstraintEqualToSuperView(anchors: [ self.direction == .bottomToTop ? .bottom(0.0) : .top(0.0)])
    }

    fileprivate var swipeLine : UIView?
    fileprivate func addSwipeLine() {
        guard self.stickyCount > 1 else {
            return
        }
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.addSubview(view)

        self.setupSwipeLineConstraints(view: view)
        view.layer.cornerRadius = 2.5
        view.layer.masksToBounds = true
        self.sendSubview(toBack: view)
        self.swipeLine = view
    }

    fileprivate func setupSwipeLineConstraints(view: UIView) {
        view.addConstraintEqualToSuperView(anchors: [.width(0.1), .centerX(1.0), self.direction == .bottomToTop ? .top(7.0) : .bottom(-7.0)])
        view.addFixedConstraints([.height(5.0)])
    }

    fileprivate func getStickyPointFor(index: Int) -> CGFloat {
        var value : CGFloat = 0
        if index < 0 {
            value = self._stickyPoints[0]
        }
        if index >= (self._stickyPoints.count - 1) {
            value = self._stickyPoints[self._stickyPoints.count - 1]
        }
        value = self._stickyPoints[index]
        return self.realCenterBy(value)
    }

    func realCenterBy(_ factor: CGFloat) -> CGFloat {
        let total: CGFloat = 1
        let max: CGFloat = 1
        let pct: CGFloat = total * factor
        return self.directionMultiplier * (max - pct)
    }

    func getStickyPointForXCenter(index: Int) -> CGFloat {
        return self.getStickyPointFor(index: index)
    }

    func getStickyPointForYCenter(index: Int) -> CGFloat {
        return self.getStickyPointFor(index: index)
    }

    func getHighestPoint() -> CGFloat {
        return self.getStickyPointFor(index: self.stickyPoints.count - 1)
    }

    func getLowestPoint() -> CGFloat {
        return self.getStickyPointFor(index: 0)
    }

}

protocol SwipeableViewProtocol {

    var stickyPoints: [CGFloat] { get set }

}