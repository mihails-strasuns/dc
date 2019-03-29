module dc.platform.windows;

version(Windows):

import dc.platform.api;
import dc.utils.trace;
import std.experimental.logger;

// from lib7z/extracttor.lib
extern(C) int extract(const char* archive, const char* dest);

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
        trace("[powershell] ", command_s);

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

        auto result = ProcessResult(
            status,
            proc.stdout.byLine(KeepTerminator.no, newline).join("\n").idup,
            proc.stderr.byLine(KeepTerminator.no, newline).join("\n").idup
        );

        if (result.stdout.length)
            trace(result.stdout);
        if (result.stderr.length)
            trace(result.stderr);

        return result;
    }

    /**
        Constructor
    */
    this ()
    {
    }

    /// See `dc.platform.api.Platform`
    void download (string url, string path)
    {
        mixin(traceCall());

        import std.format;
        import std.exception;

        auto result = powershell(
            "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12",
            format(`wget -O "%s" "%s"`, path, url)
        );
        if (result.status != 0)
            throw new DownloadFailure(url, result.stderr);
    }

    /// See `dc.platform.api.Platform`
    void enable (string src, string dst)
    {
        mixin(traceCall());

        import std.format;
        import std.file : mkdirRecurse;
        import std.path : dirName;

        mkdirRecurse(dirName(dst));
        auto result = powershell(format(`cp -r "%s" "%s"`, src, dst));
        if (result.status != 0)
            throw new FileFailure(dst, result.stderr);
    }

    /// See `dc.platform.api.Platform`
    void disable (string dst)
    {
        mixin(traceCall());

        import std.format;

        powershell(format(`Remove-Item -Recurse -Force "%s"`, dst));
    }

    /// See `dc.platform.api.Platform`
    void extract (string archive, string dst)
    {
        mixin(traceCall());

        import std.path : absolutePath;
        import std.string : toStringz;

        auto result = .extract(toStringz(archive), toStringz(absolutePath(dst)));
        if (result != 0)
            throw new ExtractionFailure(archive, dst, "Extraction failure");
    }
}
