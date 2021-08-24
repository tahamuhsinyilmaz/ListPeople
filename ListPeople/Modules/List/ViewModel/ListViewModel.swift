//
//  ListViewModel.swift
//  ListPeople
//
//  Created by Taha  YILMAZ on 23.08.2021.
//

import Foundation

enum AlertType {
    case ok
    case retry
}

class ListViewModel {
    enum Change {
        case people([Person])
        case alert(String, AlertType)
        case activityIndicator(Bool)
        case emptyTable(Bool)
    }
    
    private let changeHandler: ((Change)->Void)
    private var next: String? = nil
    private var isFetching: Bool = false
    private var peopleArray: [Person] = [] {
        didSet {
            changeHandler(.people(peopleArray))
        }
    }
    
    init(changeHandler: @escaping ((Change)->Void)) {
        self.changeHandler = changeHandler
    }
    
    func fetchFirst() {
        if !isFetching {
            isFetching = true
            changeHandler(.activityIndicator(isFetching))
            DataSource.fetch(next: nil) {[unowned self] response, error in
                isFetching = false
                handleRespose(response: response, error: error)
            }
        }
        
    }
    
    func fetchPeople() {
        guard let next = self.next else {return}
        changeHandler(.activityIndicator(true))
        DataSource.fetch(next: next) {[unowned self] response, error in
            handleRespose(response: response, error: error)
        }
    }
    
    func refresh() {
        self.next = nil
        peopleArray = []
        fetchFirst()
    }
    
    func hardRefresh() {
        self.next = nil
        peopleArray = []
        DataSource.hardRefresh { [unowned self] response, error in
            handleRespose(response: response, error: error)
        }
    }
}

//MARK: - Handling Response
private extension ListViewModel {
    func handleRespose(response: FetchResponse?, error: FetchError?) {
        self.changeHandler(.activityIndicator(false))
        if let error = error {
            self.handleError(errorMessage: error.errorDescription)
        }else if let response = response {
            self.handleSuccess(response: response)
        }else {
            self.handleError(errorMessage: AppStrings.unexpectedError)
        }
    }
    
    func handleSuccess(response: FetchResponse) {
        self.next = response.next
        for i in response.people {
            if !peopleArray.contains(where: {$0.id == i.id}) {
                peopleArray.append(i)
            }
        }
        changeHandler(.emptyTable(peopleArray.isEmpty))
    }
    
    func handleError(errorMessage: String) {
        let alertType: AlertType = peopleArray.isEmpty ? .ok:.retry
        changeHandler(.emptyTable(peopleArray.isEmpty))
        changeHandler(.alert(errorMessage, alertType))
        
    }
}
