module dc.compilers;

public import dc.compilers.base;

/**
    Creates a new compiler management object based on a
    description string and sandbox paths instance.

    Params:
        description = string of form "compiler-version"
 */
Compiler compiler (string description)
{
    import std.format : formattedRead;
    import dc.compilers.dmd;
    import dc.config;

    string name;
    string ver;
    description.formattedRead!"%s-%s"(name, ver);

    switch (name)
    {
        case "dmd":
            return new DMD(ver);
        default:
            assert(false);
    }
}