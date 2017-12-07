//
// Project «ParserAutograph»
// Created by Jeorge Taflanidi
//


import Foundation
import Synopsis


extension ClassDescription {
    var inheritesDecodable: Bool {
        return inheritedTypes.contains("Decodable") || inheritedTypes.contains("Codable")
    }
}


extension StructDescription {
    var inheritesDecodable: Bool {
        return inheritedTypes.contains("Decodable") || inheritedTypes.contains("Codable")
    }
}


extension PropertyDescription {
    var hasJsonKey: Bool {
        return annotations.contains(annotationName: "json")
    }
    
    var jsonKey: String? {
        return annotations["json"]?.value
    }
}
