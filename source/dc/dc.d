/**
    Majority of higher level application logic.
 */
module dc.dc;

import dc.utils.path;
import dc.compilers.api;
import dc.platform.api;
import std.experimental.logger;


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
    /// Print a path to the bindir of the specified compiler without installing
    /// anything (but still fetch the distribution if needed)
    Path   = 1 << 3,
}

/**
    Packs together action to take and necessary context
 */
public struct ActionContext
{
    Action action;
    string new_compiler;
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
    import std.exception;

    enforce!HelpMsgException(args.length >= 1);

    switch (args[0])
    {
        case "use":
            enforce!HelpMsgException(args.length == 2);
            return ActionContext(Action.Fetch | Action.Disable | Action.Enable, args[1]);
        case "fetch":
            enforce!HelpMsgException(args.length == 2);
            return ActionContext(Action.Fetch, args[1]);
        case "disable":
            return ActionContext(Action.Disable, null);
        case "path":
            return ActionContext(Action.Fetch | Action.Path, args[1]);

        default: assert(false);
    }
}

/**
    Implements main toolchain management logic. Lower level implementation
    is provided via `dc.compilers` and `dc.platfrom` packages.
 */
void handle (ActionContext context, Path root)
{
    import dc.compilers;

    // disable informational output to be able to forward printed script to shell
    if (context.action & Action.Path)
        sharedLog.logLevel = LogLevel.error;

    Compiler current_compiler = () {
        import std.file : readText, exists;

        if (exists(root ~ "USED"))
            return compilerFromAnchor(root ~ "USED", root);
        else
            return null;
    } ();

    Compiler new_compiler = context.new_compiler ?
          compilerFromDescription(context.new_compiler, root)
        : null;

    if (context.action & Action.Disable)
    {
        if (current_compiler !is null && current_compiler != new_compiler)
            current_compiler.disable();
    }

    if (context.action & Action.Fetch)
    {
        assert(new_compiler !is null);
        new_compiler.fetch();
    }

    if (context.action & Action.Enable)
    {
        assert(new_compiler !is null);
        if (new_compiler != current_compiler)
            new_compiler.enable();
    }

    if (context.action & Action.Path)
    {
        assert(new_compiler !is null);

        import std.stdio;

        auto path = new_compiler.distributionBinPath();
        writeln(path);
    }
}
