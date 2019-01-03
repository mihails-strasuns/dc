module dc.platform.construct;

import dc.platform.api;
import dc.platform.windows;
import dc.platform.posix;

/**
    Constructs matching Platform implementation for the current platform
    while also checking all necessary prerequisistes.
 */
public Platform initializePlatform ()
{
    import std.exception : enforce;

    version (Windows)
    {      
        enforce(
            WindowsPlatform.powershell("$PSVersionTable.PSVersion").status == 0,
                "Couldn't spawn PowerShell sub-process"
        );

        string binary7z;

        if (WindowsPlatform.powershell("7za.exe -h").status == 0)
            binary7z = "7za.exe";
        else if (WindowsPlatform.powershell("7z.exe -h").status == 0)
            binary7z = "7z.exe";
        else
            throw new Exception ("Either 7z.exe or 7za.exe must be on PATH (you can specify one via config file)");

        return new WindowsPlatform(binary7z);
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