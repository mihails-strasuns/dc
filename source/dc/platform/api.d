/**
    Defines methods that need to be implemented for any supported platform for
    rest of the tool to work.
 */
module dc.platform.api;

import dc.exception;

public interface Platform
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

///
public class DownloadFailure : DcException
{
    this (string url, string msg, string file = __FILE__, size_t line = __LINE__)
    {
        import std.format;

        auto details = msg;
        msg = format("Download failure [%s]", url);
        super(msg, details, file, line);
    }
}

///
public class FileFailure : DcException
{
    this (string path, string msg, string file = __FILE__, size_t line = __LINE__)
    {
        import std.format;

        auto details = msg;
        msg = format("Failure when working with path [%s]", path);
        super(msg, details, file, line);
    }
}

///
public class ExtractionFailure : DcException
{
    this (string from, string to, string msg, string file = __FILE__, size_t line = __LINE__)
    {
        import std.format;

        auto details = msg;
        msg = format("Failure when extracting [%s] to [%s]", from, to);
        super(msg, details, file, line);
    }
}

///
public class DependencyCheckFailure : DcException
{
    this (string msg, string file = __FILE__, size_t line = __LINE__)
    {
        super(msg, "", file, line);
    }
}

/**
    Eager replacement of result struct from std.process

    Provides all stdout/stderr output already collected.
*/
package(dc.platform) struct ProcessResult
{
    /// return status
    int status;
    /// combined stdout
    string stdout;
    /// combined stderr
    string stderr;
}