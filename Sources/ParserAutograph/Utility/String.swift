//
// Project «ParserAutograph»
// Created by Jeorge Taflanidi
//


import Foundation


extension String {
    var indent: String {
        return self
            .components(separatedBy: "\n")
            .map { $0.isEmpty ? $0 : "    " + $0 }
            .joined(separator: "\n")
    }
}
