/**
    Asbtractions around self-contained directory sandbox for D compilers
    and libraries to be managed by this tool.
 */
module dc.sandbox;

import dc.utils.path;
import dc.utils.reporting;
import dc.compilers.base;
import dc.paths;

/**
    Ensures the presence of a required directory structure for
    the D toolchain sandbox

    Params:
        path = where to put all D toolchain
 */
const(Paths) initRoot(string path)
{
    Paths ret;

    ret.root = Path(path);
    ret.bin = ret.root ~ "bin";
    ret.lib = ret.root ~ "lib";
    ret.imports = ret.root ~ "imports";
    ret.versions = ret.root ~ "versions";

    import std.file : mkdirRecurse, exists;

    if (exists(path))
        return ret;

    mixin(report!("Creating D sandbox at '%s'", path));
    
    foreach (dir; ret.tupleof)
        mkdirRecurse(dir);

    return ret;
}

/**
    Creates a new compiler management object based on a
    description string and sandbox paths instance.

    Params:
        paths = sandbox paths
        description = string of form "compiler-version"
 */
Compiler compiler (Paths paths, string description)
{
    import std.format : formattedRead;
    import dc.compilers.dmd;

    string name;
    string ver;
    description.formattedRead!"%s-%s"(name, ver);

    switch (name)
    {
        case "dmd":
            return new DMD(paths, ver);
        default:
            assert(false);
    }
}