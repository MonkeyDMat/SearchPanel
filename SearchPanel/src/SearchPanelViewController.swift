//
//  SearchPanelViewController.swift
//  ITMRed
//
//  Created by Mathieu Lecoupeur on 30/06/2017.
//  Copyright © 2017 mathieu lecoupeur. All rights reserved.
//

import UIKit

public protocol SearchPanelDelegate: class {
    
    func containerHeightConstraint() -> NSLayoutConstraint
    func closedOffset() -> Float
    func partialOffset() -> Float
    func openOffset() -> Float
}

public protocol SearchPanelListDelegate: UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    func findAroundMe()
}

public enum SearchPanelState {
    case closed
    case partial
    case opened
}

public class SearchPanelViewController: UIViewController {
    
    // Menu Const
    private let VELOCITY_ATTENUATION = CGFloat(10)
    private var CORNER_RADIUS = CGFloat(10)
    
    // Outlets
    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak private var searchBar: UISearchBar!
    @IBOutlet weak private var handler: UIView!
    
    // Delegates
    public weak var delegate: SearchPanelDelegate? {
        didSet {
            openMenu(state: currentState, animated: false)
        }
    }
    public weak var listDelegate: SearchPanelListDelegate? {
        didSet {
            tableView.dataSource = listDelegate
            tableView.delegate = listDelegate
            searchBar.delegate = listDelegate
        }
    }
    
    // Private vars
    private var containerHeightConstraint: NSLayoutConstraint?
    private var panGesture: UIPanGestureRecognizer!
    private var currentState: SearchPanelState = .closed
    private var heightAtGestureStart: CGFloat = CGFloat(0)
    var isContainerFullyOpened: Bool = true
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Pan Gesture
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(SearchPanelViewController.onPanGesture(gesture:)))
        panGesture.delegate = self
        view.addGestureRecognizer(panGesture)
        
        tableView.delegate = listDelegate
        tableView.dataSource = listDelegate
        
        // Blur Effect
        view.layer.cornerRadius = CORNER_RADIUS
        view.clipsToBounds = true
        
        let blur = UIBlurEffect(style: .light)
        let visualEffectView = UIVisualEffectView(effect: blur)
        
        visualEffectView.frame = view.bounds
        visualEffectView.layer.cornerRadius = CORNER_RADIUS
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.insertSubview(visualEffectView, at: 0)
        
        // Handler
        handler.layer.cornerRadius = 2
    }
    
    //MARK: - Table View Wrapper
    public func register(nib: UINib?, forCellReuseIdentifier identifier: String) {
        
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    public func register(cellClass: Swift.AnyClass?, forCellReuseIdentifier identifier: String) {
        
        tableView.register(cellClass, forCellReuseIdentifier: identifier)
    }
    
    public func register(nib: UINib?, forHeaderFooterViewReuseIdentifier identifier: String) {
        
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func register(aClass: Swift.AnyClass?, forHeaderFooterViewReuseIdentifier identifier: String) {
        
        tableView.register(aClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func refreshList() {
        
        tableView.reloadData()
    }
    
    //MARK: - SearchBar Wrapper
    public func setSearchBarPlaceholder(placeholder: String) {
        
        searchBar.placeholder = placeholder
    }
    
    public func searchBarEndedEditing() {
        
        searchBar.endEditing(true)
    }
    
    public func setSearchBarText(text: String?) {
        
        searchBar.text = text
    }
    
    //MARK: - Pan Gesture handler
    func onPanGesture(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
            
            case .began:
                // Saving opening offset when gesture begins
                heightAtGestureStart = delegate!.containerHeightConstraint().constant
                break
            
            case .changed:
                followPan(gesture: gesture)
                break
            
            case .ended:
                // Move to closest anchor
                if tableView.contentOffset.y == 0 {
                    let velocity =  Float(-gesture.velocity(in: view).y / VELOCITY_ATTENUATION)
                    magnetize(velocity: velocity)
                }
                break
            
            default:
                break
        }
    }
    
    // Methods that enables or disable table views scroll
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if !isContainerFullyOpened {
            tableView.contentOffset = CGPoint.zero
        }
    }
    
    // MARK: - IBActions
    @IBAction func findAroundMe() {
        
        listDelegate?.findAroundMe()
    }
    
    // MARK: - Public Methods
    public func setState(state: SearchPanelState, animated: Bool = true) {
        openMenu(state: state, animated: animated, velocity: 1)
    }
    
    // MARK: - Private Methods
    private func followPan(gesture: UIPanGestureRecognizer) {
        
        guard let delegate = delegate else {
            return
        }
        
        // Getting gesture's translation vector
        let translation = gesture.translation(in: view)
        
        // Calculating nextPosition of the container
        let nextPos = heightAtGestureStart - translation.y
        
        // Getting max offset after which we should stop scrolling and enable table view
        let openedOffset = CGFloat(getOffsetForState(state: .opened))
        
        if (nextPos < openedOffset) && (tableView.contentOffset.y <= 0) {
            // Moving Container
            delegate.containerHeightConstraint().constant = nextPos
            isContainerFullyOpened = false
        } else {
            // Moving tableView
            heightAtGestureStart = delegate.containerHeightConstraint().constant + translation.y
            delegate.containerHeightConstraint().constant = openedOffset
            isContainerFullyOpened = true
        }
    }
    
    private func magnetize(velocity: Float) {
        
        guard let delegate = delegate else {
            return
        }
        
        // Getting offsets from delegate
        let closedOffset = getOffsetForState(state: .closed)
        let partialOffset = getOffsetForState(state: .partial)
        let openedOffset = getOffsetForState(state: .opened)
        
        // Getting current container position
        let containerOffset = Float(delegate.containerHeightConstraint().constant)
        
        // Adding velocity
        let containerOffsetWithVelocity = containerOffset + velocity
        
        // Calculating distance between current container position and anchors
        let closedDiff = abs(containerOffsetWithVelocity - closedOffset)
        let partialDiff = abs(containerOffsetWithVelocity - partialOffset)
        let openedDiff = abs(containerOffsetWithVelocity - openedOffset)
        
        // Getting anchor
        var diffs = [closedDiff, partialDiff, openedDiff]
        var anchors = [SearchPanelState.closed, SearchPanelState.partial, SearchPanelState.opened]
        
        // Removing far anchors to prevent changes from closed to opened or opened to closed
        if containerOffset < partialOffset {
            diffs.remove(at: 2)
            anchors.remove(at: 2)
        } else {
            diffs.remove(at: 0)
            anchors.remove(at: 0)
        }
        
        let anchor = min(valuesToCompare: diffs, valuesToReturn: anchors)
        
        // Opening menu to closest anchor
        openMenu(state: anchor!, animated: true, velocity: velocity)
    }
    
    private func openMenu(state: SearchPanelState, animated: Bool = true, velocity: Float = 1) {
        
        let closestOffset = getOffsetForState(state: state)
        
        currentState = state
        
        if state != .opened {
            searchBar.endEditing(true)
        }
        
        if animated {
            
            let animationVelocity = CGFloat(abs(velocity)) / UIScreen.main.bounds.height
            
            UIView.animate(withDuration: 0.5,
                           delay: 0,
                           usingSpringWithDamping: 0.5,
                           initialSpringVelocity: animationVelocity,
                           options: [.beginFromCurrentState, .overrideInheritedDuration, .allowUserInteraction],
                           animations: {
                            
                            self.delegate?.containerHeightConstraint().constant = CGFloat(closestOffset)
                            self.view.superview?.superview?.layoutIfNeeded()
            }, completion: { (_) in
            })
        } else {
            self.delegate?.containerHeightConstraint().constant = CGFloat(closestOffset)
        }
    }
    
    private func getOffsetForState(state: SearchPanelState) -> Float {
        
        guard let delegate = delegate else {
            return 100
        }
        
        switch state {
            case .closed:
                return delegate.closedOffset()
            
            case .partial:
                return delegate.partialOffset()
            
            case .opened:
                return delegate.openOffset()
        }
    }
}

extension SearchPanelViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}
