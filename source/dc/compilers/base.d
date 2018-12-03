module dc.compilers.base;

import dc.paths;

/**
    Compiler management abstraction. Specific implementation has to know
    about actual paths and configuration needed to make compiler placed
    into the sandbox to work.
 */
abstract class Compiler
{
    protected Paths paths;
    protected string ver;

    this(Paths paths, string ver)
    {
        this.paths = paths;
        this.ver = ver;
    }

    /// Downloads compiler and stored in the sandbox cache
    abstract void fetch ();

    /// Disables currently enabled compiler
    abstract void disable ();

    /// Enables compiler, downloads if necessary
    abstract void enable ();
}