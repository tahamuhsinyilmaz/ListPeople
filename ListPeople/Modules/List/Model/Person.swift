//
//  Person.swift
//  ListPeople
//
//  Created by Taha  YILMAZ on 23.08.2021.
//

import Foundation

public class Person: NSObject {
    let id: Int
    let fullName: String
    
    init(id: Int, fullName: String) {
        self.id = id
        self.fullName = fullName
    }
}
