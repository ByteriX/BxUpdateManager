/**
 *	@file BxUpdateManager.swift
 *	@namespace BxUpdateManager
 *
 *	@details Manager for checking update
 *	@date 26.06.2017
 *	@author Sergey Balalaev
 *
 *	@version last in https://github.com/ByteriX/BxTextField.git
 *	@copyright The MIT License (MIT) https://opensource.org/licenses/MIT
 *	 Copyright (c) 2017 ByteriX. See http://byterix.com
 */

import Foundation
import Reachability

public protocol BxUpdateManagerDelegate : AnyObject {
    
    /// This method need implement for loading data. In this body you must call stopLoading(with error) or stopLoading()
    func updateManagerLoadData(_ updateManager: BxUpdateManager)
    /// It call when data updated or need refresh user interface
    func updateManagerUpdateInterface(_ updateManager: BxUpdateManager)
    /// It call only when data updated
    func updateManagerUpdateData(_ updateManager: BxUpdateManager)
    
}

/// Manager for checking update from network and local.
open class BxUpdateManager: AnyObject {
    
    public var updateDataInterval: TimeInterval
    public var updateInterfaceInterval: TimeInterval
    public var checkInterval: TimeInterval
    
    public weak var delegate: BxUpdateManagerDelegate? = nil
    
    // MARK - this use from main thread
    
    internal(set) var error: Error? = nil
    internal(set) var lastLocalUpdateData: Date = Date(timeIntervalSince1970: 0)
    internal(set) var lastLocalUpdateInterface: Date = Date()
    
    
    // MARK - this use from checkUpdateQueue only
    internal(set) var isUpdating: Bool = false
    internal(set) var isWaittingNextUpdate = false
    fileprivate var checkLocalUpdateData: Date = Date(timeIntervalSince1970: 0)
    fileprivate var checkLocalUpdateInterface: Date = Date()
    
    // MARK - it internal use
    fileprivate var timer: Timer? = nil
    fileprivate let reachability = Reachability.forInternetConnection()!
    fileprivate let dataUpdateQueue = DispatchQueue(label: "BxUpdateManager.DataUpdateQueue", qos: DispatchQoS.background)
    
    /// MARK -  first activation call update
    fileprivate var isFirstActivated: Bool = true
    
    ///
    /// active = true will start checking,
    /// if you want to update data before, you can call updateData() before activation
    /// and active = true after that doesn't call update immediately
    ///
    /// Please set active = false else dealloc not will called
    ///
    public var active: Bool = false {
        didSet {
            timer?.invalidate()
            timer = nil
            if active {
                timer = Timer.scheduledTimer(timeInterval: checkInterval, target: self, selector: #selector(checkTimerUpdate), userInfo: nil, repeats: true)
                if isFirstActivated {
                    isFirstActivated = false
                    checkUpdate()
                } else {
                    checkUpdateWithError()
                }
                reachability.startNotifier()
            } else {
                reachability.stopNotifier()
            }
        }
    }
    
    public init(updateDataInterval: TimeInterval = 60.0,
        updateInterfaceInterval: TimeInterval = 10.0,
        checkInterval: TimeInterval = 5.0)
    {
        self.updateDataInterval = updateDataInterval
        self.updateInterfaceInterval = updateInterfaceInterval
        self.checkInterval = checkInterval
    
        NotificationCenter.default.addObserver(self, selector: #selector(checkTimerUpdate), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        reachability.reachableBlock = { [weak self] (reachability) -> Void in
            DispatchQueue.main.async(execute: {[weak self]() -> Void in
                self?.checkUpdateWithError()
            })
        }
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        ({active = false})()
    }
    
    /// immediate update from other
    open func updateData(){
        dataUpdateQueue.async
            {[weak self] () -> Void in
                self?.internalUpdateData()
        }
    }
    
    /// only checking for update
    open func checkUpdate()
    {
        dataUpdateQueue.async
            {[weak self] () -> Void in
                guard let this = self else {
                    return
                }
                if this.active {
                    this.internalCheckUpdate()
                }
        }
    }
    
    /// if last loading return error then try repeat else only check for updating
    open func checkUpdateWithError() {
        DispatchQueue.main.async(execute: {[weak self]() -> Void in
            if self?.error != nil {
                self?.updateData()
            } else {
                self?.checkUpdate()
            }
        })
    }
    
    /// It need call only from main thread. If updateManagerLoadData finished loading whithout error, this param need set nil else error object.
    open func stopLoading(error: Error? = nil) {
        self.error = error
        self.didUpdateData()
    }
    
    /// need for overriding if need incapsulate data in Manager
    open func didUpdateData()
    {
        lastLocalUpdateData = Date()
        
        if let delegate = delegate {
            delegate.updateManagerUpdateData(self)
        }
        updateInterfaceExecute()
        
        dataUpdateQueue.async
            {[weak self] () -> Void in
                guard let this = self else {
                    return
                }
                this.checkLocalUpdateInterface = Date()
                this.isUpdating = false
                if (this.isWaittingNextUpdate) {
                    self?.internalUpdateData()
                }
        }
    }
    
    func invalidateUpdatedTime() {
        checkLocalUpdateData = Date().addingTimeInterval( -2 * updateDataInterval)
    }
    
    // this method only work in dataUpdateQueue
    internal func internalUpdateData() {
        invalidateUpdatedTime()
        internalCheckUpdate()
    }
    
    // this method only work in dataUpdateQueue
    internal func internalCheckUpdate() {
        if (fabs(checkLocalUpdateData.timeIntervalSinceNow) > updateDataInterval) {
            checkLocalUpdateData = Date()
            if isUpdating {
                isWaittingNextUpdate = true
            } else {
                isWaittingNextUpdate = false
                DispatchQueue.main.sync(execute: {[weak self]() -> Void in
                    guard let this = self else {
                        return
                    }
                    if this.isUpdating {
                        this.isUpdating = true
                        this.delegate?.updateManagerLoadData(this)
                    }
                })
            }
        } else if (fabs(checkLocalUpdateInterface.timeIntervalSinceNow) > updateInterfaceInterval) {
            checkLocalUpdateInterface = Date()
            DispatchQueue.main.sync(execute: {[weak self]() -> Void in
                self?.updateInterfaceExecute()
            })
        }
    }
    
    @objc fileprivate func checkTimerUpdate() {
        checkUpdate()
    }
    
    internal func updateInterfaceExecute()
    {
        if let delegate = delegate {
            delegate.updateManagerUpdateInterface(self)
        }
        didUpdateInterface()
    }
    
    internal func didUpdateInterface()
    {
        self.lastLocalUpdateInterface = Date()
    }
    
}
