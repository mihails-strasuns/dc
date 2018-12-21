/**
    Defining and parsing configuration
 */
module dc.config;

import dc.utils.path;

/// Stores all configuration used by the rest of the app
struct Config
{
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
        /// Path to 7z.exe
        Path path7z;
    }
}
