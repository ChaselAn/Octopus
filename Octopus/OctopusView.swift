//
//  OctopusView.swift
//  Octopus
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

public protocol OctopusPage {
    func containerView() -> UIView

    func scrollViewInContainerView() -> UIScrollView
}

extension OctopusPage {
    func scrollViewInContainerView() -> UIScrollView {
        return OctopusExceptionView()
    }
}

public protocol OctopusViewDataSource: class {

    func numberOfPages(in octopusView: OctopusView) -> Int
    func octopusView(_ octopusView: OctopusView, pageViewControllerAt index: Int) -> OctopusPage

    func headerView(in octopusView: OctopusView) -> UIView?
    func headerViewHeight(in octopusView: OctopusView) -> CGFloat

    func segmentView(in octopusView: OctopusView) -> UIView?
    func segmentViewHeight(in octopusView: OctopusView) -> CGFloat

}

public extension OctopusViewDataSource {
    func headerView(in octopusView: OctopusView) -> UIView? { return nil }
    func headerViewHeight(in octopusView: OctopusView) -> CGFloat { return 0 }

    func segmentView(in octopusView: OctopusView) -> UIView? { return nil }
    func segmentViewHeight(in octopusView: OctopusView) -> CGFloat { return 0 }
}

public class OctopusView: UIView {

    public weak var dataSource: OctopusViewDataSource?

    public lazy var tableView: OctopusMainTableView = {
        let tableView = OctopusMainTableView(frame: CGRect.zero, style: .plain)
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        setupHeaderView(tableView)
        tableView.estimatedRowHeight = UIScreen.main.bounds.height
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "OctopusViewCell")
        return tableView
    }()

    public func reloadData() {
        listContainerView.reloadData()
        tableView.reloadData()
    }

    public func updateSegmentViewHeight(animated: Bool) {
        guard dataSource?.segmentView(in: self) != nil else {
            return
        }
        if animated {
            tableView.beginUpdates()
            UIView.animate(withDuration: 0.3) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.segmentViewHeightConstraint?.constant = strongSelf.segmentViewHeight
                strongSelf.tableView.tableHeaderView?.frame.size.height = strongSelf.headerViewTotalHeight
                strongSelf.realHeaderView.layoutIfNeeded()
            }
            tableView.endUpdates()
        } else {
            segmentViewHeightConstraint?.constant = segmentViewHeight
        }
    }

    private var headerViewTotalHeight: CGFloat {
        return headerViewHeight + segmentViewHeight
    }

    private var headerViewHeight: CGFloat {
        guard dataSource?.headerView(in: self) != nil else { return 0 }
        return dataSource?.headerViewHeight(in: self) ?? 0
    }

    private var segmentViewHeight: CGFloat {
        guard dataSource?.segmentView(in: self) != nil else { return 0 }
        return dataSource?.segmentViewHeight(in: self) ?? 0
    }

    private lazy var realHeaderView = UIView()
    private var segmentViewHeightConstraint: NSLayoutConstraint?

    private var listContainerView = OctopusListContainerView()

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


        if let dataSource = dataSource {
            listContainerView.dataViewsCount = { [weak self] in
                guard let strongSelf = self else { return 0 }
                return dataSource.numberOfPages(in: strongSelf)
            }

            listContainerView.dataContainerView = { [weak self] index in
                guard let strongSelf = self else { return OctopusExceptionView() }
                let page = dataSource.octopusView(strongSelf, pageViewControllerAt: index)
                return page.containerView()
            }

            listContainerView.dataScrollView = { [weak self] index in
                guard let strongSelf = self else { return OctopusExceptionView() }
                let page = dataSource.octopusView(strongSelf, pageViewControllerAt: index)
                return page.scrollViewInContainerView()
            }
        }

        listContainerView.dataViewDidScroll = { [weak self] scrollView in
            guard let strongSelf = self else { return }
            strongSelf.currentScrollingListView = scrollView
            strongSelf.preferredProcessListViewDidScroll(scrollView: scrollView)
        }
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        listContainerView.heightAnchor.constraint(equalToConstant: tableView.bounds.height).isActive = true
    }

    private func setupHeaderView(_ tableView: UITableView) {
        realHeaderView.subviews.forEach({ $0.removeFromSuperview() })
        if let headerView = dataSource?.headerView(in: self) {
            realHeaderView.addSubview(headerView)
            headerView.translatesAutoresizingMaskIntoConstraints = false
            headerView.topAnchor.constraint(equalTo: realHeaderView.topAnchor).isActive = true
            headerView.leadingAnchor.constraint(equalTo: realHeaderView.leadingAnchor).isActive = true
            headerView.trailingAnchor.constraint(equalTo: realHeaderView.trailingAnchor).isActive = true
            headerView.heightAnchor.constraint(equalToConstant: headerViewHeight).isActive = true
        }
        if let segmentView = dataSource?.segmentView(in: self) {
            realHeaderView.addSubview(segmentView)
            segmentView.translatesAutoresizingMaskIntoConstraints = false
            segmentView.bottomAnchor.constraint(equalTo: realHeaderView.bottomAnchor).isActive = true
            segmentView.leadingAnchor.constraint(equalTo: realHeaderView.leadingAnchor).isActive = true
            segmentView.trailingAnchor.constraint(equalTo: realHeaderView.trailingAnchor).isActive = true
            segmentViewHeightConstraint = segmentView.heightAnchor.constraint(equalToConstant: segmentViewHeight)
            segmentViewHeightConstraint!.isActive = true
        }

        realHeaderView.frame = CGRect(x: 0, y: 0, width: 0, height: headerViewTotalHeight)
        tableView.tableHeaderView = realHeaderView
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
            listContainerView.observations.keys.forEach({
                $0.contentOffset = CGPoint.zero
            })
        }

        if scrollView.contentOffset.y > headerViewHeight - contentInsetTop && (currentScrollingListView?.contentOffset.y ?? 0) == 0 {
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

public class OctopusMainTableView: UITableView, UIGestureRecognizerDelegate {

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer

    }
}

class OctopusExceptionView: UIScrollView {

}
