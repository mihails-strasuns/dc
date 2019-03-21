module dc.app;

import dc.dc;
import dc.utils.path;
import dc.platform.api;
import dc.exception;
import std.experimental.logger;

void main (string[] args)
{
    try
    {
        configureLogging();

        import dc.platform;
        import dc.install;

        Path toolchain_dir;
        if (installIfNeeded(toolchain_dir))
        {
            infof("Initial setup done, toolchain directory created at %s",
                toolchain_dir);
        }

        if (args.length == 1)
            return;

        auto context = parseAction(args[1 .. $]);

        initializePlatform();
        handle(context, toolchain_dir);
    }
    catch (DcException e)
    {
        error(e.msg);

        if (e.details.length)
        {
            info("Additional information:\n");
            info(e.details);
        }
    }
    catch (HelpMsgException)
    {
        info("Usage: dc COMMAND COMPILER");
        info("");
        info("COMMAND: action to perform");
        info("\tuse - switch to specified compiler, disabling the current one if present");
        info("\tfetch - download specified compiler distribution without affecting the current one");
        info("");
        info("COMPILER: compiler description string");
        info("\tdmd-2.099.9 - example, describes DMD compiler of version 2.099.9");
    }
}

void configureLogging ()
{
    static class SimpleLogger : Logger
    {
        this (LogLevel lv)
        {
            super(lv);
        }

        override void writeLogMsg (ref LogEntry payload)
        {
            import std.stdio;
            writeln(payload.msg);
        }
}

    // TODO: verbosity levels
    sharedLog = new SimpleLogger(LogLevel.info);
}
