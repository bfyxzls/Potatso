//
//  ICSPullToRefresh.swift
//  Vendored & patched for Xcode 15 / Swift 5
//

import UIKit

private var pullToRefreshViewKey: Void?

public typealias ActionHandler = () -> Void

private struct Constants {
    static let observeKeyContentOffset = "contentOffset"
    static let observeKeyFrame = "frame"
    static let pullToRefreshViewValueKey = "ICSPullToRefreshView"
    static let pullToRefreshViewHeight: CGFloat = 60
}

public extension UIScrollView {

    var pullToRefreshView: PullToRefreshView? {
        get {
            return objc_getAssociatedObject(self, &pullToRefreshViewKey) as? PullToRefreshView
        }
        set(newValue) {
            willChangeValue(forKey: Constants.pullToRefreshViewValueKey)
            objc_setAssociatedObject(self, &pullToRefreshViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            didChangeValue(forKey: Constants.pullToRefreshViewValueKey)
        }
    }

    var showsPullToRefresh: Bool {
        guard let pullToRefreshView = pullToRefreshView else {
            return false
        }
        return !pullToRefreshView.isHidden
    }

    func addPullToRefreshHandler(_ actionHandler: @escaping ActionHandler) {
        if pullToRefreshView == nil {
            pullToRefreshView = PullToRefreshView(
                frame: CGRect(
                    x: 0,
                    y: -Constants.pullToRefreshViewHeight,
                    width: bounds.width,
                    height: Constants.pullToRefreshViewHeight
                )
            )
            addSubview(pullToRefreshView!)
            pullToRefreshView?.autoresizingMask = .flexibleWidth
            pullToRefreshView?.scrollViewOriginContentTopInset = contentInset.top
        }
        pullToRefreshView?.actionHandler = actionHandler
        setShowsPullToRefresh(true)
    }

    func triggerPullToRefresh() {
        pullToRefreshView?.state = .triggered
        pullToRefreshView?.startAnimating()
    }

    func setShowsPullToRefresh(_ showsPullToRefresh: Bool) {
        guard let pullToRefreshView = pullToRefreshView else {
            return
        }
        pullToRefreshView.isHidden = !showsPullToRefresh
        if showsPullToRefresh {
            addPullToRefreshObservers()
        } else {
            removePullToRefreshObservers()
        }
    }

    func addPullToRefreshObservers() {
        guard let pullToRefreshView = pullToRefreshView, !pullToRefreshView.isObserving else {
            return
        }
        addObserver(pullToRefreshView, forKeyPath: Constants.observeKeyContentOffset, options: .new, context: nil)
        addObserver(pullToRefreshView, forKeyPath: Constants.observeKeyFrame, options: .new, context: nil)
        pullToRefreshView.isObserving = true
    }

    func removePullToRefreshObservers() {
        guard let pullToRefreshView = pullToRefreshView, pullToRefreshView.isObserving else {
            return
        }
        removeObserver(pullToRefreshView, forKeyPath: Constants.observeKeyContentOffset)
        removeObserver(pullToRefreshView, forKeyPath: Constants.observeKeyFrame)
        pullToRefreshView.isObserving = false
    }
}

open class PullToRefreshView: UIView {
    open var actionHandler: ActionHandler?
    open var isObserving: Bool = false
    var triggeredByUser: Bool = false

    open var scrollView: UIScrollView? {
        return superview as? UIScrollView
    }

    open var scrollViewOriginContentTopInset: CGFloat = 0

    public enum State {
        case stopped
        case triggered
        case loading
        case all
    }

    open var state: State = .stopped {
        willSet {
            if state != newValue {
                setNeedsLayout()
                switch newValue {
                case .loading:
                    setScrollViewContentInsetForLoading()
                    if state == .triggered {
                        actionHandler?()
                    }
                default:
                    break
                }
            }
        }
        didSet {
            switch state {
            case .stopped:
                resetScrollViewContentInset()
            default:
                break
            }
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initViews()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initViews()
    }

    open func startAnimating() {
        if scrollView == nil {
            return
        }
        animate {
            guard let scrollView = self.scrollView else { return }
            scrollView.setContentOffset(
                CGPoint(
                    x: scrollView.contentOffset.x,
                    y: -(scrollView.contentInset.top + self.bounds.height)
                ),
                animated: false
            )
        }
        triggeredByUser = true
        state = .loading
    }

    open func stopAnimating() {
        state = .stopped
        if triggeredByUser {
            animate {
                guard let scrollView = self.scrollView else { return }
                scrollView.setContentOffset(
                    CGPoint(
                        x: scrollView.contentOffset.x,
                        y: -scrollView.contentInset.top
                    ),
                    animated: false
                )
            }
        }
    }

    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == Constants.observeKeyContentOffset {
            let point = (change?[.newKey] as? NSValue)?.cgPointValue
            srollViewDidScroll(point)
        } else if keyPath == Constants.observeKeyFrame {
            setNeedsLayout()
        }
    }

    private func srollViewDidScroll(_ contentOffset: CGPoint?) {
        guard let scrollView = scrollView, let contentOffset = contentOffset else {
            return
        }
        guard state != .loading else {
            return
        }
        let scrollOffsetThreshold = frame.origin.y - scrollViewOriginContentTopInset
        if !scrollView.isDragging && state == .triggered {
            state = .loading
        } else if contentOffset.y < scrollOffsetThreshold && scrollView.isDragging && state == .stopped {
            state = .triggered
        } else if contentOffset.y >= scrollOffsetThreshold && state != .stopped {
            state = .stopped
        }
    }

    private func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        animate {
            self.scrollView?.contentInset = contentInset
        }
    }

    private func resetScrollViewContentInset() {
        guard let scrollView = scrollView else { return }
        var currentInset = scrollView.contentInset
        currentInset.top = scrollViewOriginContentTopInset
        setScrollViewContentInset(currentInset)
    }

    private func setScrollViewContentInsetForLoading() {
        guard let scrollView = scrollView else { return }
        let offset = max(scrollView.contentOffset.y * -1, 0)
        var currentInset = scrollView.contentInset
        currentInset.top = min(offset, scrollViewOriginContentTopInset + bounds.height)
        setScrollViewContentInset(currentInset)
    }

    private func animate(_ animations: @escaping () -> Void) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: animations
        ) { _ in
            self.setNeedsLayout()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        defaultView.frame = bounds
        activityIndicator.center = defaultView.center
        switch state {
        case .stopped:
            activityIndicator.stopAnimating()
        case .loading:
            activityIndicator.startAnimating()
        default:
            break
        }
    }

    open override func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview == nil,
              superview != nil,
              let showsPullToRefresh = scrollView?.showsPullToRefresh,
              showsPullToRefresh else {
            return
        }
        scrollView?.removePullToRefreshObservers()
    }

    private func initViews() {
        addSubview(defaultView)
        defaultView.addSubview(activityIndicator)
    }

    private lazy var defaultView: UIView = UIView()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = false
        return indicator
    }()

    open func setActivityIndicatorColor(_ color: UIColor) {
        activityIndicator.color = color
    }

    open func setActivityIndicatorStyle(_ style: UIActivityIndicatorView.Style) {
        activityIndicator.style = style
    }
}
