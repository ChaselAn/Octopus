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
    private var isShowAll: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

//        if #available(iOS 11.0, *) {
//            octopusView.contentInsetAdjustmentBehavior = .never
//        }
        octopusView.dataSource = self
        view.addSubview(octopusView)
        octopusView.translatesAutoresizingMaskIntoConstraints = false
        octopusView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        octopusView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        octopusView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        octopusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    @objc private func segmentViewClicked() {
        isShowAll = !isShowAll
        octopusView.updateSegmentViewHeight(animated: true)
    }

}

extension SegmentViewController: OctopusViewDataSource {
    func numberOfPages(in octopusView: OctopusView) -> Int {
        return 10
    }

    func octopusView(_ octopusView: OctopusView, pageViewControllerAt index: Int) -> OctopusPage {
        let vc = OctopusDataViewController.init(scrollView: TestTableView())
        addChild(vc)
        vc.index = index
        return vc
    }

    func headerView(in octopusView: OctopusView) -> UIView? {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }

    func headerViewHeight(in octopusView: OctopusView) -> CGFloat {
        return 150
    }

    func segmentView(in octopusView: OctopusView) -> UIView? {
        let view = UIView()
        view.backgroundColor = .green
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(segmentViewClicked)))
        return view
    }

    func segmentViewHeight(in octopusView: OctopusView) -> CGFloat {
        return isShowAll ? 100 : 50
    }
}
