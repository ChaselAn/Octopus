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
        collectionView.register(UICollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        self.addSubview(collectionView)
        collectionView.constraintEqualToSuperView()
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
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        for view in cell.contentView.subviews {
            view.removeFromSuperview()
        }
        let tableView = UITableView()
        cell.contentView.addSubview(tableView)
        tableView.constraintEqualToSuperView()

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
