# Octopus

![](https://raw.githubusercontent.com/ChaselAn/Octopus/master/CircleDemo.gif)

### Requirements

- Swift 4.2, iOS 9.0

### Installation

- With Cocoapods:

- swift4.2:

```ruby
pod 'Octopus', '~> 1.0.1'
# Then, run the following command:
$ pod install
```

- swift5.0:

```ruby
pod 'Octopus', '~> 1.1.2'
# Then, run the following command:
$ pod install
```

### How to use

<img width="250" height="445" src="https://raw.githubusercontent.com/ChaselAn/Octopus/master/Octopus.png"/>

```swift
	let octopusView = OctopusView()	  
	octopusView.dataSource = self
        octopusView.delegate = self
//        if #available(iOS 11.0, *) {
//            octopusView.tableView.contentInsetAdjustmentBehavior = .never
//        }
        view.addSubview(octopusView)
        octopusView.translatesAutoresizingMaskIntoConstraints = false
        octopusView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        octopusView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        octopusView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        octopusView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

        octopusView.hangUpOffsetY = Int((navigationController?.navigationBar.bounds.height ?? 0) + UIApplication.shared.statusBarFrame.height)
//        octopusView.tableView.contentInset = UIEdgeInsets(top: 88, left: 0, bottom: 0, right: 0)
        view.layoutIfNeeded()
```

* OctopusViewDataSource

```swift
public protocol OctopusViewDataSource: class {

    func numberOfPages(in octopusView: OctopusView) -> Int
    func octopusView(_ octopusView: OctopusView, pageViewControllerAt index: Int) -> OctopusPage

    func headerView(in octopusView: OctopusView) -> UIView?
    func headerViewHeight(in octopusView: OctopusView) -> Int

    func segmentView(in octopusView: OctopusView) -> UIView?
    func segmentViewHeight(in octopusView: OctopusView) -> Int
}
```

* I suggest you implement the caching mechanism for page view by yourself.

```swift
private var vcs: [Int: OctopusDataViewController] = [:]
func octopusView(_ octopusView: OctopusView, pageViewControllerAt index: Int) -> OctopusPage {
        if let cacheVC = vcs[index] {
            return cacheVC
        }
        let vc = OctopusDataViewController()
        vc.index = index
        vcs[index] = vc
        return vc
    }
```

