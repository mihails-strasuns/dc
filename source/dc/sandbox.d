/**
    Abstractions around self-contained directory sandbox for D compilers
    and libraries to be managed by this tool.
 */
module dc.sandbox;

import dc.utils.path;
import dc.utils.reporting;
import dc.compilers.base;
import dc.platform.api;
import dc.config;

/**
    Ensures the presence of a required directory structure for
    the D toolchain sandbox

    Params:
        paths = part of configuration describing sandbox path layout
 */
void initSandbox(Config.Paths paths)
{
    import std.file : mkdirRecurse, exists;

    auto root = paths.root;

    if (exists(root))
        return;

    mixin(report!("Creating D sandbox at '%s'", root));

    foreach (dir; paths.tupleof)
        mkdirRecurse(dir);
}

/**
    Creates a new compiler management object based on a
    description string and sandbox paths instance.

    Params:
        config = app config
        platform = abstraction over platform utils
        description = string of form "compiler-version"
 */
Compiler compiler (Config config, Platform platform, string description)
{
    import std.format : formattedRead;
    import dc.compilers.dmd;

    string name;
    string ver;
    description.formattedRead!"%s-%s"(name, ver);

    switch (name)
    {
        case "dmd":
            return new DMD(config, platform, ver);
        default:
            assert(false);
    }
}
