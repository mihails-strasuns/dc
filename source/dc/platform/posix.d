module dc.platform.posix;

version(Posix):

import dc.platform.api;

class PosixPlatform : Platfrom
{
    /// See `dc.platform.api.Platform`
    int download (string url, string path)
    {
        import std.process;
        return execute([ "curl", "-o", path, "-LSs", url ]).status;
    }

    /// See `dc.platform.api.Platform`
    int enable (string src, string dst)
    {
        import std.file : symlink, FileException;
        import std.exception;
        try
        {
            symlink(src, dst);
            return 0;
        }
        catch (FileException)
            return 1;
    }

    /// See `dc.platform.api.Platform`
    void disable (string dst)
    {
        import std.file;
        try
            remove(dst);
        catch (FileException) { }
    }

    /// See `dc.platform.api.Platform`
    void extract (string archive, string dst)
    {
        import std.exception : enforce;
        import std.string : endsWith;
        import std.process : execute;
        import std.file : mkdirRecurse;

        mkdirRecurse(dst);

        enforce(archive.endsWith(".tar.xz"));

        auto status = execute([ "tar",
            "-xf", archive,
            "-C", dst,
        ]).status;

        enforce(status == 0, "Extracting has failed");
    }
}