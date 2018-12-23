module dc.utils.platform.posix;

version(Posix):

/**
    Downloads remote file using curl

    Params:
        url = remote URL to download from
        path = local fully-qualified destination path
 */
int download (string url, string path)
{
    import std.process;
    return execute([ "curl", "-o", path, "-LSs", url ]).status;
}

/**
    Creates a symlink using `ln`

    Params:
        src = absolute path to source file to link
        lnk = absolute path to link file to create
 */
int link (string src, string lnk)
{
    import std.file : symlink, FileException;
    import std.exception;
    try
    {
        symlink(src, lnk);
        return 0;
    }
    catch (FileException)
        return 1;
}

/**
    Deletes symlink as a regular file

    Params:
        lnk = absolute path to link file to delete
 */
void unlink (string lnk)
{
    import std.file;
    try
        remove(lnk);
    catch (FileException) { }
}

/**
    Extracts an archive using `tar`

    Params:
        archive = absolute path to link file to create
        dst = absolute path to directory to extract to
 */
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

/**
    Makes sure all required tools are available
 */
void checkRequirements ()
{
    import std.exception : enforce;
    import std.process;

    void checkPresent(string binary)
    {
        enforce(
            execute([ "which", binary ]).status == 0,
            binary ~ " is either not installed or not on PATH"
        );
    }

    checkPresent("curl");
    checkPresent("ln");
    checkPresent("tar");
}
