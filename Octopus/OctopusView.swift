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
    func headerViewHeight(in octopusView: OctopusView) -> Int // 鉴于scrollView的滚动精度缺失问题，暂时使用整型

    func segmentView(in octopusView: OctopusView) -> UIView?
    func segmentViewHeight(in octopusView: OctopusView) -> Int // 鉴于scrollView的滚动精度缺失问题，暂时使用整型
}

public extension OctopusViewDataSource {
    func headerView(in octopusView: OctopusView) -> UIView? { return nil }
    func headerViewHeight(in octopusView: OctopusView) -> Int { return 0 }

    func segmentView(in octopusView: OctopusView) -> UIView? { return nil }
    func segmentViewHeight(in octopusView: OctopusView) -> Int { return 0 }
}

public protocol OctopusViewDelegate: NSObjectProtocol {

    func octopusViewStatusChanged(_ octopusView: OctopusView, status: OctopusView.Status)
    func octopusViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer, in octopusView: OctopusView) -> Bool

    func octopusViewDidScroll(_ octopusView: OctopusView)
    func octopusViewDidZoom(_ octopusView: OctopusView)
    func octopusViewWillBeginDragging(_ octopusView: OctopusView)
    func octopusViewWillEndDragging(_ octopusView: OctopusView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func octopusViewDidEndDragging(_ octopusView: OctopusView, willDecelerate decelerate: Bool)
    func octopusViewWillBeginDecelerating(_ octopusView: OctopusView)
    func octopusViewDidEndDecelerating(_ octopusView: OctopusView)
    func octopusViewDidEndScrollingAnimation(_ octopusView: OctopusView)

    func octopusPageViewDidScroll(_ octopusPageView: UICollectionView)
    func octopusPageViewDidZoom(_ octopusPageView: UICollectionView)
    func octopusPageViewWillBeginDragging(_ octopusPageView: UICollectionView)
    func octopusPageViewWillEndDragging(_ octopusPageView: UICollectionView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func octopusPageViewDidEndDragging(_ octopusPageView: UICollectionView, willDecelerate decelerate: Bool)
    func octopusPageViewWillBeginDecelerating(_ octopusPageView: UICollectionView)
    func octopusPageViewDidEndDecelerating(_ octopusPageView: UICollectionView)
    func octopusPageViewDidEndScrollingAnimation(_ octopusPageView: UICollectionView)

}

public extension OctopusViewDelegate {

    func octopusViewStatusChanged(_ octopusView: OctopusView, status: OctopusView.Status) {}
    func octopusViewGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer, in octopusView: OctopusView) -> Bool {
        return gestureRecognizer is UIPanGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
    }

    func octopusViewDidScroll(_ octopusView: OctopusView) {}
    func octopusViewDidZoom(_ octopusView: OctopusView) {}
    func octopusViewWillBeginDragging(_ octopusView: OctopusView) {}
    func octopusViewWillEndDragging(_ octopusView: OctopusView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {}
    func octopusViewDidEndDragging(_ octopusView: OctopusView, willDecelerate decelerate: Bool) {}
    func octopusViewWillBeginDecelerating(_ octopusView: OctopusView) {}
    func octopusViewDidEndDecelerating(_ octopusView: OctopusView) {}
    func octopusViewDidEndScrollingAnimation(_ octopusView: OctopusView) {}

    func octopusPageViewDidScroll(_ octopusPageView: UICollectionView) {}
    func octopusPageViewDidZoom(_ octopusPageView: UICollectionView) {}
    func octopusPageViewWillBeginDragging(_ octopusPageView: UICollectionView) {}
    func octopusPageViewWillEndDragging(_ octopusPageView: UICollectionView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {}
    func octopusPageViewDidEndDragging(_ octopusPageView: UICollectionView, willDecelerate decelerate: Bool) {}
    func octopusPageViewWillBeginDecelerating(_ octopusPageView: UICollectionView) {}
    func octopusPageViewDidEndDecelerating(_ octopusPageView: UICollectionView) {}
    func octopusPageViewDidEndScrollingAnimation(_ octopusPageView: UICollectionView) {}

}

public class OctopusView: UIView {

    public enum Status {
        case normal
        case hangUp
    }

    public weak var dataSource: OctopusViewDataSource?
    public weak var delegate: OctopusViewDelegate?

    public var hangUpOffsetY: Int = 0 // 悬挂区域距离顶部的间距
    public var isHangUp: Bool {
        return status == .hangUp
    }
    public var status: Status = .normal

    public var visibleOctopusPages: [OctopusPage] {
        return listContainerView.visibleOctopusPages
    }

    public var visibleOctopusPageIndexs: [Int] {
        return listContainerView.visibleIndexs
    }

    public var currentMainVisibleIndex: Int {
        let x = listContainerView.collectionView.contentOffset.x + listContainerView.collectionView.bounds.width / 2
        return lround(Double(x / listContainerView.collectionView.contentSize.width))
    }

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
        tableView.octopusViewGestureRecognizer = { [weak self] gesture, otherGesture in
            guard let strongSelf = self, let delegate = strongSelf.delegate else { return true }
            return delegate.octopusViewGestureRecognizer(gesture, shouldRecognizeSimultaneouslyWith: otherGesture, in: strongSelf)
        }
        return tableView
    }()

    public func reloadData() {
        listContainerView.reloadData()
        tableView.reloadData()
    }

    public func updateHeaderViewHeight(animated: Bool) {
        let headerViewHeightFloat = CGFloat(headerViewHeight)
        guard headerViewHeightFloat != headerViewHeightConstraint?.constant else { return }
        guard dataSource?.headerView(in: self) != nil else {
            return
        }
        if animated {
            tableView.beginUpdates()
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.headerViewHeightConstraint?.constant = headerViewHeightFloat
                strongSelf.realHeaderView.frame.size.height = CGFloat(strongSelf.headerViewTotalHeight)
                strongSelf.realHeaderView.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView.tableHeaderView = strongSelf.realHeaderView
            })
            tableView.endUpdates()
        } else {
            headerViewHeightConstraint?.constant = headerViewHeightFloat
            realHeaderView.frame.size.height = CGFloat(headerViewTotalHeight)
            tableView.tableHeaderView = realHeaderView
        }

        preferredProcessMainTableViewDidScroll(tableView)

    }

    public func updateSegmentViewHeight(animated: Bool) {
        guard dataSource?.segmentView(in: self) != nil else {
            return
        }
        if animated {
            tableView.beginUpdates()
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.segmentViewHeightConstraint?.constant = CGFloat(strongSelf.segmentViewHeight)
                strongSelf.realHeaderView.frame.size.height = CGFloat(strongSelf.headerViewTotalHeight)
                strongSelf.realHeaderView.layoutIfNeeded()
                }, completion: { [weak self] _ in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView.tableHeaderView = strongSelf.realHeaderView
            })
            tableView.endUpdates() 
        } else {
            segmentViewHeightConstraint?.constant = CGFloat(segmentViewHeight)
            realHeaderView.frame.size.height = CGFloat(headerViewTotalHeight)
            tableView.tableHeaderView = realHeaderView
        }

        listContainerView.updateMainTableCellHeight()
    }

    public func scrollToPage(index: Int) {
        listContainerView.scrollToPage(index: index)
    }

    private var headerViewTotalHeight: Int {
        return headerViewHeight + segmentViewHeight
    }

    private var headerViewHeight: Int {
        guard dataSource?.headerView(in: self) != nil else {
            return 0
        }
        let height = dataSource?.headerViewHeight(in: self) ?? 0
        return height
    }

    private var segmentViewHeight: Int {
        guard dataSource?.segmentView(in: self) != nil else { return 0 }
        return dataSource?.segmentViewHeight(in: self) ?? 0
    }

    private lazy var realHeaderView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        return view
    }()
    private var segmentViewHeightConstraint: NSLayoutConstraint?
    private var headerViewHeightConstraint: NSLayoutConstraint?

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
        listContainerView.delegate = self

        listContainerView.dataViewsCount = { [weak self] in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else { return 0 }
            return dataSource.numberOfPages(in: strongSelf)
        }

        listContainerView.dataOctopusPage = { [weak self] index in
            guard let strongSelf = self, let dataSource = strongSelf.dataSource else { return nil }
            let page = dataSource.octopusView(strongSelf, pageViewControllerAt: index)
            return page
        }

        listContainerView.dataViewDidScroll = { [weak self] scrollView in
            guard let strongSelf = self else { return }
            strongSelf.currentScrollingListView = scrollView
            strongSelf.preferredProcessListViewDidScroll(scrollView: scrollView)
        }

        listContainerView.cellHeight = { [weak self] in
            guard let strongSelf = self else { return nil }
            return strongSelf.bounds.height - CGFloat(strongSelf.hangUpOffsetY) - CGFloat(strongSelf.segmentViewHeight)
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
            headerViewHeightConstraint = headerView.heightAnchor.constraint(equalToConstant: CGFloat(headerViewHeight))
            headerViewHeightConstraint?.isActive = true
        }
        if let segmentView = dataSource?.segmentView(in: self) {
            realHeaderView.addSubview(segmentView)
            segmentView.translatesAutoresizingMaskIntoConstraints = false
            segmentView.bottomAnchor.constraint(equalTo: realHeaderView.bottomAnchor).isActive = true
            segmentView.leadingAnchor.constraint(equalTo: realHeaderView.leadingAnchor).isActive = true
            segmentView.trailingAnchor.constraint(equalTo: realHeaderView.trailingAnchor).isActive = true
            segmentViewHeightConstraint = segmentView.heightAnchor.constraint(equalToConstant: CGFloat(segmentViewHeight))
            segmentViewHeightConstraint!.isActive = true
        }

        realHeaderView.frame = CGRect(x: 0, y: 0, width: 0, height: headerViewTotalHeight)
        tableView.tableHeaderView = realHeaderView
    }

    private func preferredProcessListViewDidScroll(scrollView: UIScrollView) {
        if tableView.contentOffset.y < CGFloat(headerViewHeight - hangUpOffsetY) {
            guard let currentScrollingListView = currentScrollingListView else { return }
            currentScrollingListView.contentOffset = CGPoint(x: -currentScrollingListView.contentInset.left, y: -currentScrollingListView.contentInset.top)
            currentScrollingListView.showsVerticalScrollIndicator = false
        } else {
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight - hangUpOffsetY)
            currentScrollingListView!.showsVerticalScrollIndicator = true
        }
    }
}

extension OctopusView: UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let source = dataSource else { return 0 }
        return source.numberOfPages(in: self) > 0 ? 1 : 0
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
        delegate?.octopusViewDidScroll(self)
    }

    private func preferredProcessMainTableViewDidScroll(_ scrollView: UIScrollView) {

        if let currentScrollingListView = currentScrollingListView, currentScrollingListView.contentOffset.y > -currentScrollingListView.contentInset.top {
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight - hangUpOffsetY)
            if status == .normal {
                status = .hangUp
                delegate?.octopusViewStatusChanged(self, status: .hangUp)
            }
        }
        if tableView.contentOffset.y < CGFloat(headerViewHeight - hangUpOffsetY) {
            if status == .hangUp {
                status = .normal
                delegate?.octopusViewStatusChanged(self, status: .normal)
            }
            listContainerView.observations.values.forEach({
                let scrollView = $0.0
                scrollView.contentOffset = CGPoint(x: -scrollView.contentInset.left, y: -scrollView.contentInset.top)
            })
        }

        if scrollView.contentOffset.y > CGFloat(headerViewHeight - hangUpOffsetY) {
            if let currentScrollingListView = currentScrollingListView, currentScrollingListView.contentOffset.y > -currentScrollingListView.contentInset.top { return }
            tableView.contentOffset = CGPoint(x: 0, y: headerViewHeight - hangUpOffsetY)
            if status == .normal {
                status = .hangUp
                delegate?.octopusViewStatusChanged(self, status: .hangUp)
            }
        }

    }

    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.octopusViewDidZoom(self)
    }

    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.octopusViewWillBeginDragging(self)
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        listContainerView.collectionView.isScrollEnabled = true
        delegate?.octopusViewDidEndDecelerating(self)
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.octopusViewWillEndDragging(self, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        listContainerView.collectionView.isScrollEnabled = true
        delegate?.octopusViewDidEndDragging(self, willDecelerate: decelerate)
    }

    public func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.octopusViewWillBeginDecelerating(self)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        listContainerView.collectionView.isScrollEnabled = true
        delegate?.octopusViewDidEndScrollingAnimation(self)
    }

}

extension OctopusView: OctopusListContainerViewDelegate {

    func collectionViewDidScroll(_ collectionView: UICollectionView) {
        delegate?.octopusPageViewDidScroll(collectionView)
    }

    func collectionViewDidZoom(_ collectionView: UICollectionView) {
        delegate?.octopusPageViewDidZoom(collectionView)
    }

    func collectionViewWillBeginDragging(_ collectionView: UICollectionView) {
        delegate?.octopusPageViewWillBeginDragging(collectionView)
    }

    func collectionViewWillEndDragging(_ collectionView: UICollectionView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.octopusPageViewWillEndDragging(collectionView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func collectionViewDidEndDragging(_ collectionView: UICollectionView, willDecelerate decelerate: Bool) {
        if !decelerate {
            if let scrollingView = (listContainerView.collectionView.visibleCells.first as? OctopusPageCell)?.octopusPage?.scrollViewInContainerView() {
                currentScrollingListView = scrollingView
            }
        }
        delegate?.octopusPageViewDidEndDragging(collectionView, willDecelerate: decelerate)
    }

    func collectionViewWillBeginDecelerating(_ collectionView: UICollectionView) {
        delegate?.octopusPageViewWillBeginDecelerating(collectionView)
    }

    func collectionViewDidEndDecelerating(_ collectionView: UICollectionView) {
        if let scrollingView = (listContainerView.collectionView.visibleCells.first as? OctopusPageCell)?.octopusPage?.scrollViewInContainerView() {
            currentScrollingListView = scrollingView
        }
        delegate?.octopusPageViewDidEndDecelerating(collectionView)
    }

    func collectionViewDidEndScrollingAnimation(_ collectionView: UICollectionView) {
        if let scrollingView = (listContainerView.collectionView.visibleCells.first as? OctopusPageCell)?.octopusPage?.scrollViewInContainerView() {
            currentScrollingListView = scrollingView
        }
        delegate?.octopusPageViewDidEndScrollingAnimation(collectionView)
    }

}

public class OctopusMainTableView: UITableView, UIGestureRecognizerDelegate {

    var octopusViewGestureRecognizer: ((UIGestureRecognizer, UIGestureRecognizer) -> Bool)?

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        return octopusViewGestureRecognizer?(gestureRecognizer, otherGestureRecognizer) ?? true

    }
}

class OctopusExceptionView: UIScrollView {

}
