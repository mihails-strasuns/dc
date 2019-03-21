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
Compiler compiler (string description, Path root)
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
