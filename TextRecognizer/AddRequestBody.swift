//
//  AddRequestBody.swift
//  TextRecognizer
//
//  Created by Fodé Guirassy on 31/12/2018.
//  Copyright © 2018 Fodé Guirassy. All rights reserved.
//

import Foundation

class AddRequestBody : Codable {
    let label : String
    let data : [Double]

    init(aLabel : String, aData : [Double]) {
        self.label = aLabel
        self.data = aData
    }
    
}
