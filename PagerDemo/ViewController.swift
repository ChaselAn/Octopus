//
//  ViewController.swift
//  PagerDemo
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit
import Octopus

class ViewController: UIViewController {

    private let octopusView = OctopusView()

    override func viewDidLoad() {
        super.viewDidLoad()

        octopusView.contentInsetAdjustmentBehavior = .never
        octopusView.targetVC = self
        view.addSubview(octopusView)
        octopusView.translatesAutoresizingMaskIntoConstraints = false
        octopusView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        octopusView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        octopusView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        octopusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

