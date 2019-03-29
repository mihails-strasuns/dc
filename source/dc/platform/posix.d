module dc.platform.posix;

version(Posix):

import dc.platform.api;
import dc.utils.trace;

class PosixPlatform : Platform
{
    static ProcessResult run (string[] cmd)
    {
        import std.process;

        auto proc = pipeProcess(cmd, Redirect.stdout | Redirect.stderr);
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

    /// See `dc.platform.api.Platform`
    void download (string url, string path)
    {
        mixin(traceCall());

        import std.format;
        import std.exception;

        auto result = run([ "curl", "-o", path, "-LSs", url ]);
        if (result.status != 0)
            throw new DownloadFailure(url, result.stderr);
    }

    /// See `dc.platform.api.Platform`
    void enable (string src, string dst)
    {
        mixin(traceCall());

        import std.file : mkdirRecurse;
        import std.path : dirName;
        import std.process;

        mkdirRecurse(dirName(dst));
        auto result = execute([ "cp", "-r", src, dst ]);
        if (result.status != 0)
            throw new FileFailure(dst, result.output);
    }

    /// See `dc.platform.api.Platform`
    void disable (string dst)
    {
        mixin(traceCall());

        import std.process;
        auto result = execute([ "rm", "-rf", dst ]);
        if (result.status != 0)
            throw new FileFailure(dst, result.output);
    }

    /// See `dc.platform.api.Platform`
    void extract (string archive, string dst)
    {
        mixin(traceCall());

        import std.string : endsWith;
        import std.process : execute;
        import std.file : mkdirRecurse;

        mkdirRecurse(dst);

        auto result = run([ "tar",
            "-xf", archive,
            "-C", dst,
        ]);

        if (result.status != 0)
            throw new ExtractionFailure(archive, dst, result.stderr);
    }
}
