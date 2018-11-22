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
        octopusView.delegate = self
        automaticallyAdjustsScrollViewInsets = false
        view.addSubview(octopusView)
        octopusView.translatesAutoresizingMaskIntoConstraints = false
        octopusView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        octopusView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        octopusView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        octopusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        octopusView.handUpOffsetY = (navigationController?.navigationBar.bounds.height ?? 0) + UIApplication.shared.statusBarFrame.height
//        octopusView.tableView.contentInset = UIEdgeInsets(top: 200, left: 0, bottom: 0, right: 0)

    }
    
    @objc private func segmentViewClicked() {
        isShowAll = !isShowAll
        octopusView.updateSegmentViewHeight(animated: true)
    }

    private var vcs: [Int: OctopusDataViewController] = [:]

//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//
//        if #available(iOS 11.0, *) {
//            octopusView.layoutIfNeeded()
//        } else {
//            octopusView.tableView.setContentOffset(CGPoint(x: 0, y: -200), animated: false)
//        }
//    }

}

extension SegmentViewController: OctopusViewDataSource {
    func numberOfPages(in octopusView: OctopusView) -> Int {
        return 10
    }

    func octopusView(_ octopusView: OctopusView, pageViewControllerAt index: Int) -> OctopusPage {
        if let cacheVC = vcs[index] {
            return cacheVC
        }
        let vc = OctopusDataViewController()
        vc.index = index
        vcs[index] = vc
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

extension SegmentViewController: OctopusViewDelegate {

    func octopusViewDidScroll(_ octopusView: OctopusView) {
//        print("------------", octopusView.isHandUp)
    }
}
