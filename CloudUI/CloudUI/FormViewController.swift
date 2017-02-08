//
//  FormViewController.swift
//  CloudUI
//
//  Created by Tobias Kräntzer on 08.02.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import Fountain

class FormViewController: UITableViewController, UITableViewDelegateCellAction {
    
    var dataSource: FTDataSource? {
        didSet {
            tableViewAdapter?.dataSource = dataSource
        }
    }
    
    private var tableViewAdapter: FTTableViewAdapter?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.allowsSelection = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 45
        
        tableViewAdapter = FTTableViewAdapter(tableView: tableView)
        
        tableView.register(FormValueItemCell.self, forCellReuseIdentifier: "FormValueItemCell")
        tableViewAdapter?.forRowsMatching(
            FormValueItemCell.predicate,
            useCellWithReuseIdentifier: "FormValueItemCell"
        ) { view, item, _, _ in
            if let cell = view as? FormValueItemCell,
                let formItem = item as? FormValueItem {
                cell.item = formItem
            }
        }
        
        tableView.register(FormTextItemCell.self, forCellReuseIdentifier: "FormTextItemCell")
        tableViewAdapter?.forRowsMatching(
            FormTextItemCell.predicate,
            useCellWithReuseIdentifier: "FormTextItemCell"
        ) { view, item, _, _ in
            if let cell = view as? FormTextItemCell,
                let formItem = item as? FormTextItem {
                cell.item = formItem
            }
        }
        
        tableView.register(FormURLItemCell.self, forCellReuseIdentifier: "FormURLItemCell")
        tableViewAdapter?.forRowsMatching(
            FormURLItemCell.predicate,
            useCellWithReuseIdentifier: "FormURLItemCell"
        ) { view, item, _, _ in
            if let cell = view as? FormURLItemCell,
                let formItem = item as? FormURLItem {
                cell.item = formItem
            }
        }
        
        tableView.register(FormButtonItemCell.self, forCellReuseIdentifier: "FormButtonItemCell")
        tableViewAdapter?.forRowsMatching(
            FormButtonItemCell.predicate,
            useCellWithReuseIdentifier: "FormButtonItemCell"
        ) { view, item, _, _ in
            if let cell = view as? FormButtonItemCell,
                let formItem = item as? FormButtonItem {
                cell.item = formItem
            }
        }
        
        tableViewAdapter?.delegate = self
        tableViewAdapter?.dataSource = dataSource
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionItem = dataSource?.sectionItem(forSection: UInt(section)) as? FormSection {
            return sectionItem.title
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let sectionItem = dataSource?.sectionItem(forSection: UInt(section)) as? FormSection {
            return sectionItem.instructions
        } else {
            return nil
        }
    }
    
}

