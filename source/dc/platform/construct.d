module dc.platform.construct;

import dc.platform.api;
import dc.platform.windows;
import dc.platform.posix;
import dc.config;

/**
    Constructs matching Platform implementation for the current platform
    while also checking all necessary prerequisistes.
 */
public Platform initializePlatform (Config config)
{
    import std.exception : enforce;

    version (Windows)
    {
        import std.format;

        enforce(
            WindowsPlatform.powershell("$PSVersionTable.PSVersion").status == 0,
                "Couldn't spawn PowerShell sub-process"
        );

        enforce(
            WindowsPlatform.powershell(format(`& "%s" -h`, config.path7z)).status == 0,
            "Path to 7z.exe or 7za.exe must be specified via configuration file or CLI argument"
        );

        return new WindowsPlatform(config.path7z);
    }
    else version (Posix)
    {
        void checkPresent(string binary)
        {
            import std.process;

            enforce(
                execute([ "which", binary ]).status == 0,
                binary ~ " is either not installed or not on PATH"
            );
        }

        checkPresent("curl");
        checkPresent("ln");
        checkPresent("tar");

        return new PosixPlatform;
    }
    else
        static assert (false);
}