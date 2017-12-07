DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )" 
cd "$DIR"

swift run ParserAutograph -project_name Sandbox -input Sources/Sandbox -output Sources/Sandbox -verbose
