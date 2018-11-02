//
//  OctopusView.swift
//  Octopus
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

protocol OctopusViewDelegate: class {

//    func tableHeaderView(in octopusView: OctopusView) -> UIView?
//    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat

}

extension OctopusViewDelegate {
    func tableHeaderView(in octopusView: OctopusView) -> UIView? { return nil }
    func tableHeaderViewHeight(in octopusView: OctopusView) -> CGFloat { return 0 }
}

public class OctopusView: UIView {

    weak var delegate: OctopusViewDelegate?

    private let segmentViewHeight: CGFloat = 50
    private let headerViewHeight: CGFloat = 150

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerViewHeight))
        tableView.tableHeaderView = headerView
//        tableView.tableHeaderView = delegate?.tableHeaderView(in: self)
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "cell")
        return tableView
    }()

    private var listContainerView = OctopusListContainerView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableView)
        tableView.constraintEqualToSuperView()

        listContainerView.mainTableView = tableView
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        layoutIfNeeded()
        return bounds.height - segmentViewHeight - headerViewHeight
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
//        self.delegate.mainTableViewDidScroll?(scrollView)
        //用户正在上下滚动的时候，就不允许左右滚动
        if scrollView.isTracking {
            listContainerView.collectionView.isScrollEnabled = false
        }

        preferredProcessMainTableViewDidScroll(scrollView)
    }

    private func preferredProcessMainTableViewDidScroll(_ scrollView: UIScrollView) {
//        if (self.currentScrollingListView != nil && self.currentScrollingListView!.contentOffset.y > 0) {
//            //mainTableView的header已经滚动不见，开始滚动某一个listView，那么固定mainTableView的contentOffset，让其不动
//            tableView.contentOffset = CGPoint(x: 0, y: self.delegate.tableHeaderViewHeight(in: self))
//        }
//
//        if (mainTableView.contentOffset.y < getTableHeaderViewHeight()) {
//            //mainTableView已经显示了header，listView的contentOffset需要重置
//            for listView in self.delegate.listViews(in: self) {
//                listView.listScrollViewWillResetContentOffset?()
//                listView.listScrollView().contentOffset = CGPoint.zero
//            }
//        }
//
//        if scrollView.contentOffset.y > getTableHeaderViewHeight() && self.currentScrollingListView?.contentOffset.y == 0 {
//            //当往上滚动mainTableView的headerView时，滚动到底时，修复listView往上小幅度滚动
//            self.mainTableView.contentOffset = CGPoint(x: 0, y: self.delegate.tableHeaderViewHeight(in: self))
//        }
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
