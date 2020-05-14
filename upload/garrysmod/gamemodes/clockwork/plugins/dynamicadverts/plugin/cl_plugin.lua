--[[
	© CloudSixteen.com do not share, re-distribute or modify
	without permission of its author (kurozael@gmail.com).

	Clockwork was created by Conna Wiles (also known as kurozael.)
	http://cloudsixteen.com/license/clockwork.html
--]]

Clockwork.datastream:Hook("DynamicAdverts", function(data)
	for k, v in pairs(data) do
		cwDynamicAdverts:CreateHTMLPanel(v);
	end;
	
	cwDynamicAdverts.storedList = data;
end);

Clockwork.datastream:Hook("DynamicAdvertAdd", function(data)
	cwDynamicAdverts.storedList[#cwDynamicAdverts.storedList + 1] = data;
	cwDynamicAdverts:CreateHTMLPanel(data);
end);

Clockwork.datastream:Hook("DynamicAdvertRemove", function(data)
	for k, v in pairs(cwDynamicAdverts.storedList) do
		if (v.position == data) then
			cwDynamicAdverts.storedList[k] = nil;
			
			if (IsValid(v.panel)) then
				v.panel:Remove();
			end;
		end;
	end;
end);

-- A function to create a HTML panel.
function cwDynamicAdverts:CreateHTMLPanel(dynamicAdvert)
	dynamicAdvert.panel = vgui.Create("HTML");
	dynamicAdvert.panel:SetPaintedManually(true);
	dynamicAdvert.panel:SetSize(dynamicAdvert.width, dynamicAdvert.height);
	dynamicAdvert.panel:SetPos(0, 0);
	dynamicAdvert.panel:SetHTML([[
		<head>
			<style type="text/css">
				body, html {
					vertical-align: 50%;
					overflow: hidden;
					text-align: center;
					padding: 0;
					margin: 0;
					height: 100%;
				}
				img {
					position: relative;
					margin-top: -]]..(dynamicAdvert.height / 2)..[[px;
					heigth: ]]..dynamicAdvert.height..[[;
					width: ]]..dynamicAdvert.width..[[;
					top: 50%;
				}
			</style>
		</head>
		<body scroll="no" scrolling="no">
			<img src="]]..dynamicAdvert.url..[["/>
		</body>
	]]);
end;