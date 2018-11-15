//
//  OctopusListContainerView.swift
//  Octopus
//
//  Created by ancheng on 2018/11/1.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

class OctopusListContainerView: UIView {

    var collectionView: UICollectionView!
    weak var mainTableView: UITableView?
    var dataViewsCount: (() -> Int)?
    var dataView: ((Int) -> OctopusPage?)?
    var dataViewDidScroll: ((UIScrollView) -> Void)?

    var observations: [UIScrollView: NSKeyValueObservation] = [:]

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

        observations.keys.forEach({ $0.frame = self.bounds })
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func reloadData() {
        collectionView.reloadData()
    }

}

extension OctopusListContainerView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataViewsCount?() ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OctopusPageCell", for: indexPath) as! OctopusPageCell
        for view in cell.contentView.subviews {
            if let scrollView = cell.octopusPageScrollView {
                observations[scrollView] = nil
            }
            view.removeFromSuperview()
        }
        guard let vc = dataView?(indexPath.row), let view = vc.view else { return cell }
        cell.contentView.addSubview(view)
        let scrollView = vc.scrollView
            cell.octopusPageScrollView = scrollView
            let observation = scrollView.observe(\.contentOffset, options: [.old, .new], changeHandler: { [weak self] (scrollView, change) in
                guard let strongSelf = self else { return }
                guard change.oldValue != change.newValue else { return }
                strongSelf.dataViewDidScroll?(scrollView)
            })
            observations[scrollView] = observation
        

        return cell
    }
}

extension OctopusListContainerView: UICollectionViewDelegate {

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.mainTableView?.isScrollEnabled = true
    }

    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.mainTableView?.isScrollEnabled = true
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isTracking || scrollView.isDecelerating {
            self.mainTableView?.isScrollEnabled = false
        }
    }
}

extension OctopusListContainerView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        layoutIfNeeded()
        return bounds.size
    }
}

extension OctopusListContainerView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = UITableViewCell()
        cell.contentView.subviews.forEach({
            $0.removeFromSuperview()
        })
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}

class OctopusPageCell: UICollectionViewCell {
    var octopusPageScrollView: UIScrollView?

    
}
