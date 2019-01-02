/**
    Defining and parsing configuration
 */
module dc.config;

import dc.utils.path;
import simpleconfig;

/// Stores all configuration used by the rest of the app
struct Config
{
    @cfg
    string root_path = "D";

    struct Paths
    {
        /// Sandbox root
        Path root;
        /// Executables (compiler, dub)
        Path bin;
        /// Static libraries
        Path lib;
        /// Root -I path
        Path imports;
        /// Storage for downloaded compiler packages
        Path versions;
    }

    /// Where key bits of D compiler/libraries are stored, deduced
    /// automatically from `this.sandbox`
    Paths paths;

    version(Windows)
    {
        /// Path to 7z.exe or 7za.exe
        Path path7z;;
    }

    void finalizeConfig ()
    {
        with (this.paths)
        {
            root = Path(this.root_path);
            bin = root ~ "bin";
            lib = root ~ "lib";
            versions = root ~ "versions";
            imports = root ~ "imports";
        }

        version (Windows)
        {
            if (this.path7z.length == 0)
                this.path7z = Path(".\\7z");

            // Add 7z.exe location to PATH for the current process so that it can be called
            // from shell scripts without having to access app config.
            import std.process;
            environment["path"] = environment["path"] ~ ";" ~ this.path7z ~ ";";
        }
    }
}

///
Config readConfig ()
{
    Config config;
    readConfiguration(config);
    return config;
}
