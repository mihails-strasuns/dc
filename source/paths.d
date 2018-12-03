module dc.paths;

import dc.utils.path;

/// Where key bits of D compiler/libraries are stored
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