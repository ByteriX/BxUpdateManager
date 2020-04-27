# BxUpdateManager

Swift manager for checking update from network and local.

## Features

- [x] manage loading data
- [x] execute in unconcurent queue

## Requirements

- iOS 8.0+ : iOS 8.x/9.x/10.x/11.x/12.x/13.x
- Swift 3.0+ : Swift 3.x/4.x/5.x supported

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate BxUpdateManager into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

target '<Your Target Name>' do
pod 'BxUpdateManager', '~> 1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```


### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler. It is in early development, but BxUpdateManager does support its use on supported platforms. 

Once you have your Swift package set up, adding BxUpdateManager as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .Package(url: "https://github.com/ByteriX/BxUpdateManager.git", majorVersion: 1)
]
```

### Manually

If you prefer not to use either of the aforementioned dependency managers, you can integrate `BxUpdateManager` into your project manually.

#### Embedded Framework

- Open up Terminal, `cd` into your top-level project directory, and run the following command "if" your project is not initialized as a git repository:

```bash
$ git init
```

- Add `BxUpdateManager` as a git [submodule](http://git-scm.com/docs/git-submodule) by running the following command:

```bash
$ git submodule add https://github.com/ByteriX/BxUpdateManager.git
```

- Add all sources and resources from local copy of `BxUpdateManager` to the build phase of the project.

- And that's it!


## Usage

### Example

```swift

class SimpleController: UIViewController, BxUpdateManagerDelegate {
	
	let dataManager = BxUpdateManager(updateDataInterval: 15.0,
        updateInterfaceInterval: 5.0,
        checkInterval: 1.0,
        waitingStrategy: .fromStopLoading,
        isActive: false)
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataManager.delegate = self
    }
    
    func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        // The BxUpdateManager instance initiate as deactivated, then you will need activate it:
        dataManager.isActive = true
    }
    
    func viewWillDisappear(_ animated: Bool){
        super.viewWillDisappear(animated)
        // If Controller has deinited then isActive = false should called from destructor and that wouldn't need:
        dataManager.isActive = false
    }
    
    // MARK - BxUpdateManagerDelegate

    func updateManagerLoadData(_ updateManager: BxUpdateManager)
    {

        // loading...

        // When loading is finished without error call that:
        updateManager.stopLoading()
        
        //If loading fail with error call that:
        // updateManager.stopLoading(error: error)
    }

    func updateManagerUpdateInterface(_ updateManager: BxUpdateManager)
    {
        // only for interface updating
    }

    func updateManagerUpdateData(_ updateManager: BxUpdateManager)
    {
        // only for data updating
    }
}

```

## License

BxUpdateManager is released under the MIT license. See LICENSE for details.
