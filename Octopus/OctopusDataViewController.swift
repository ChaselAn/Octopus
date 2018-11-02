//
//  OctopusDataViewController.swift
//  Octopus
//
//  Created by ancheng on 2018/11/2.
//  Copyright © 2018年 chaselan. All rights reserved.
//

import UIKit

class OctopusDataViewController: UIViewController {

    private let tableView = TestTableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
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
        cell.textLabel?.text = "\(indexPath.row)"
        return cell
    }
}
