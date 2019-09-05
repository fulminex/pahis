//
//  UITextViewExtensions.swift
//  PaHis
//
//  Created by Angel Herrera Medina on 9/5/19.
//  Copyright © 2019 Maple. All rights reserved.
//

import Foundation

extension UITextView {
    
//    func centerVertically() {
//        let fittingSize = CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude)
//        let size = sizeThatFits(fittingSize)
//        let topOffset = (bounds.size.height - size.height * zoomScale) / 2
//        let positiveTopOffset = max(1, topOffset)
//        contentOffset.y = -positiveTopOffset
//    }
    
    func adjustContentSize(){
        let deadSpace = self.bounds.size.height - self.contentSize.height
        let inset = max(0, deadSpace/2.0)
        self.contentInset = UIEdgeInsets(top: inset, left: self.contentInset.left, bottom: inset, right: self.contentInset.right)
    }
}
