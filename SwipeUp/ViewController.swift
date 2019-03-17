//
//  ViewController.swift
//  SwipeUp
//
//  Created by Miguel Moldes on 26/09/2018.
//  Copyright © 2018 Miguel Moldes. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.red


        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let second = SecondViewController()

//        self.navigationController?.viewControllers = [UIViewController]()
        self.navigationController?.pushViewController(second, animated: false)
    }
}

