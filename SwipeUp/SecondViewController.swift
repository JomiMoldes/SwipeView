//
// Created by Miguel Moldes on 26/09/2018.
// Copyright (c) 2018 Miguel Moldes. All rights reserved.
//

import Foundation
import UIKit

class SecondViewController : UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        self.self.createSecondView()
    }

    fileprivate var swipeManager : SwipeManager!
    private func createSecondView() {
        let view = MySwipeView(stickyPoints: [0.2, 0.5, 0.8], direction: .bottomToTop)
        view.backgroundColor = UIColor.green
        self.swipeManager = SwipeManager(container: self.view, swipeView: view, initialStep: 1)

//        self.swipeManager.start()
//        self.swipeManager.animateTo(factor: 0.5)
        view.createView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//            self.createThirdView()
//            self.swipeManager.frozen = true
        }
    }

    fileprivate var swipeThirdManager : SwipeManager?
    private func createThirdView() {
        let view = MySwipeView(stickyPoints: [0.4, 0.9], direction: .bottomToTop)
        view.backgroundColor = UIColor.green
        self.swipeThirdManager = SwipeManager(container: self.view, swipeView: view)

//        view.createView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            /*self.swipeThirdManager?.doOutAnimation {
                self.swipeThirdManager = nil
            }*/
//            self.swipeThirdManager?.animateTo(factor: 0.6)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.swipeManager.didLayoutSubviews()
        self.swipeThirdManager?.didLayoutSubviews()
    }
}
