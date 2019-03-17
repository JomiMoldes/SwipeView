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
        let view = MySwipeView(stickyPoints: [0.2, 0.5, 0.8], direction: .leftToRight, initialStep: 2)
        self.view.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false

        view.widthAnchor.constraint(equalTo: self.view.widthAnchor).isActive = true
        view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true

        view.backgroundColor = UIColor.green
        view.createView()
        /*DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            view.frozen = true
        }*/
    }
}
