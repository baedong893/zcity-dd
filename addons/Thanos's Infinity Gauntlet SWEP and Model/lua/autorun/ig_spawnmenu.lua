if SERVER then
	AddCSLuaFile()
	return
end

local function Client(panel)
	panel:ClearControls()
	
	panel:AddControl("Label", {Text = "Lower for better performance but lower quality effects."})
	local slider = vgui.Create("DNumSlider", panel)
	slider:SetDecimals(1)
	slider:SetMin(0)
	slider:SetMax(1)
	slider:SetConVar("ig_particlescale")
	slider:SetValue(GetConVar("ig_particlescale"):GetFloat())
	slider:SetText("Particle Quality")
	panel:AddItem(slider)
end

local function PopulateToolMenu()
	spawnmenu.AddToolMenuOption("Options","Infinity Gauntlet","Infinity Gauntlet Client","Client","","",Client)
end

hook.Add("PopulateToolMenu","IG_PopulateMenuClient",PopulateToolMenu)

if GetConVar("ig_time_reverse_fps") then
	local function Admin(panel)
		panel:ClearControls()
		
		panel:AddControl("Label", {Text = "Use old model? Restart to apply."})
		panel:AddControl("CheckBox", {Label = "Use Old Model", Command = "ig_useoldmodel"})
		
		panel:AddControl("Label", {Text = "Disable to conserve memory usage but prevents time reversing from reverting bone manipulations."})
		panel:AddControl("CheckBox", {Label = "Time Reverses bones?", Command = "ig_time_record_bones"})
		
		panel:AddControl("Label", {Text = "Disable to conserve memory usage but prevents time reversing from reverting flex manipulations."})
		panel:AddControl("CheckBox", {Label = "Time Reverses flexes?", Command = "ig_time_record_flex"})
		
		panel:AddControl("Label", {Text = "VERY SLOW! Enable at your own risk."})
		panel:AddControl("CheckBox", {Label = "[SLOW] Time Reverses constraints?", Command = "ig_time_record_constraints"})
		
		panel:AddControl("Label", {Text = "Lower for better performance but choppier time reversal."})
		local slider = vgui.Create("DNumSlider", panel)
		slider:SetDecimals(0)
		slider:SetMin(1)
		slider:SetMax(60)
		slider:SetConVar("ig_time_reverse_fps")
		slider:SetValue(GetConVar("ig_time_reverse_fps"):GetInt())
		slider:SetText("Time Reversal FPS")
		panel:AddItem(slider)
		
		panel:AddControl("Label", {Text = "Lower to reduce memory usage but less time reversal length."})
		local slider = vgui.Create("DNumSlider", panel)
		slider:SetDecimals(0)
		slider:SetMin(1)
		slider:SetMax(1000)
		slider:SetConVar("ig_time_max_frames")
		slider:SetValue(GetConVar("ig_time_max_frames"):GetInt())
		slider:SetText("Time Reversal Max Frames")
		panel:AddItem(slider)
	end

	local function PopulateToolMenu()
		spawnmenu.AddToolMenuOption("Options","Infinity Gauntlet","Infinity Gauntlet Admin","Admin","","",Admin)
	end

	hook.Add("PopulateToolMenu","IG_PopulateMenuAdmin",PopulateToolMenu)
end
