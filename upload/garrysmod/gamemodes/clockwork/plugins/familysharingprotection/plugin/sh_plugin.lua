local Clockwork = Clockwork;

-- Prevent the plugin from being registered (due to GitHub issue #528)
PLUGIN.Register = function() end;

Clockwork.kernel:IncludePrefixed("sv_hooks.lua");
