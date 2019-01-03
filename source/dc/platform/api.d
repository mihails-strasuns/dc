/**
    Defines methods that need to be implemented for any supported platform for
    rest of the tool to work.
 */
module dc.platform.api;

interface Platform
{
    /**
        Downloads a remote file using platform-specific method.

        Params:
            url  = remote URL to download from
            path = local fully-qualified destination path
    */
    void download (string url, string path);

    /**
        Either copies files recursively or creates a symbolic link, depending
        on the platform.

        Params:
            src = absolute source path to link/copy
            dst = absolute destination path to link/copy
    */
    void enable (string src, string dst);

    /**
        Deletes a symbolic link/folder, depending on the platform.

        Params:
            dst = absolute path to unlink/delete
    */
    void disable (string dst);
    
    /**
        Extracts an archive using a platform-specific method

        Params:
            archive = path to archive
            src = path to directory to extract archive to
    */
    void extract (string archive, string dst);
}