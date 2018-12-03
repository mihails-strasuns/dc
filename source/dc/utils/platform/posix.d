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
    return execute([ "curl", "-o", path, "-Ss", url ]).status;
}

/**
    Creates a symlink using `ln`

    Params:
        lnk = absolute path to link file to create
        src = absolute path to source file to link
 */
void link (string lnk, string src)
{
    import std.file : symlink;
    symlink(lnk, src);
}

/**
    Extracts an archive using `tar`

    Params:
        archive = absolute path to link file to create
        src = absolute path to source file to link
 */
void extract (string archive, string dst)
{
    import std.exception : enforce;
    import std.string : endsWith;
    import std.process : execute;
    
    enforce(archive.endsWith(".tar.xz"));

    execute([ "tar",
        "-xf", archive,
        "-C", dst,
        "--one-top-level"
    ]);
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