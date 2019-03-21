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
    import dc.utils.path : currentProcessBinary;
    import std.path : dirName;

    Path binary_path = currentProcessBinary();
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

    return true;
}

/**
    Returns: true if currently running binary is already placed into initialized
        directory structure
 */
bool isInstalled (Path toolchain_dir)
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
