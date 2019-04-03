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
    
    /// This method need implement for loading data.
    /// In this body you must call stopLoading(with error) or stopLoading()
    func updateManagerLoadData(_ updateManager: BxUpdateManager)
    /// It call when data updated or need refresh user interface
    func updateManagerUpdateInterface(_ updateManager: BxUpdateManager)
    /// It call only when data updated
    func updateManagerUpdateData(_ updateManager: BxUpdateManager)
    
}

/// Manager for checking update from network and local.
open class BxUpdateManager {
    
    /// Waiting beetwen loading iteration can use different stratagies
    public enum WaitingStrategy : Int {
        /// next iteration waiting will initiate immediatly with starting of a loading data
        case fromStartLoading
        /// next iteration waiting will initiate only when a loading data has ended
        case fromStopLoading
    }
    
#if swift( >=4.2 )
    static let enterForegroundNotification = UIApplication.willEnterForegroundNotification
#else
    static let enterForegroundNotification = NSNotification.Name.UIApplicationWillEnterForeground
#endif
    
    /// Interval for waiting new iteration of a data updating
    public var updateDataInterval: TimeInterval
    /// Interval for waiting new iteration of a interface updating
    public var updateInterfaceInterval: TimeInterval
    /// Timer interval for checking needing of updates
    public var checkInterval: TimeInterval
    /// Waiting beetwen loading iteration can use different stratagies
    public var waitingStrategy: WaitingStrategy
    
    /// delegate of manager
    public weak var delegate: BxUpdateManagerDelegate? = nil
    
    // MARK - this use from main thread
    
    internal(set) public var error: Error? = nil
    internal(set) public var lastActivationDate: Date = Date(timeIntervalSince1970: 0)
    internal(set) public var lastUpdateDataDate: Date = Date(timeIntervalSince1970: 0)
    internal(set) public var lastUpdateInterfaceDate: Date = Date()
    
    
    // MARK - this use from checkUpdateQueue only
    internal(set) public var isUpdating: Bool = false
    internal(set) public var isWaittingNextUpdate = false
    fileprivate var checkUpdateDataDate: Date = Date(timeIntervalSince1970: 0)
    fileprivate var checkUpdateInterfaceDate: Date = Date()
    
    // MARK - it internal use
    fileprivate var timer: Timer? = nil
    fileprivate let reachability = Reachability.forInternetConnection()!
    fileprivate let dataUpdateQueue = DispatchQueue(label: "BxUpdateManager.DataUpdateQueue", qos: DispatchQoS.background)
    
    /// MARK -  first activation call update
    fileprivate var isFirstActivated: Bool = true
    
    ///
    /// If isActive == true will start checking,
    /// if you want to update data before, you can call updateData() before activation
    /// and isActive = true after that doesn't call update immediately
    ///
    /// Please set isActive = false else dealloc not will called
    ///
    public var isActive: Bool = false {
        didSet {
            timer?.invalidate()
            timer = nil
            if isActive {
                lastActivationDate = Date()
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
        checkInterval: TimeInterval = 5.0,
        waitingStrategy: WaitingStrategy = .fromStopLoading,
        isActive: Bool = false)
    {
        self.updateDataInterval = updateDataInterval
        self.updateInterfaceInterval = updateInterfaceInterval
        self.checkInterval = checkInterval
        self.waitingStrategy = waitingStrategy
    
        NotificationCenter.default.addObserver(self, selector: #selector(checkTimerUpdate), name: BxUpdateManager.enterForegroundNotification, object: nil)
        reachability.reachableBlock = { [weak self] (reachability) -> Void in
            DispatchQueue.main.async(execute: {[weak self]() -> Void in
                self?.checkUpdateWithError()
            })
        }
        ({self.isActive = isActive})()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: BxUpdateManager.enterForegroundNotification, object: nil)
        ({isActive = false})()
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
                if this.isActive {
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
    
    // MARK - private & internal methods
    
    fileprivate func didUpdateData()
    {
        lastUpdateDataDate = Date()
        
        if let delegate = delegate {
            delegate.updateManagerUpdateData(self)
        }
        updateInterfaceExecute()
        
        dataUpdateQueue.async
            {[weak self] () -> Void in
                guard let this = self else {
                    return
                }
                this.resetUpdateInterfaceTime()
                if this.waitingStrategy == .fromStopLoading {
                    this.resetUpdateDataTime()
                }
                this.isUpdating = false
                if this.isWaittingNextUpdate {
                    this.internalUpdateData()
                }
        }
    }
    
    // this method only work in dataUpdateQueue
    private func toUpdateData() {
        checkUpdateDataDate = Date().addingTimeInterval( -1 * updateDataInterval - 1)
    }
    
    // this method only work in dataUpdateQueue
    private func resetUpdateDataTime() {
        checkUpdateDataDate = Date()
    }
    
    // this method only work in dataUpdateQueue
    private func toUpdateInterface() {
        checkUpdateInterfaceDate = Date().addingTimeInterval( -1 * updateInterfaceInterval - 1)
    }
    
    // this method only work in dataUpdateQueue
    private func resetUpdateInterfaceTime() {
        checkUpdateInterfaceDate = Date()
    }
    
    // this method only work in dataUpdateQueue
    internal func internalUpdateData() {
        toUpdateData()
        internalCheckUpdate()
    }
    
    // this method only work in dataUpdateQueue
    internal func internalCheckUpdate() {
        if (fabs(checkUpdateDataDate.timeIntervalSinceNow) > updateDataInterval) {
            resetUpdateDataTime()
            if isUpdating {
                isWaittingNextUpdate = true
            } else {
                isWaittingNextUpdate = false
                DispatchQueue.main.sync(execute: {[weak self]() -> Void in
                    guard let this = self else {
                        return
                    }
                    this.isUpdating = true
                    this.delegate?.updateManagerLoadData(this)
                })
            }
        } else if (fabs(checkUpdateInterfaceDate.timeIntervalSinceNow) > updateInterfaceInterval) {
            resetUpdateInterfaceTime()
            DispatchQueue.main.sync(execute: {[weak self]() -> Void in
                self?.updateInterfaceExecute()
            })
        }
        if isUpdating && waitingStrategy == .fromStopLoading {
            resetUpdateDataTime()
        }
    }
    
    @objc fileprivate func checkTimerUpdate() {
        checkUpdate()
    }
    
    private func updateInterfaceExecute()
    {
        if let delegate = delegate {
            delegate.updateManagerUpdateInterface(self)
        }
        didUpdateInterface()
    }
    
    private func didUpdateInterface()
    {
        self.lastUpdateInterfaceDate = Date()
    }
    
}
