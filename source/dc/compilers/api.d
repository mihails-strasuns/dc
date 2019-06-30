module dc.compilers.api;

import dc.utils.path : Path;

/**
    Compiler management abstraction. Specific implementation has to know
    about actual paths and configuration needed to make compiler placed
    into the sandbox to work.
 */
abstract class Compiler
{
    import dc.compilers.common;

    /// Downloads compiler and stored in the sandbox cache
    void fetch ();

    /// Enables compiler, downloads if necessary
    void enable ();

    /// Disables currently enabled compiler
    void disable ();

    /// Returns direct path to a portable distribution bin folder
    Path distributionBinPath ();

    /// Standard text representation of this compiler description
    string representation ()
    {
        return this.config.name ~ "-" ~ this.config.ver;
    }

    ///
    override equals_t opEquals (Object rhs)
    {
        if (auto rhs_ = cast(Compiler) rhs)
            return this.representation() == rhs_.representation();
        else
            return false;
    }

    ///
    this (Config config)
    {
        this.config = config;

        this.distribution = CompilerDistribution(
            this.representation()
        );
    }

    ///
    final void registerExistingFiles (Path[] files)
    {
        this.distribution.registerExistingFiles(files);
    }

    protected {
        struct Config
        {
            /// root of whole toolchain directory
            Path root;
            /// path to extracted compiler distribution directory
            Path source;
            /// path to downloaded compiler distribution archive
            Path archive;
            /// compiler name (dmd|ldc|gdc)
            string name;
            /// compiler version string, i.e. "2.080.0"
            string ver;
        }

        Config config;
        CompilerDistribution distribution;
    }
}
