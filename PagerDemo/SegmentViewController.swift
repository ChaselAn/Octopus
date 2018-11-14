//
//  SegmentViewController.swift
//  PagerDemo
//
//  Created by ancheng on 2018/11/14.
//  Copyright © 2018 chaselan. All rights reserved.
//

import UIKit
import Octopus

class SegmentViewController: UIViewController {

    private let octopusView = OctopusView()

    override func viewDidLoad() {
        super.viewDidLoad()

//        if #available(iOS 11.0, *) {
//            octopusView.contentInsetAdjustmentBehavior = .never
//        }
        octopusView.delegate = self
        view.addSubview(octopusView)
        octopusView.translatesAutoresizingMaskIntoConstraints = false
        octopusView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        octopusView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        octopusView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        octopusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

}

extension SegmentViewController: OctopusViewDelegate {
    func tableHeaderView(in octopusView: OctopusView) -> UIView? {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }

    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat {
        return 150
    }
}
