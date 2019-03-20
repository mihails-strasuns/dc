/**
    Defining and parsing configuration
 */
module dc.config;

import dc.utils.path;
import simpleconfig.attributes;

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
    }
}

///
Config config;
