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
