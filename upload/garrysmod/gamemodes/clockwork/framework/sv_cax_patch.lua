print("Please wait while Clockwork initializes...")

CloudAuthX = CWUtil;
CloudAuthX.kernel = {};

function CloudAuthX.GetVersion()
    return CLOUDAUTHX_VERSION;
end;

function CloudAuthX.kernel:IncludeSchema()
    local schemaFolder = Clockwork.kernel:GetSchemaFolder();

    if (schemaFolder == "") then
        return;
    end;

    Clockwork.config:Load(nil, true);
    Clockwork.plugin:Include(schemaFolder .. "/schema", true);
    Clockwork.config:Load();
end;

function CloudAuthX.Base64Encode(data)
    if (!data) then
        return "";
    end;

    return util.Base64Encode(data);
end;

function CloudAuthX.Base64Decode(data)
    if (!data) then
        return "";
    end;
    
    return util.Base64Decode(data);
end;

function CloudAuthX.External(data)
    MsgC(Color(255, 100, 0, 255), "[Clockwork] CloudAuthX.External is no longer supported.\n");
end;

local cwOldRunConsoleCommand = RunConsoleCommand;

function RunConsoleCommand(...)
	local arguments = {...};
	
	if (arguments[1] == nil) then
		return;
	end;
	
	cwOldRunConsoleCommand(...);
end;