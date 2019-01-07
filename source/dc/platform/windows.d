module dc.platform.windows;

version(Windows):

import dc.platform.api;

class WindowsPlatform : Platform
{
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

        auto proc = pipeProcess(
            [ environment["SYSTEMROOT"] ~ "\\System32\\WindowsPowerShell\\v1.0\\powershell.exe",
                "-NonInteractive", "-Command" ] ~ command_s,
            Redirect.stdout | Redirect.stderr
        );

        auto status = wait(proc.pid);

        import std.ascii : newline;
        import std.stdio : KeepTerminator;
        import std.range : join;

        return ProcessResult(
            status,
            proc.stdout.byLine(KeepTerminator.no, newline).join("\n").idup,
            proc.stderr.byLine(KeepTerminator.no, newline).join("\n").idup
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

        auto result = powershell(format(`wget -O "%s" "%s"`, path, url));
        if (result.status != 0)
            throw new DownloadFailure(url, result.stderr);
    }

    /// See `dc.platform.api.Platform`
    void enable (string src, string dst)
    {
        import std.format;
        import std.exception;

        auto result = powershell(format(`cp -r "%s" "%s"`, src, dst));
        if (result.status != 0)
            throw new FileFailure(dst, result.stderr);
    }

    /// See `dc.platform.api.Platform`
    void disable (string dst)
    {
        import std.format;

        powershell(format(`Remove-Item -Recurse -Force "%s"`, dst));
    }

    /// See `dc.platform.api.Platform`
    void extract (string archive, string dst)
    {
        import std.exception : enforce;
        import std.string : endsWith;
        import std.format;

        auto result = powershell(format(`& "%s" x -o"%s" "%s"`, this.binary7z, dst, archive));
        if (result.status != 0)
            throw new ExtractionFailure(archive, dst, result.stderr);
    }
}