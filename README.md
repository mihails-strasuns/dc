## DC

[![Build Status](https://dev.azure.com/mihails-strasuns/github/_apis/build/status/mihails-strasuns.dc?branchName=master)](https://dev.azure.com/mihails-strasuns/github/_build/latest?definitionId=2?branchName=master)

Tool to help managing D compiler toolchain in uniform manner between Linux and Windows. Defines
a folder where all tools and libraries can be stored and easily used as long as compiler is on PATH.

Most useful when doing cross-platform development with a lot of switching between compiler versions.

## Usage

- Download latest release for your platform from https://github.com/mihails-strasuns/dc/releases
- Create a folder where all toolchain will be stored (`$D-DIR`) and put downloaded binary inside it
- Run the binary once with no argument to create the initial directory
  structure. It will try adding itself `$PATH` for the current user as appropriate for your platform.
  Note that this will only have effect on the next login.
- Run command to download and enable first toolchain. For example, `dc use dmd-2.083.2`.

## Temporary limitations

This is early version and has plenty of limitations that should be eventually lifted:

- No support for switching toolchain within single shell context (like
  `activate` from `install.sh`). It doesn't fit well with DC approach of reusing
  single `bin` folder for all versions - some design idea is needed to move
  forward with it.
- No shared library support. It is not yet clear how to make it work while
  keeping resulting binaries portable. Adding naive support would be trivial
  but misleading thus left out until there is any demand.

## Intentional limitations

There are few intentional choices that are likely to remain:

- No support for older compiler versions
- No support for OPTLINK on Windows
