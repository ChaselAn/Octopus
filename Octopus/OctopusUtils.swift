//
//  OctopusUtils.swift
//  Octopus
//
//  Created by ancheng on 2018/11/2.
//  Copyright © 2018年 chaselan. All rights reserved.
//

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
