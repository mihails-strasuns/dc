module dc.install;

import dc.utils.path : Path;
import std.experimental.logger;

/**
    Returns: true if installation was needed

    Params:
        root = will be set to path to be used as root of the toolchain directory
 */
bool installIfNeeded (ref Path root)
{
    import std.path : dirName;
    import std.file : thisExePath;

    Path binary_path = thisExePath();
    Path toolchain_dir = Path(dirName(dirName(binary_path)));

    bool installed = isInstalled(toolchain_dir);

    if (installed)
    {
        root = toolchain_dir;
        return false;
    }
    else
        root = Path(dirName(binary_path));

    import std.file : mkdirRecurse, copy;
    import dc.utils.path : subDirectories;
    import std.path : baseName;

    foreach (dir; subDirectories)
        mkdirRecurse(root ~ dir);

    auto new_path = root ~ "bin" ~ baseName(binary_path);
    copy(binary_path, new_path);

    version (Posix)
    {
        import std.file : remove;

        remove(binary_path);
    }
    else version (Windows)
    {
        // Windows does not allow binary to remove itself but it can ask OS
        // to remove it upon next reboot:

        import core.sys.windows.winbase;
        import std.string;

        MoveFileExA(toStringz(binary_path), null, MOVEFILE_DELAY_UNTIL_REBOOT);
    }

    version (Posix)
    {
        import std.file;
        import std.conv;

        setAttributes(new_path, octal!555);
    }

    addToPath(root ~ "bin");

    return true;
}

/**
    Returns: true if currently running binary is already placed into initialized
        directory structure
 */
private bool isInstalled (Path toolchain_dir)
{
    import std.file : exists;
    import dc.utils.path : subDirectories;

    foreach (dir; subDirectories)
    {
        if (!exists(toolchain_dir ~ dir))
            return false;
    }

    return true;
}

/**
    Adds toolchain bin folder to current user PATH env variable
 */
private void addToPath (Path bindir)
{
    import std.process;
    import std.algorithm.searching;

    auto current_path = environment["PATH"];
    trace("Current PATH is: ", current_path);
    if (current_path.canFind(bindir.toString()))
        return;

    version (Windows)
    {
        import core.sys.windows.winreg;
        import core.sys.windows.windef;
        import core.sys.windows.winnt;
        import std.exception;

        HKEY folder;
        auto result = RegOpenKeyEx(
            HKEY_CURRENT_USER,
            "Environment",
            0,
            KEY_QUERY_VALUE | KEY_SET_VALUE,
            &folder
        );
        enforce(result == ERROR_SUCCESS);

        auto value = new char[2048];
        uint value_length = cast(uint) value.length;
        result = RegQueryValueExA(
            folder,
            "Path",
            null,
            null,
            value.ptr,
            &value_length
        );
        enforce(result == ERROR_SUCCESS);
        value = (value[0 .. value_length - 1] ~ ";" ~ bindir ~ "\0");
        result = RegSetValueExA(
            folder,
            "Path",
            0,
            REG_SZ,
            cast(ubyte*) value.ptr,
            cast(uint) value.length
        );
        enforce(result == ERROR_SUCCESS);
        result = RegCloseKey(folder);
        enforce(result == ERROR_SUCCESS);
    }
    else version(Posix)
    {
        bool checkAndAdd (Path config)
        {
            import std.file : exists, append;
            import std.format;

            if (exists(config))
            {
                trace("Appending PATH adjustment to ", config);
                append(config, format("\nexport PATH=\"$PATH:%s\" # added by DC\n", bindir));
                return true;
            }
            else
                return false;
        }

        static immutable paths = [
            "~/.bash_aliases",
            "~/.bashrc",
            "~/.bash_profile",
            "~/.profile"
        ];

        foreach (path; paths)
        {
            if (checkAndAdd(Path(path)))
                break;
        }
    }
}
