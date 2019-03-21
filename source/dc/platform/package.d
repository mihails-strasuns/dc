module dc.platform;

public import dc.platform.api;

/**
    Initializes matching Platform implementation for the current platform
    while also checking all necessary prerequisistes. Will update thread-local
    `platform` variable in this module.
 */
public void initializePlatform ()
{
    import std.exception : enforce;

    version (Windows)
    {
        import std.format;
        import dc.platform.windows;

        enforce!DependencyCheckFailure(
            WindowsPlatform.powershell("$PSVersionTable.PSVersion").status == 0,
                "Couldn't spawn PowerShell sub-process"
        );

        platform = new WindowsPlatform;
    }
    else version (Posix)
    {
        import dc.platform.posix;

        void checkPresent(string binary)
        {
            import std.process;

            enforce!DependencyCheckFailure(
                execute([ "which", binary ]).status == 0,
                binary ~ " is either not installed or not on PATH"
            );
        }

        checkPresent("wget");
        checkPresent("ln");
        checkPresent("tar");

        platform = new PosixPlatform;
    }
    else
        static assert (false);

    assert (platform !is null);
}

/// Must be only used after `initializePlatform` has been called
public Platform platform;
