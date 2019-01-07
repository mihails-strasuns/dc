/**
    Majority of higher level application logic.
 */
module dc.dc;

import dc.utils.path;
import dc.compilers.base;
import dc.platform.api;
import dc.config;


/**
    Bitflag defining actions to take during this run.
 */
public enum Action
{
    /// Download new compiler distribution
    Fetch   = 1,
    /// Disable the currently present compiler (if present)
    Disable = 1 << 1,
    /// Switch to the specified compiler
    Enable  = 1 << 2,
}

/**
    Packs together action to take and necessary context
 */
public struct ActionContext
{
    Action action;
    Compiler new_compiler;
}

/**
    Thrown when something is wrong with CLI arguments
*/
public class HelpMsgException : Exception
{
    this (string file = __FILE__, size_t line = __LINE__)
    {
        super("", file, line);
    }
}

/**
    Initializes action context from command-line arguments, creating
    necessary intermediate objects.
 */
ActionContext parseAction (string[] args)
{
    if (args.length != 2)
        throw new HelpMsgException;

    auto action = () {
        switch (args[0])
        {
            case "use":   return (Action.Fetch | Action.Disable | Action.Enable);
            case "fetch": return Action.Fetch;

            default: assert(false);
        }
    } ();

    import dc.compilers;
    return ActionContext(action, compiler(args[1]));
}

/**
    Implements main toolchain management logic. Lower level implementation
    is provided via `dc.compilers` and `dc.platfrom` packages.
 */
void handle (ActionContext context)
{
    import dc.compilers;

    Compiler current_compiler = () {
        import std.file : readText, exists;

        if (exists(config.paths.root ~ "USED"))
            return compiler(readText(config.paths.root ~ "USED"));
        else
            return null;
    } ();

    if (context.action & Action.Disable)
    {
        if (current_compiler !is null && current_compiler != context.new_compiler)
            current_compiler.disable();
    }

    if (context.action & Action.Fetch)
    {
        assert(context.new_compiler !is null);
        context.new_compiler.fetch();
    }

    if (context.action & Action.Enable)
    {
        assert(context.new_compiler !is null);
        if (context.new_compiler != current_compiler)
            context.new_compiler.enable();
    }
}

/**
    Ensures the presence of a required directory structure for
    the D toolchain directory

    Params:
        paths = part of configuration describing sandbox path layout
 */
void initializeToolchainDir(Config.Paths paths)
{
    import std.file : mkdirRecurse, exists;
    import std.experimental.logger;

    auto root = paths.root;

    if (exists(root))
        return;

    infof("Creating D sandbox at '%s'", root);

    foreach (dir; paths.tupleof)
        mkdirRecurse(dir);
}