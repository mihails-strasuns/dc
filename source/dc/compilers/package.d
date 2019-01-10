module dc.compilers;

public import dc.compilers.api;

/**
    Creates a new compiler management object based on a
    description string and sandbox paths instance.

    Params:
        description = string of form "compiler-version"

    Returns:
        instance capable of manipulating compiler distribution
 */
Compiler compiler (string description)
{
    import std.format : formattedRead;
    import dc.compilers.dmd;
    import dc.compilers.ldc;
    import dc.config;
    import dc.exception;

    string name;
    string ver;
    description.formattedRead!"%s-%s"(name, ver);

    switch (name)
    {
        case "dmd":
            return new DMD(ver);
        case "ldc":
            return new LDC(ver);
        default:
            throw new DcException("Unsupported compiler", "");
    }
}