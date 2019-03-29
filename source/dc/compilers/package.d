module dc.compilers;

public import dc.compilers.api;
import dc.utils.path : Path;

/**
    Creates a new compiler management object based on a
    description string and sandbox paths instance.

    Params:
        description = string of form "compiler-version"

    Returns:
        instance capable of manipulating compiler distribution
 */
Compiler compilerFromDescription (string description, Path root)
{
    import std.format : formattedRead;
    import dc.compilers.dmd;
    import dc.compilers.ldc;
    import dc.exception;

    string name;
    string ver;
    description.formattedRead!"%s-%s"(name, ver);

    switch (name)
    {
        case "dmd":
            return new DMD(ver, root);
        case "ldc":
            return new LDC(ver, root);
        default:
            throw new DcException("Unsupported compiler", "");
    }
}

/**
    Creates a new compiler management object based on a
    'USED' anchor file present in existing installation.

    Params:
        anchor = path to 'USED' file

    Returns:
        instance capable of manipulating compiler distribution
 */
Compiler compilerFromAnchor (Path anchor, Path root)
{
    import std.stdio : File;
    import std.algorithm : map;
    import std.string : strip;
    import std.array;

    auto lines = File(anchor).byLineCopy.array();
    auto description = lines[0];

    auto compiler = compilerFromDescription(description, root);
    compiler.registerExistingFiles(
        lines[1 .. $].map!(line => Path(strip(line))).array());
    return compiler;
}
