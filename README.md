## DC

[![Build Status](https://dev.azure.com/mihails-strasuns/github/_apis/build/status/mihails-strasuns.dc?branchName=master)](https://dev.azure.com/mihails-strasuns/github/_build/latest?definitionId=2?branchName=master)

Tool to help managing D compiler toolchain in uniform manner between Linux and Windows. Defines
a folder where all tools and libraries can be stored and easily used as long as compiler is on PATH.

Most useful when doing cross-platform development with a lot of switching between compiler versions.

## Usage

- Download latest release for your platform from https://github.com/mihails-strasuns/dc/releases
- Create a folder where all toolchain will be stored (`$D-DIR`) and create `bin` folder inside it
- Move DC binary to `$D-DIR/bin` and create the configuration file in the same directory
- Add `$D-DIR/bin` to `$PATH` as appropriate for your platform
- Run command to download and enable first toolchain. For example, `dc use dmd-2.083.2`.

## Configuration file

Must be named `dc.cfg` and should look like this:

```
root_path = "Full path to $D-DIR"
path_to_7z = "On Windows, full path to 7z.exe or 7za.exe"
```

## Temporary limitations

This is early version and has plenty of limitations that should be eventually lifted:

- Dependency on external 7-zip installation on Windows. Should be included as a library.
- No support for switching toolchain within single shell context (like `activate` from `install.sh`)
- No shared library support. It is not yet clear how to make it work while keeping resulting binaries portable.

## Intentional limitations

There are few intentional choices that are likely to remain:

- No support for older compiler versions
- No support for OPTLINK on Windows
