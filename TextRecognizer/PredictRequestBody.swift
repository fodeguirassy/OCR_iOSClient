//
//  PredictRequestBody.swift
//  TextRecognizer
//
//  Created by Fodé Guirassy on 31/12/2018.
//  Copyright © 2018 Fodé Guirassy. All rights reserved.
//

import Foundation

class PredictRequestBody : Codable {
    
    let data : [Double]
    
    init(aData : [Double]) {
        self.data = aData
    }
}
