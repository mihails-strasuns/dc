module dc.utils.trace;

string traceCall ( string func = __FUNCTION__ )
{
    import std.format;

    return format(
        q{
            import std.traits : ParameterIdentifierTuple;
            import std.experimental.logger : trace;
            import std.string : join;

            enum args = [ ParameterIdentifierTuple!(%s) ].join(`, " ",`);

            mixin(`trace(__FUNCTION__, "(", ` ~ args ~ `, ")");`);
        },
        func
    );
}

version(unittest)
{
    void foo ( int x )
    {
        mixin(traceCall());
    }
}
