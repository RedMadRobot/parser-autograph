//
// Project «ParserAutograph»
// Created by Jeorge Taflanidi
//


import Foundation
import Autograph
import Synopsis


class App: AutographApplication {
    override func printHelp() {
        super.printHelp()
        print("""
        -input
        Input folder with model source files.
        If not set, current working directory is used as an input folder.

        -output
        Where to put generated files.
        If not set, current working directory is used as an input folder.


        """)
    }
    
    enum ExecutionError: Error, CustomStringConvertible {
        case noInputFolder
        
        var description: String {
            switch self {
                case .noInputFolder: return "PLEASE PROVIDE AN -input FOLDER!"
            }
        }
    }
    
    override func provideInputFoldersList(fromParameters parameters: ExecutionParameters) throws -> [String] {
        guard let input: String = parameters["-input"]
        else { throw ExecutionError.noInputFolder }
        return [input]
    }
    
    override func compose(forSynopsis synopsis: Synopsis, parameters: ExecutionParameters) throws -> [Implementation] {
        let output: String = parameters["-output"] ?? "."
        
        var models: [Model] = []
        
        try synopsis.classes.forEach { (classDescription: ClassDescription) in
            guard classDescription.annotations.contains(annotationName: "model")
            else {
                throw XcodeMessage(
                    declaration: classDescription.declaration,
                    message: "[MY GENERATOR] THIS CLASS IS NOT A MODEL"
                )
            }
        }
        
        synopsis.classes
            .filter { $0.inheritesDecodable }
            .forEach { models.append(Model(name: $0.name, properties: $0.properties)) }
        
        synopsis.structures
            .filter { $0.inheritesDecodable }
            .forEach { models.append(Model(name: $0.name, properties: $0.properties)) }
        
        let sourceCode = objectParser + composeDecodableExtensions(forModels: models)
        
        let implementation = Implementation(
            filePath: output + "/ObjectParser.swift",
            sourceCode: sourceCode
        )
        
        return [implementation]
    }
    
    func composeDecodableExtensions(forModels models: [Model]) -> String {
        return models.reduce("\n") { (result: String, model: Model) -> String in
            let jsonKeys: [(String, String)] =
                model.properties
                    .map { (property: PropertyDescription) -> (String, String) in
                        if !property.hasJsonKey {
                            print(
                                XcodeMessage(
                                    declaration: property.declaration,
                                    message: "[ParserAutograph] Property does not have @json annotation; property name is implicitly used as a JSON key"
                                )
                            )
                        }
                        
                        let jsonKey: String = property.jsonKey ?? property.name
                        return (property.name, jsonKey)
                    }
            
            let codingKeysEnumCases: [EnumCase] =
                jsonKeys.map { (propertyNameJsonKey: (String, String)) -> EnumCase in
                    return EnumCase.template(
                        comment: nil,
                        name: propertyNameJsonKey.0,
                        defaultValue: "\"\(propertyNameJsonKey.1)\""
                    )
                }
            
            let codingKeysEnum: EnumDescription =
                EnumDescription.template(
                    comment: nil,
                    accessibility: Accessibility.`internal`,
                    name: "CodingKeys",
                    inheritedTypes: ["String", "CodingKey"],
                    cases: codingKeysEnumCases,
                    properties: [],
                    methods: []
                )
            
            return result + """
                extension \(model.name) {
                
                \(codingKeysEnum.verse.indent)
                }
                
                """ + (models.last == model ? "" : "\n")
        }
    }
    
    private let objectParser = """
    import Foundation

    class ObjectParser<Model: Decodable> {
        let decoder = JSONDecoder()
        var logErrors: Bool = false
        
        func parse(any: Any?) -> [Model] {
            if let data: Data = any as? Data {
                return parse(data: data)
            }
            
            if let dictionary: [String: Any] = any as? [String: Any] {
                return parse(dictionary: dictionary)
            }
            
            if let array: [Any] = any as? [Any] {
                return parse(array: array)
            }
            
            return []
        }
        
        func parse(data: Data) -> [Model] {
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                return parse(any: jsonObject)
            } catch {
                return []
            }
        }
        
        func parse(dictionary: [String: Any]) -> [Model] {
            return dictionary.keys.reduce(decode(dictionary: dictionary)) { $0 + parse(any: dictionary[$1]) }
        }
        
        func parse(array: [Any]) -> [Model] {
            return array.flatMap { parse(any: $0) }
        }
        
        func decode(dictionary: [String: Any]) -> [Model] {
            do {
                let dictionaryData: Data = try JSONSerialization.data(withJSONObject: dictionary)
                return try [decoder.decode(Model.self, from: dictionaryData)]
            } catch let error as DecodingError {
                log(error: error, dictionary: dictionary)
                return []
            } catch let error {
                if logErrors { print(error) }
                return []
            }
        }
        
        func log(error: DecodingError, dictionary: [String: Any]) {
            guard logErrors else { return }
            log(dictionary: dictionary)
            switch error {
                case .dataCorrupted(let context):    log(context: context)
                case .keyNotFound(_, let context):   log(context: context)
                case .typeMismatch(_, let context):  log(context: context)
                case .valueNotFound(_, let context): log(context: context)
            }
        }
        
        func log(context: DecodingError.Context) {
            guard logErrors else { return }
            print(context.debugDescription)
        }
        
        private func log(dictionary: [String: Any]) {
            do {
                let data = try JSONSerialization.data(withJSONObject: dictionary)
                if let string = String(data: data, encoding: String.Encoding.utf8) {
                    print(string)
                }
            } catch {
                return
            }
        }
    }

    """
}
