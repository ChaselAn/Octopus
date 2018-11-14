//
//  OctopusView.swift
//  Octopus
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

public protocol OctopusViewDelegate: class {

    func tableHeaderView(in octopusView: OctopusView) -> UIView?
    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat

}

extension OctopusViewDelegate {
    func tableHeaderView(in octopusView: OctopusView) -> UIView? { return nil }
    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat { return 0 }
}

public class OctopusView: UIView {

    public weak var delegate: OctopusViewDelegate?

    @available(iOS 11.0, *)
    public var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior {
        get {
            return tableView.contentInsetAdjustmentBehavior
        }
        set {
            tableView.contentInsetAdjustmentBehavior = newValue
        }
    }

    private var headerViewHeight: CGFloat {
        return delegate?.tableHeaderViewHeight(in: self) ?? 0
    }

    private lazy var tableView: OctopusMainTableView = {
        let tableView = OctopusMainTableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        if let headerView = delegate?.tableHeaderView(in: self), let headerViewHeight = delegate?.tableHeaderViewHeight(in: self) {
            headerView.frame = CGRect(x: 0, y: 0, width: 0, height: headerViewHeight)
            tableView.tableHeaderView = headerView
        }
        tableView.estimatedRowHeight = UIScreen.main.bounds.height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "OctopusViewCell")
        return tableView
    }()

    private var listContainerView = OctopusListContainerView()
    private var observations: [NSKeyValueObservation] = []

    private var currentScrollingListView: UIScrollView?

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)

        guard newSuperview != nil else { return }

        addSubview(tableView)
        tableView.constraintEqualToSuperView()

        listContainerView.mainTableView = tableView

        //        let firstVC = OctopusDataViewController()
        //        let secondVC = OctopusDataViewController()
        //        let vcs: [UIViewController] = [firstVC, secondVC]
        //        let firstView = firstVC.tableView
        //        firstView.backgroundColor = UIColor.green
        //        let secondView = secondVC.tableView
        //        secondView.backgroundColor = UIColor.yellow
        //        listContainerView.dataView = [firstView, secondView]
        //        vcs.forEach({ [weak self] in
        //            self?.targetVC?.addChild($0)
        //        })

        listContainerView.dataView.forEach({
            let observation = $0.observe(\.contentOffset, options: [.old, .new], changeHandler: { [weak self] (scrollView, change) in
                guard let strongSelf = self else { return }
                guard change.oldValue != change.newValue else { return }
                strongSelf.currentScrollingListView = scrollView
                strongSelf.preferredProcessListViewDidScroll(scrollView: scrollView)
            })
            observations.append(observation)
        })
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        listContainerView.heightAnchor.constraint(equalToConstant: tableView.bounds.height).isActive = true
    }

    private func preferredProcessListViewDidScroll(scrollView: UIScrollView) {
        let contentInsetTop: CGFloat
        if #available(iOS 11.0, *) {
            contentInsetTop = tableView.adjustedContentInset.top
        } else {
            contentInsetTop = tableView.contentInset.top
        }

        if tableView.contentOffset.y < headerViewHeight - contentInsetTop {
            guard let currentScrollingListView = currentScrollingListView else { return }
            currentScrollingListView.contentOffset = CGPoint.zero
            currentScrollingListView.showsVerticalScrollIndicator = false
        } else {
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight - contentInsetTop)
            currentScrollingListView!.showsVerticalScrollIndicator = true
        }
    }
}

extension OctopusView: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OctopusViewCell", for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.contentView.addSubview(listContainerView)
        listContainerView.constraintEqualToSuperView()
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect.zero)
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
}

extension OctopusView: UITableViewDelegate {

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking {
            listContainerView.collectionView.isScrollEnabled = false
        }

        preferredProcessMainTableViewDidScroll(scrollView)
    }

    private func preferredProcessMainTableViewDidScroll(_ scrollView: UIScrollView) {

        print("--------- ", tableView.contentOffset.y)
        let contentInsetTop: CGFloat
        if #available(iOS 11.0, *) {
            contentInsetTop = tableView.adjustedContentInset.top
        } else {
            contentInsetTop = tableView.contentInset.top
        }

        if let currentScrollingListView = currentScrollingListView, currentScrollingListView.contentOffset.y > 0 {
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight - contentInsetTop)
        }

        if tableView.contentOffset.y < headerViewHeight - contentInsetTop {
            for scrollView in listContainerView.dataView {
                scrollView.contentOffset = CGPoint.zero
            }
        }

        if scrollView.contentOffset.y > headerViewHeight - contentInsetTop && currentScrollingListView?.contentOffset.y == 0 {
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight - contentInsetTop)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        listContainerView.collectionView.isScrollEnabled = true
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        listContainerView.collectionView.isScrollEnabled = true
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        listContainerView.collectionView.isScrollEnabled = true
    }
}

class OctopusMainTableView: UITableView, UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer

    }
}
