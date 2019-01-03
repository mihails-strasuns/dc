module dc.compilers.base;

import dc.config;
import dc.platform.api;

/**
    Compiler management abstraction. Specific implementation has to know
    about actual paths and configuration needed to make compiler placed
    into the sandbox to work.
 */
abstract class Compiler
{
    protected {
        Config config;
        Platform platform;
        string ver;
    }

    this (Config config, Platform platform, string ver)
    {
        this.config = config;
        this.platform = platform;
        this.ver = ver;
    }

    /// Downloads compiler and stored in the sandbox cache
    abstract void fetch ();

    /// Disables currently enabled compiler
    abstract void disable ();

    /// Enables compiler, downloads if necessary
    abstract void enable ();
}