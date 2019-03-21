module dc.utils.path;

/**
    Simple utility to augment paths while keeping them normalized.

    Implicitly convertiable back to plain path string.
 */
struct Path
{
    import std.path : absolutePath, expandTilde, buildNormalizedPath,
           isValidPath;
    import std.exception : enforce;

    private string normalized;

    /// Creates Path from string by normalizing it and turning into the absolute one
    this (string rhs)
    {
        this.normalized = absolutePath(expandTilde(rhs));
        enforce(isValidPath(this.normalized));
    }

    /// Quick way to append to existing path, ensures there is exactly
    /// one path separator between entries.
    Path opBinary (string op) (string rhs)
        if (op == "~")
    {
        Path path;
        path.normalized = buildNormalizedPath(this.normalized, rhs);
        return path;
    }

    /// Conversion back to string, also enabled implicitly via `alias this`
    inout(string) toString () inout
    {
        return this.normalized;
    }

    alias toString this;
}

/// Returns: fully-qualified filesystem path to the currently running executable
Path currentProcessBinary ()
{
    import std.process : thisProcessID;

    version (Windows)
    {
        import core.sys.windows.winbase : GetModuleFileNameA;

        char[1024] buffer;
        auto ln = GetModuleFileNameA(null, buffer.ptr, buffer.length);
        return Path(buffer[0 .. ln].idup);
    }
    else version (Posix)
    {
        import std.file : readLink;
        import std.format;
        return Path(readLink(format("/proc/%s/exe", thisProcessID())));
    }
}

/// Sub-directories to create inside toolchain directory
static immutable subDirectories = [
    "bin",
    "lib",
    "versions",
    "imports"
];

struct SubDirectories
{
    Path bin;
    Path lib;
    Path versions;
    Path imports;

    this (Path root)
    {
        foreach (i, ref field; this.tupleof)
            field = root ~ subDirectories[i];
    }
}
