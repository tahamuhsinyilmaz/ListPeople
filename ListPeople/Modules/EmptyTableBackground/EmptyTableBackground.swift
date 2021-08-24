//
//  EmptyTableBackground.swift
//  ListPeople
//
//  Created by Taha  YILMAZ on 24.08.2021.
//

import UIKit

class EmptyTableBackground: UIView {
    
    @IBOutlet private(set) weak var contentView: UIView!
    
    private let retryCompletion: () -> Void
    
    init(retryCompletion: @escaping () -> Void) {
        self.retryCompletion = retryCompletion
        super.init(frame: .zero)
        commonInit()
        contentView.frame = frame
    }

    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed("EmptyTableBackground", owner: self, options: nil)
        addSubview(contentView)
    }
    
    
    @IBAction func retryAction(_ sender: Any) {
        retryCompletion()
    }
}
