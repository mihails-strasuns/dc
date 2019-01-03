module dc.app;

import dc.sandbox;
import dc.config;
import dc.utils.path;
import dc.platform.api;

void main (string[] args)
{
    import simpleconfig;

    Config config;
    args = readConfiguration(config);
    args = args[1 .. $];

    import std.exception;
    enforce(args.length > 1, "Must specify an action");
    auto action = args[0];

    initSandbox(config.paths);

    import dc.platform.construct;
    auto platform = initializePlatform();

    switch(action)
    {
        case "use":
            if (disableOldCompiler(config, platform, args[1]))
            {
                auto c = compiler(config, platform, args[1]);
                c.fetch();
                c.enable();
            }
            break;

        case "fetch":
            if (disableOldCompiler(config, platform, args[1]))
            {
                auto c = compiler(config, platform, args[1]);
                c.fetch();
            }
            break;

        default: enforce(false);
    }
}

bool disableOldCompiler (Config config, Platform platform, string compiler_str)
{
    import std.file : readText, exists;

    if (exists(config.paths.root ~ "USED"))
    {
        auto current_compiler_str = readText(config.paths.root ~ "USED");

        if (compiler_str == current_compiler_str)
            return false;
        else
        {
            auto current = compiler(config, platform, current_compiler_str);
            current.disable();
            return true;
        }
    }

    return true;
}
