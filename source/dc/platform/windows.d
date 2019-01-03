module dc.platform.windows;

version(Windows):

import dc.platform.api;

class WindowsPlatform : Platform
{
    /**
        Eager replacement of result struct from std.process

        Provides all stdout/stderr output already collected.
    */
    static struct ProcessResult
    {
        /// return status
        int status;
        /// lines of stdout
        string[] stdout;
        /// lines of stderr
        string[] stderr;
    }

    /**
        Finds powershell executable and tries to run provided
        commands inside it.

        Params:
            commands = list of commands to run, all will share the
                same execution context (and thus can share variables)

        Returns:
            execution result
    */
    static ProcessResult powershell (string[] commands...)
    {
        import std.algorithm : map;
        import std.range : join;

        auto command_s = commands.join("; ");

        import std.process;
        import std.exception : enforce;

        auto proc = pipeProcess(
            [ environment["SYSTEMROOT"] ~ "\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "-NonInteractive", "-Command" ] ~ command_s,
            Redirect.stdout | Redirect.stderr
        );

        auto status = wait(proc.pid);

        import std.array;
        import std.ascii : newline;
        import std.stdio : KeepTerminator;

        return ProcessResult(
            status,
            proc.stdout.byLineCopy(KeepTerminator.no, newline).array(),
            proc.stderr.byLineCopy(KeepTerminator.no, newline).array()
        );
    }

    private {
        string binary7z;
    }

    /**
        Constructor

        Params:
            binary7z = 7z.exe or 7za.exe, as deduced by environment check
    */
    this (string binary7z)
    {
        assert(binary7z.length > 0);
        this.binary7z = binary7z;
    }

    /// See `dc.platform.api.Platform`
    void download (string url, string path)
    {
        import std.format;
        import std.exception;

        enforce(powershell(format(`wget -O "%s" "%s"`, path, url)).status == 0);
    }

    /// See `dc.platform.api.Platform`
    void enable (string src, string dst)
    {
        import std.format;
        import std.exception;

        auto cmd = format(
            `cp -r "%s" "%s"`,
            src,
            dst,
        );

        enforce(powershell(cmd).status == 0);
    }

    /// See `dc.platform.api.Platform`
    void disable (string dst)
    {
        import std.format;

        auto cmd = format(`Remove-Item -Recurse -Force "%s"`, dst);
        powershell(cmd);
    }

    /// See `dc.platform.api.Platform`
    void extract (string archive, string dst)
    {
        import std.exception : enforce;
        import std.string : endsWith;
        import std.format;

        enforce(archive.endsWith(".7z"));

        auto status = powershell(
            format(`& "%s" x -o"%s" "%s"`, this.binary7z, dst, archive)).status;

        enforce(status == 0, "Extracting has failed");
    }
}