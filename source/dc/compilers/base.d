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
    protected string ver;

    this (string ver)
    {
        this.ver = ver;
    }

    ///
    override equals_t opEquals (Object obj)
    {
        if (Compiler rhs = cast(Compiler) obj)
            return this.representation() == rhs.representation();
        else
            return false;
    }

    /// Standard text representation of this compiler description
    string representation ()
    {
        return this.name() ~ "-" ~ this.ver;
    }

    /// Compiler name (dmd/ldc/gdc)
    abstract string name ();

    /// Downloads compiler and stored in the sandbox cache
    abstract void fetch ();

    /// Disables currently enabled compiler
    abstract void disable ();

    /// Enables compiler, downloads if necessary
    abstract void enable ();
}