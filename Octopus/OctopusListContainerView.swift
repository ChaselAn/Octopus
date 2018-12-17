//
//  OctopusListContainerView.swift
//  Octopus
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

protocol OctopusListContainerViewDelegate: NSObjectProtocol {

    func collectionViewDidScroll(_ collectionView: UICollectionView)
    func collectionViewDidZoom(_ collectionView: UICollectionView)
    func collectionViewWillBeginDragging(_ collectionView: UICollectionView)
    func collectionViewWillEndDragging(_ collectionView: UICollectionView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>)
    func collectionViewDidEndDragging(_ collectionView: UICollectionView, willDecelerate decelerate: Bool)
    func collectionViewWillBeginDecelerating(_ collectionView: UICollectionView)
    func collectionViewDidEndDecelerating(_ collectionView: UICollectionView)
    func collectionViewDidEndScrollingAnimation(_ collectionView: UICollectionView)

}
class OctopusListContainerView: UIView {

    weak var delegate: OctopusListContainerViewDelegate?
    var collectionView: UICollectionView!
    weak var mainTableView: UITableView?
    var dataViewsCount: (() -> Int)?
    var dataOctopusPage: ((Int) -> OctopusPage?)?
    var cellHeight: (() -> CGFloat?)?

    var dataViewDidScroll: ((UIScrollView) -> Void)?

    var visibleOctopusPages: [OctopusPage] {
        return collectionView.visibleCells.compactMap({ ($0 as? OctopusPageCell)?.octopusPage })
    }

    var visibleIndexs: [Int] {
        return collectionView.indexPathsForVisibleItems.map({ $0.item })
    }

    var observations: [UIScrollView: NSKeyValueObservation] = [:]

    private var containerViews: [Int: UIView] = [:]

    override init(frame: CGRect) {
        super.init(frame: frame)

        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.bounces = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(OctopusPageCell.classForCoder(), forCellWithReuseIdentifier: "OctopusPageCell")
        self.addSubview(collectionView)
        collectionView.constraintEqualToSuperView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerViews.values.forEach({ [weak self] in
            guard let strongSelf = self else { return }
            $0.translatesAutoresizingMaskIntoConstraints = true
            $0.frame = CGRect(origin: strongSelf.bounds.origin, size: CGSize(width: strongSelf.bounds.width, height: strongSelf.cellHeight?() ?? strongSelf.bounds.height))
            $0.layoutIfNeeded()
        })

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData() {
        collectionView.reloadData()
    }

    func updateMainTableCellHeight() {
        layoutSubviews()
    }

    func scrollToPage(index: Int) {
        layoutIfNeeded()
        collectionView.setContentOffset(CGPoint(x: bounds.size.width * CGFloat(index), y: 0), animated: true)
        layoutSubviews()
    }

}

extension OctopusListContainerView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataViewsCount?() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OctopusPageCell", for: indexPath) as! OctopusPageCell
        for view in cell.contentView.subviews {
            if let scrollView = cell.octopusPage?.scrollViewInContainerView() {
                observations[scrollView] = nil
            }
            view.removeFromSuperview()
        }
        guard let octopusPage = dataOctopusPage?(indexPath.row) else { return cell }
        cell.octopusPage = octopusPage
        let containerView = octopusPage.containerView()
        cell.contentView.addSubview(containerView)
        let scrollView = octopusPage.scrollViewInContainerView()
        let observation = scrollView.observe(\.contentOffset, options: [.old, .new], changeHandler: { [weak self] (scrollView, change) in
            guard let strongSelf = self else { return }
            guard change.oldValue != change.newValue else { return }
            strongSelf.dataViewDidScroll?(scrollView)
        })
        containerView.translatesAutoresizingMaskIntoConstraints = true
        layoutIfNeeded()
        containerView.frame = CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: cellHeight?() ?? bounds.height))
        containerView.layoutIfNeeded()
        observations[scrollView] = observation
        containerViews[indexPath.item] = containerView

        return cell
    }
}

extension OctopusListContainerView: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDecelerating {
            self.mainTableView?.isScrollEnabled = false
        }
        delegate?.collectionViewDidScroll(collectionView)
    }

    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        delegate?.collectionViewDidZoom(collectionView)
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.collectionViewWillBeginDragging(collectionView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        delegate?.collectionViewWillEndDragging(collectionView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.mainTableView?.isScrollEnabled = true
        delegate?.collectionViewDidEndDragging(collectionView, willDecelerate: decelerate)
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        delegate?.collectionViewWillBeginDecelerating(collectionView)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
        delegate?.collectionViewDidEndDecelerating(collectionView)
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
        delegate?.collectionViewDidEndScrollingAnimation(collectionView)
    }

}

extension OctopusListContainerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        layoutIfNeeded()
        return bounds.size
    }
}

class OctopusPageCell: UICollectionViewCell {
    var octopusPage: OctopusPage?
}
