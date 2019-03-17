//
// Created by Miguel Moldes on 26/09/2018.
// Copyright (c) 2018 Miguel Moldes. All rights reserved.
//

import Foundation
import UIKit

class MySwipeView : SwipeVerticalView {

    func createView() {
        let view = UIView()
        self.contentContainer.addSubview(view)

        view.addConstraintEqualToSuperView(anchors: [.width(0.5), .centerX(1.0), .height(0.1), .top(10.0)])
        view.backgroundColor = UIColor.red

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
    }

    @objc fileprivate func tapped(_ tap : UITapGestureRecognizer) {
        print("tapped 2")
    }

}
