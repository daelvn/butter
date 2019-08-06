# Butter
Butter is a preprocessor for shell files, which lets you declare functions much more easily, with the use of namespaces and indent-based syntax.
## Example
```sh
# example.butter
# This is a normal comment!
[some-prefix]
func:
  echo @1

[:]
main:
  func "Hello, Butter!"
```
When you run `butter -i example.butter --dry` for this file, you get:
```
# example.butter
# This is a normal comment!
some_prefix_func () {
  echo "$1"
}

main () {
  func "Hello, Butter!"
}
```

## Install
You can install this utility via LuaRocks:
```
$ luarocks install butter
```

## Usage
```
Options:
  -v               Be verbose
  -I               Include butter helper functions in script
  -o <string>      Output file
  -i <string>      Input file
  --dry            Print the output instead of writing it
  +i ...           Source files
  --verbose-print  Enable verbose butter logging
  --no-print       Disable all butter logging
```

## Features
### Pretty function calling
`px#fld` turns into `px_fld`
### Indent-based function declaration
```sh
example-func:
  do stuff
```
### Namespaces
```sh
[example]
func:
  do stuff
```
### Shortcuts
`@n` turns into `"$n"`
### Logging
You can log messages with any comment following this rule: `#@v?[iewk]`.  
The `v` stands for verbose and it will only print if `--verbose-print` is activated.  
`i` is for info (white), `e` is for error (red), `w` is for warning (yellow), `k` is for OK (green).  
You can disable all printing with `--no-print`.
### Sourcing files
You can source several other files with `+i`. They will be included in the first line or wherever `#@source` is.
### Stop processing
You can stop processing with the `#@@` tag.
### Local variables
You can now declare and use local variables by prefixing them with `*`
```sh
[fs]
*dist="dir/"
echo "$*dist"
```

## License
This project is released to the public domain.

## Maintainer
This project is maintained by [daelvn](https://github.com/daelvn)
