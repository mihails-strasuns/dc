module dc.utils.reporting;

/**
    Mixin for common boilerplate to print status message while
    some process is happenning and either success report ot nothing
    depending on the result.

    Params:
        fmt = format string to use, must only have one %s parameter
        arg = symbol reference to the argument to be used for
            the formatted string, usually some locale variable
 */
string report (string fmt, alias arg) ()
{   
    import std.range : join;
    import std.format;
    
    return format(q{
            {
                import std.format;
                import std.stdio : stdout;

                stdout.writef(format("%s", %s));
                stdout.write(" ...");
                stdout.flush();
            }
            scope(success)
            {
                import std.stdio : stdout;
                stdout.writeln(" done.");
            }
        },
        fmt,
        __traits(identifier, arg)
    );
}