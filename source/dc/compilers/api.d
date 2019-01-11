module dc.compilers.api;

/**
    Compiler management abstraction. Specific implementation has to know
    about actual paths and configuration needed to make compiler placed
    into the sandbox to work.
 */
abstract class Compiler
{
    /// Downloads compiler and stored in the sandbox cache
    void fetch ();

    /// Enables compiler, downloads if necessary
    void enable ();

    /// Disables currently enabled compiler
    void disable ();

    /// Standard text representation of this compiler description
    string representation ()
    {
        return this.name ~ "-" ~ this.ver;
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
    this (string name, string ver)
    {
        this.name = name;
        this.ver = ver;
    }

    protected {
        string name;
        string ver;
    }
}