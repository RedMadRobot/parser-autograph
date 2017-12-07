# Parser Autograph

Object parser generation utility based on [Autograph](https://github.com/RedMadRobot/autograph) and [Synopsis](https://github.com/RedMadRobot/synopsis) frameworks.

# Usage
## Prepare your sources

Mark your model classes and structures like this:

```swift
/**
 EVERYTHING Codable OR Decodable IS CONSIDERED A MODEL
 */
struct Person: Decodable {
    /**
     PROVIDE JSON KEYS FOR EACH PROPERTY:
     @json first_name
     */
    let firstName: String
    
    /**
     USE OPTIONAL PROPERTY TYPES FOR OPTIONAL FIELDS e.g. String?
     USE NON-OPTIONAL TYPES FOR MANDATORY FIELDS     e.g. String
     @json last_name
     */
    let lastName: String?
    
    /**
     FEEL FREE TO USE OTHER ANNOTATED MODELS AS SUB-OBJECTS e.g. Passport
     PROPERTY NAMES ARE USED AS IMPLICIT JSON KEYS:
     @json
     */
    let passport: Passport?
}
```

**Parser Autograph** will generate a generic `object parser` utility class for you, and also `Decodable` extensions for each of your models.

`Object parser` utility works as you would expect:

```swift
let parser: ObjectParser<Person> = ObjectParser()
parser.logErrors = true // error logging is disabled by default

let data = """
{ 
    "data": [
        { "first_name": "Jack", "last_name": "Daniel" }, 
        { "first_name": "Jim Beam" }
    ]
}
""".data(using: String.Encoding.utf8)!

let result: [Person] = parser.parse(data: data) // see also parse(any:), parse(dictionary:) and parse(array:)

print(result.count) // two guys here
```

## Build executable

Run `spm_build.command` script in order to build from sources.

You'll find your `ParserAutograph` executable in `./build/x86_64-apple-macosx10.10/release` folder or similar, depending on your OS.

## Add run script build phase to your project

Run `ParserAutograph` executable before other build phases, so that new generated source code would be taken into the process.
The utility accepts next arguments:

* `-help` — print help, do not execute;
* `-verbose` — print additional debug information;
* `-input [folder]` — path to the folder with your model classes and structures;
* `-output [folder]` — path to the folder, where to put generated `ObjectParser.swift` file.

Your script may look like this:

```bash
PARSER_AUTOGRAPH_PATH=Utilities/ParserAutograph

if [ -f $PARSER_AUTOGRAPH_PATH ]
then
    echo "ParserAutograph executable found"
else
    osascript -e 'tell app "Xcode" to display dialog "Object parser generator executable not found in \nUtilities/ParserAutograph" buttons {"OK"} with icon caution'
fi

$PARSER_AUTOGRAPH_PATH \
    -input "$PROJECT_NAME/Classes/Model" \
    -output "./$PROJECT_NAME/Generated/Classes"
```

## Demo & running tests

Use `spm_resolve.command` to load all dependencies and `spm_generate_xcodeproj.command` to assemble an Xcode project file.
Also, ensure Xcode targets macOS.

Run `spm_run_sandbox.command` script for a demo — it builds and launches **Parser Autograph** with `Sources/Sandbox` as a working directory.
