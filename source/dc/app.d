module dc.app;

import dc.sandbox;
import dc.config;
import dc.utils.path;
import dc.utils.platform : checkRequirements;

void main (string[] args)
{
    auto config = readConfig();

    import std.algorithm : filter, startsWith;
    import std.array : array;

    args = filterFlags(args);

    import std.exception;
    enforce(args.length > 1, "Must specify an action");
    auto action = args[0];

    checkRequirements();
    initSandbox(config.paths);

    switch(action)
    {
        case "use":
            if (disableOldCompiler(config, args[1]))
            {
                auto c = compiler(config, args[1]);
                c.fetch();
                c.enable();
            }
            break;

        case "fetch":
            if (disableOldCompiler(config, args[1]))
            {
                auto c = compiler(config, args[1]);
                c.fetch();
            }
            break;

        default: enforce(false);
    }
}

string[] filterFlags (string[] args)
{
    import std.range.primitives;

    typeof(return) result;
    args = args[1 .. $];

    foreach (i, _; args)
    {
        if (args[i].front != '-' && (i == 0 || args[i-1][0] != '-'))
            result ~= args[i];
    }

    return result;
}

bool disableOldCompiler (Config config, string compiler_str)
{
    import std.file : readText, exists;

    if (exists(config.paths.root ~ "USED"))
    {
        auto current_compiler_str = readText(config.paths.root ~ "USED");

        if (compiler_str == current_compiler_str)
            return false;
        else
        {
            auto current = compiler(config, current_compiler_str);
            current.disable();
            return true;
        }
    }

    return true;
}
