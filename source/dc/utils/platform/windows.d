module dc.utils.platform.windows;

version(Windows):

/**
    Eager replacement of result struct from std.process

    Provides all stdout/stderr output already collected.
 */
struct ProcessResult
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
ProcessResult powershell (string[] commands...)
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

/**
    Creates symlink on Windows using `mklink` command built into cmd.exe

    Params:
        lnk = absolute path to link file to create
        src = absolute path to source file to link
 */
void link (string lnk, string src)
{
    powershell("cmd", "/c", "mklink", lnk, src);
}

/**
    Downloads remote file using powershell built-in

    Params:
        url = remote URL to download from
        path = local fully-qualified destination path
 */
int download (string url, string path)
{
    import std.format;
    return powershell(format("wget -O %s %s", path, url)).status;
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
    
    enforce(archive.endsWith(".7z"));

    // TODO:
    assert(false);
}

/**
    Makes sure all required tools are available and admin access present
 */
void checkRequirements ()
{
    import std.exception : enforce;    
    
    enforce(
        powershell("$PSVersionTable.PSVersion").status == 0,
        "Couldn't spawn PowerShell sub-process"
    );
    
    enforce(
        powershell(
            "$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())",
            "$currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
        ).stdout == [ "True" ],
        "Must run this program as administrator (for mklink to work)"
    );
}