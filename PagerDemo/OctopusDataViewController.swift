//
//  OctopusDataViewController.swift
//  Octopus
//
//  Created by ancheng on 2018/11/2.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit
import Octopus

class OctopusDataViewController: UIViewController, OctopusPage {
    func containerView() -> UIView {
        return view
    }

    func scrollViewInContainerView() -> UIScrollView {
        return tableView
    }

    var tableView = UITableView()
    var index: Int = 0

    private var counts = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.rowHeight = 50
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "testCell")
        view.addSubview(tableView)
        tableView.constraintEqualToSuperView()
    }
}

class TestTableView: UITableView {

}

extension OctopusDataViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "testCell", for: indexPath)
        cell.contentView.subviews.forEach({
            $0.removeFromSuperview()
        })

        let label = UILabel()
        label.text = "\(indexPath.row) - \(index)"
        cell.contentView.addSubview(label)
        label.constraintEqualToSuperView()
        cell.backgroundColor = .clear
        return cell
    }
}

extension UIView {

    @discardableResult
    func constraintEqualToSuperView(insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
        guard let view = superview else { return [] }
        self.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: insets.bottom),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: insets.right)
        ]
        constraints.forEach { $0.isActive = true }
        return constraints
    }
}
