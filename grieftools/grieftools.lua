--[[

Grief Tools ~ effy

]]--


local names = {}


local ui_get, ui_set, ui_set_visible, ui_check, ui_combo, ui_text, ui_call, ui_label, ui_button, set_cvar, set_clantag, delay_call = ui.get, ui.set, ui.set_visible, ui.new_checkbox, ui.new_combobox, ui.new_textbox, ui.set_callback, ui.new_label, ui.new_button, client.set_cvar, client.set_clan_tag, client.delay_call
local hasInf = false
local lp = entity.get_local_player()
local lpname = entity.get_player_name(lp, "m_iName")

local old_name = lpname
local old_clan = entity.get_prop(entity.get_player_resource(), "m_szClan", lp)
local old_size


local fuckingstupidfuckinglua = ui.reference("MISC", "Miscellaneous", "Steal player name") -- kill me

local chokedcmds = 0
client.set_event_callback("run_command", function(c)
	chokedcmds = c.chokedcommands 
end)

local function setName(name)
    set_cvar("name", name)
end

local function get_entindex_for_name(name)
    for player=1, globals.maxplayers() do 
        local tmp_name = entity.get_player_name(player)
        if tmp_name == name then 
            return player 
        end
    end
end

local namelabel = ui_label("LUA", "A", "-- Grief Tools --")
local namelist = ui_combo("LUA", "A", "Name List", "~", unpack(names))
local nameclan = ui_check("LUA", "A", "Steal Clantag")
local nameteam = ui_check("LUA", "A", "Include enemy team")
local hidename = ui_check("LUA", "A", "Hide infinite name")


local function updateNames()
    local ret = {}
    for i = globals.maxplayers(), 1, -1 do
        i = math.floor(i);
        local name = entity.get_player_name(i)
        if (name ~= 'unknown' and i ~= lp) then
            local lpTeam = entity.get_prop(lp, "m_iTeamNum");
            local otherTeam = entity.get_prop(i, "m_iTeamNum");
                if (ui_get(nameteam)) then 
                    table.insert(ret, name)
                else
                    if (entity.is_enemy(i) == false) then
                        table.insert(ret, name)
                    end
                end
        end
    end
    names = ret
end

local function update_menu_item()
    if old_size ~= #names then 
		ui.set_visible(namelist, false)
		old_size = #names
		namelist = ui.new_combobox("LUA", "A", "Name List", "~", unpack(names))
	end
end


local nameupdate = ui_button("LUA", "A", "Update list", function() 
    updateNames()
    update_menu_item()
end)



local target = get_entindex_for_name(ui_get(namelist))
local name = entity.get_player_name(target, "m_iName")

local infnamebut = ui_button("LUA", "A", "Infinite name", function()
    local lpname = entity.get_player_name(lp, "m_iName")
    if (lpname == nil or lpname == "") then -- thigh high wearing codenz
        lpname = old_name
    end
    ui_set(fuckingstupidfuckinglua, true)
    delay_call(0.2,setName,"\n\xAD\xAD\xAD")
    delay_call(0.5,setName,lpname)
    hasInf = true
    if (ui_get(hidename)) then
        delay_call(0.2, client.exec, "say ﷽﷽ ﷽﷽﷽ ﷽﷽﷽ ﷽ ﷽﷽ ﷽﷽﷽ ﷽﷽﷽ ﷽ ﷽﷽ ﷽﷽ ﷽﷽﷽ ﷽﷽﷽ ﷽ ﷽﷽ ﷽﷽﷽ ﷽﷽")
    end
end)

local namebut = ui_button("LUA", "A", "Steal name", function() 
    local target = get_entindex_for_name(ui_get(namelist))
    if (target == nil) then 
        return print("Please select a target")
    end
    local name = entity.get_player_name(target, "m_iName")
    local clantag = entity.get_prop(entity.get_player_resource(), "m_szClan", target)
    if (chokedcmds == 0) and (name ~= nil) then
            if (ui.get(nameclan) and clantag ~= nil) then
                set_clantag((clantag))
            end
                delay_call(0.8,setName,(name).. " ")
                print("Set name to: "..clantag.." ".. name)
    end
end)

local resetnamebut = ui_button("LUA", "A", "Reset name", function()
    setName(old_name) 
    if (old_clan ~= nil) then 
        set_clantag(old_clan) 
    end 
end)

client.set_event_callback("player_connect_full", function()
    updateNames()
    update_menu_item()
    return
end)

ui_call(nameteam, function() updateNames() update_menu_item() end)

