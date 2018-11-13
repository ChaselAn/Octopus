//
//  OctopusView.swift
//  Octopus
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

public protocol OctopusViewDelegate: class {

//    func tableHeaderView(in octopusView: OctopusView) -> UIView?
//    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat

}

extension OctopusViewDelegate {
    func tableHeaderView(in octopusView: OctopusView) -> UIView? { return nil }
    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat { return 0 }
}

public class OctopusView: UIView {

    public weak var delegate: OctopusViewDelegate?
    public weak var targetVC: UIViewController?

    public var contentInsetAdjustmentBehavior: UIScrollView.ContentInsetAdjustmentBehavior = .automatic {
        didSet {
            tableView.contentInsetAdjustmentBehavior = contentInsetAdjustmentBehavior
        }
    }

    private let segmentViewHeight: CGFloat = 50
    private let headerViewHeight: CGFloat = 150

    private lazy var tableView: OctopusMainTableView = {
        let tableView = OctopusMainTableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerViewHeight))
        headerView.backgroundColor = UIColor.red
        tableView.tableHeaderView = headerView
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.tableHeaderView = delegate?.tableHeaderView(in: self)
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()

    private var listContainerView = OctopusListContainerView()
    private var observations: [NSKeyValueObservation] = []

    private var currentScrollingListView: UIScrollView?

    override init(frame: CGRect) {
        super.init(frame: frame)

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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        listContainerView.heightAnchor.constraint(equalToConstant: tableView.bounds.height).isActive = true
    }

    private func preferredProcessListViewDidScroll(scrollView: UIScrollView) { 
        if tableView.contentOffset.y < headerViewHeight {
            //mainTableView的header还没有消失，让listScrollView一直为0
            guard let currentScrollingListView = currentScrollingListView else { return }
//            self.currentListView?.listScrollViewWillResetContentOffset?()
            currentScrollingListView.contentOffset = CGPoint.zero
            currentScrollingListView.showsVerticalScrollIndicator = false
        } else {
            //mainTableView的header刚好消失，固定mainTableView的位置，显示listScrollView的滚动条
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight);
            currentScrollingListView!.showsVerticalScrollIndicator = true;
        }
    }
}

extension OctopusView: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        cell.contentView.addSubview(listContainerView)
        listContainerView.constraintEqualToSuperView()
        return cell
    }

//    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        layoutIfNeeded()
//        return bounds.height
//    }

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
//        self.delegate.mainTableViewDidScroll?(scrollView)
        //用户正在上下滚动的时候，就不允许左右滚动
        if scrollView.isTracking {
            listContainerView.collectionView.isScrollEnabled = false
        }

        preferredProcessMainTableViewDidScroll(scrollView)
    }

    private func preferredProcessMainTableViewDidScroll(_ scrollView: UIScrollView) {
        if let currentScrollingListView = currentScrollingListView, currentScrollingListView.contentOffset.y > 0 {
            //mainTableView的header已经滚动不见，开始滚动某一个listView，那么固定mainTableView的contentOffset，让其不动
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight)
        }

        if tableView.contentOffset.y < headerViewHeight {
            //mainTableView已经显示了header，listView的contentOffset需要重置
            for scrollView in listContainerView.dataView {
//                listView.listScrollViewWillResetContentOffset?()
                scrollView.contentOffset = CGPoint.zero
            }
        }

        if scrollView.contentOffset.y > headerViewHeight && currentScrollingListView?.contentOffset.y == 0 {
            //当往上滚动mainTableView的headerView时，滚动到底时，修复listView往上小幅度滚动
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight)
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
