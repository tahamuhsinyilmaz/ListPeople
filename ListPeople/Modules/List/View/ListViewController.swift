//
//  ListViewController.swift
//  ListPeople
//
//  Created by Taha  YILMAZ on 23.08.2021.
//

import UIKit

class ListViewController: UITableViewController {
    
    private enum Constants {
        static let bundleNameKey: String = "CFBundleName"
        static let cellId: String = "CELL_ID"
        static let paginationTrigger: Int = 3
    }
    
    private var viewModel: ListViewModel!
    
    private var people = [Person]() {
        didSet {
            tableView.reloadData()
        }
        
    }
    
    private var tableViewBackground: EmptyTableBackground {
        let view = EmptyTableBackground(retryCompletion: {[weak self] in
            self?.viewModel.fetchFirst()
        })
        return view
    }
    
    private var activityIndicator: UIActivityIndicatorView {
        let act = UIActivityIndicatorView()
        act.hidesWhenStopped = true
        act.translatesAutoresizingMaskIntoConstraints = false
        return act
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        bindViewModel()
        viewModel.fetchFirst()
    }
    
    private func configureView() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refreshControlAction), for: .valueChanged)
        
        title = Bundle.main.object(forInfoDictionaryKey: Constants.bundleNameKey) as? String
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.hardRefresh,
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(hardRefreshAction))
    }
    
    @objc func refreshControlAction() {
        viewModel.refresh()
    }
    
    @objc func hardRefreshAction() {
        viewModel.hardRefresh()
    }
    
    private func fetchPeople() {
        viewModel.fetchPeople()
    }
}

// MARK: - TableView Delegation and Data Source
extension ListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellId, for: indexPath)
        let person = people[indexPath.row]
        cell.textLabel?.text = "\(person.fullName) (\(person.id))"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == people.count - Constants.paginationTrigger {
            fetchPeople()
        }
    }
}


//MARK: - ViewModel and Changes Binding
private extension ListViewController {
    func bindViewModel() {
        viewModel = ListViewModel(changeHandler: {[unowned self] change in
            switch change {
            case .alert(let message, let alertType):
                didReceiveAlert(message: message, alertType: alertType)
            case .people(let people):
                self.people = people
            case .activityIndicator(let isShown):
                didReceiveIndicator(isShown: isShown)
            case .emptyTable(let isEmpty):
                didReceiveEmptyTable(isEmpty: isEmpty)
            }
        })
    }
    
    func didReceiveAlert(message: String, alertType: AlertType) {
        switch alertType {
        case .ok:
            showAlert(message: message)
        case .retry:
            showAlert(buttonTitle: AppStrings.retry,
                      message: message) { [weak self] action in
                self?.fetchPeople()
            }
        }
    }
    
    func didReceiveIndicator(isShown: Bool) {
        if isShown {
            if !self.refreshControl!.isRefreshing {
                self.refreshControl?.beginRefreshing()
            }
        }else {
            if self.refreshControl!.isRefreshing {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    func didReceiveEmptyTable(isEmpty: Bool) {
        if isEmpty {
            tableView.backgroundView = tableViewBackground
        }else {
            tableView.backgroundView = nil
        }
    }
}
