//
//  SearchPanelDemoViewController.swift
//  SearchPanel
//
//  Created by mathieu lecoupeur on 01/07/2017.
//  Copyright © 2017 mathieu lecoupeur. All rights reserved.
//

import UIKit

class SearchPanelDemoViewController: UIViewController {
    
    @IBOutlet var seacrhPanelHeightConstraint: NSLayoutConstraint?
    
    @IBOutlet var searchPanel: SearchPanelViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Getting searchPanel from container
        searchPanel = childViewControllers.first as? SearchPanelViewController
        
        // Configuring delegates
        searchPanel?.delegate = self
        searchPanel?.listDelegate = self
        
        // Registering cells
        searchPanel?.register(cellClass: UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
        
        // Setting SearchBar placeholder
        searchPanel?.setSearchBarPlaceholder(placeholder: "Search")
    }
}

extension SearchPanelDemoViewController: SearchPanelDelegate {
    
    func containerHeightConstraint() -> NSLayoutConstraint {
        
        return seacrhPanelHeightConstraint!
    }
    
    func closedOffset() -> Float {
        
        return 60
    }
    
    func partialOffset() -> Float {
        
        return 300
    }
    
    func openOffset() -> Float {
        
        return Float(view.bounds.size.height) - 60
    }
}

extension SearchPanelDemoViewController: SearchPanelListDelegate {
    
    func findAroundMe() {
        
        print("FIND AROUND ME")
    }
}

extension SearchPanelDemoViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 50
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell")
        
        cell?.textLabel?.text = "CELL \(indexPath.row)"
        cell?.backgroundColor = UIColor.clear
        
        return cell!
    }
}

extension SearchPanelDemoViewController: UITableViewDelegate {
    
}

extension SearchPanelDemoViewController: UIScrollViewDelegate {
    
    /* !IMPORTANT !*/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        searchPanel?.scrollViewDidScroll(scrollView)
    }
}

extension SearchPanelDemoViewController: UISearchBarDelegate {
    
    /* !IMPORTANT !*/
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchPanel?.setState(state: .opened, animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // do search
    }
    
    /* !IMPORTANT !*/
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        hideKeyboardAndSuggestionList()
    }
    
    /* !IMPORTANT !*/
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        hideKeyboardAndSuggestionList()
    }
    
    /* !IMPORTANT !*/
    fileprivate func hideKeyboardAndSuggestionList() {
        
        searchPanel?.setState(state: .closed)
    }
}
