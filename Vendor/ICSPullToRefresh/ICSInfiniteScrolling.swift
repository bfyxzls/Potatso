//
//  ICSInfiniteScrolling.swift
//  Vendored & patched for Xcode 15 / Swift 5
//

import UIKit

private var infiniteScrollingViewKey: Void?

private struct InfiniteConstants {
    static let observeKeyContentOffset = "contentOffset"
    static let observeKeyContentSize = "contentSize"
    static let observeKeyContentInset = "contentInset"
    static let infiniteScrollingViewValueKey = "ICSInfiniteScrollingView"
    static let infiniteScrollingViewHeight: CGFloat = 60
}

public extension UIScrollView {

    var infiniteScrollingView: InfiniteScrollingView? {
        get {
            return objc_getAssociatedObject(self, &infiniteScrollingViewKey) as? InfiniteScrollingView
        }
        set(newValue) {
            willChangeValue(forKey: InfiniteConstants.infiniteScrollingViewValueKey)
            objc_setAssociatedObject(self, &infiniteScrollingViewKey, newValue, .OBJC_ASSOCIATION_RETAIN)
            didChangeValue(forKey: InfiniteConstants.infiniteScrollingViewValueKey)
        }
    }

    var showsInfiniteScrolling: Bool {
        guard let infiniteScrollingView = infiniteScrollingView else {
            return false
        }
        return !infiniteScrollingView.isHidden
    }

    func addInfiniteScrollingWithHandler(_ actionHandler: @escaping ActionHandler) {
        if infiniteScrollingView == nil {
            infiniteScrollingView = InfiniteScrollingView(
                frame: CGRect(
                    x: 0,
                    y: contentSize.height,
                    width: bounds.width,
                    height: InfiniteConstants.infiniteScrollingViewHeight
                )
            )
            addSubview(infiniteScrollingView!)
            infiniteScrollingView?.autoresizingMask = .flexibleWidth
            infiniteScrollingView?.scrollViewOriginContentBottomInset = contentInset.bottom
        }
        infiniteScrollingView?.actionHandler = actionHandler
        setShowsInfiniteScrolling(true)
    }

    func triggerInfiniteScrolling() {
        infiniteScrollingView?.state = .triggered
        infiniteScrollingView?.startAnimating()
    }

    func setShowsInfiniteScrolling(_ showsInfiniteScrolling: Bool) {
        guard let infiniteScrollingView = infiniteScrollingView else {
            return
        }
        infiniteScrollingView.isHidden = !showsInfiniteScrolling
        if showsInfiniteScrolling {
            addInfiniteScrollingViewObservers()
        } else {
            removeInfiniteScrollingViewObservers()
            infiniteScrollingView.setNeedsLayout()
            infiniteScrollingView.frame = CGRect(
                x: 0,
                y: contentSize.height,
                width: infiniteScrollingView.bounds.width,
                height: InfiniteConstants.infiniteScrollingViewHeight
            )
        }
    }

    fileprivate func addInfiniteScrollingViewObservers() {
        guard let infiniteScrollingView = infiniteScrollingView, !infiniteScrollingView.isObserving else {
            return
        }
        addObserver(infiniteScrollingView, forKeyPath: InfiniteConstants.observeKeyContentOffset, options: .new, context: nil)
        addObserver(infiniteScrollingView, forKeyPath: InfiniteConstants.observeKeyContentSize, options: .new, context: nil)
        infiniteScrollingView.isObserving = true
    }

    fileprivate func removeInfiniteScrollingViewObservers() {
        guard let infiniteScrollingView = infiniteScrollingView, infiniteScrollingView.isObserving else {
            return
        }
        removeObserver(infiniteScrollingView, forKeyPath: InfiniteConstants.observeKeyContentOffset)
        removeObserver(infiniteScrollingView, forKeyPath: InfiniteConstants.observeKeyContentSize)
        infiniteScrollingView.isObserving = false
    }
}

open class InfiniteScrollingView: UIView {
    open var actionHandler: ActionHandler?
    open var isObserving: Bool = false

    open var scrollView: UIScrollView? {
        return superview as? UIScrollView
    }

    open var scrollViewOriginContentBottomInset: CGFloat = 0

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
                    setScrollViewContentInsetForInfiniteScrolling()
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
        state = .loading
    }

    open func stopAnimating() {
        state = .stopped
    }

    open override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == InfiniteConstants.observeKeyContentOffset {
            let point = (change?[.newKey] as? NSValue)?.cgPointValue
            srollViewDidScroll(point)
        } else if keyPath == InfiniteConstants.observeKeyContentSize {
            setNeedsLayout()
            if let scrollView = scrollView {
                frame = CGRect(
                    x: 0,
                    y: scrollView.contentSize.height,
                    width: bounds.width,
                    height: InfiniteConstants.infiniteScrollingViewHeight
                )
            }
        }
    }

    private func srollViewDidScroll(_ contentOffset: CGPoint?) {
        guard let scrollView = scrollView, let contentOffset = contentOffset else {
            return
        }
        guard state != .loading else {
            return
        }
        let scrollViewContentHeight = scrollView.contentSize.height
        var scrollOffsetThreshold = scrollViewContentHeight - scrollView.bounds.height + 40
        if scrollViewContentHeight < scrollView.bounds.height {
            scrollOffsetThreshold = 40 - scrollView.contentInset.top
        }

        activityIndicator.hidesWhenStopped = !(
            scrollView.isDragging &&
            scrollViewContentHeight > scrollView.bounds.height
        )

        if !scrollView.isDragging && state == .triggered {
            state = .loading
        } else if contentOffset.y > scrollOffsetThreshold && state == .stopped && scrollView.isDragging {
            state = .triggered
        } else if contentOffset.y < scrollOffsetThreshold && state != .stopped {
            state = .stopped
        }
    }

    private func setScrollViewContentInset(_ contentInset: UIEdgeInsets) {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.allowUserInteraction, .beginFromCurrentState],
            animations: {
                self.scrollView?.contentInset = contentInset
            },
            completion: nil
        )
    }

    private func resetScrollViewContentInset() {
        guard let scrollView = scrollView else { return }
        var currentInset = scrollView.contentInset
        currentInset.bottom = scrollViewOriginContentBottomInset
        setScrollViewContentInset(currentInset)
    }

    private func setScrollViewContentInsetForInfiniteScrolling() {
        guard let scrollView = scrollView else { return }
        var currentInset = scrollView.contentInset
        currentInset.bottom = scrollViewOriginContentBottomInset + InfiniteConstants.infiniteScrollingViewHeight
        setScrollViewContentInset(currentInset)
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
              let showsInfiniteScrolling = scrollView?.showsInfiniteScrolling,
              showsInfiniteScrolling else {
            return
        }
        scrollView?.removeInfiniteScrollingViewObservers()
    }

    private func initViews() {
        addSubview(defaultView)
        defaultView.addSubview(activityIndicator)
    }

    private lazy var defaultView: UIView = UIView()

    private lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .gray)
        indicator.hidesWhenStopped = true
        return indicator
    }()

    open func setActivityIndicatorColor(_ color: UIColor) {
        activityIndicator.color = color
    }

    open func setActivityIndicatorStyle(_ style: UIActivityIndicatorView.Style) {
        activityIndicator.style = style
    }
}
