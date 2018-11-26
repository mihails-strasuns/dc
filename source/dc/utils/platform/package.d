/**
    Common API behind platform-specific functionality
 */
module dc.utils.platform;

version (Windows)
    import platform = dc.utils.platform.windows;
else version (Posix)
    import platform = dc.utils.platform.posix;
else
    static assert (false);

/**
    Platform-specific prerequisite checks
 */
void checkRequirements ()
{
    platform.checkRequirements();
}

/**
    Downloads a remote file using platform-specific method.

    Params:
        url = remote URL to download from
        path = local fully-qualified destination path
 */
void download (string url, string path)
{
    import dc.utils.reporting;
    import std.exception : enforce;

    mixin (report!("Downloading %s", url));
    auto status = platform.download(url, path);        
    enforce(status == 0, "Download failure");
}

/**
    Creates a symbolic link using platform-specific method

    Params:
        lnk = absolute path to link file to create
        src = absolute path to source file to link
 */
void link (string lnk, string src)
{
    import std.exception : enforce;
    import std.path : isAbsolute;

    enforce(isAbsolute(lnk));
    enforce(isAbsolute(src));
    platform.link(lnk, src);
}

/**
    Extracts an archive using platform-specific method

    Params:
        archive = path to archive
        src = path to directory to extract archive to
 */
void extract (string archive, string dst)
{
    import dc.utils.reporting;

    mixin(report!("Extracting %s", archive));
    platform.extract(archive, dst);
}