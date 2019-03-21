local lastxchunk = 0
local lastychunk = 0

local function create_radar_info(player)
	
	if player.gui.left["radar_info"] then player.gui.left["radar_info"].destroy() end

	local frame = player.gui.left.add { type = "frame", name = "radar_info", direction = "vertical" }
	local rows = frame.add { type = "flow", name = "rows", direction = "vertical" }
	local jtable = rows.add { type = "table", name = "jtable", column_count = 2 }
	
	local xchunk = math.floor((player.position.x / 32))
	local ychunk = math.floor((player.position.y / 32))

	--jtable.add {type = "label", caption = "Player Chunk:"}
	--jtable.add {type = "label", caption = xchunk .. "," .. ychunk}
	--todo: show closest 3 - 5 radars search bounding box centered on player
	
	local radars = game.surfaces[1].find_entities_filtered{name = "radar"}
	local mindist = 100000
	jtable.add {type = "label", caption = "Nearest Radar:"}
	jtable.add {type = "label", caption = "", name = "closestposition"}
	jtable.add {type = "label", caption = "X,Y Distance:"}
	jtable.add {type = "label", caption = "", name = "closestdist"}
	for _, radar in pairs (radars) do
		local rxchunk = math.floor(radar.position.x / 32)
		local rychunk = math.floor(radar.position.y / 32)
	
		local xdist = math.abs(xchunk - rxchunk)
		local ydist = math.abs(ychunk - rychunk)
		local dist = math.sqrt(xdist*xdist + ydist*ydist)
	
		if dist < mindist then
			jtable.closestposition.caption = {"gui.closestposition", rxchunk .. " , " .. rychunk}
			jtable.closestdist.caption = {"gui.closestdist", xdist .. " , " .. ydist}
			mindist = dist
		end
	end
end


local function create_gui(event)
	local player = game.players[event.player_index]
	if player.cursor_stack.valid_for_read and player.cursor_stack.name:match("radar") then create_radar_info(player) 
	elseif player.gui.left["radar_info"] then player.gui.left["radar_info"].destroy() 
	end
end

local function update_gui(event)
	local player = game.players[event.player_index]
	local xchunk = math.floor((player.position.x / 32))
	local ychunk = math.floor((player.position.y / 32))
	if xchunk ~= lastxchunk then
		if player.gui.left["radar_info"] then create_radar_info(player) end
		lastxchunk = xchunk
	end
	if ychunk ~= lastychunk then
		if player.gui.left["radar_info"] then create_radar_info(player) end
		lastychunk = ychunk
	end
end

local function player_cursor_stack_changed(event)
	create_gui(event)
end

local function player_changed_position(event)
	update_gui(event)
end

script.on_event(defines.events.on_player_cursor_stack_changed, player_cursor_stack_changed)
script.on_event(defines.events.on_player_changed_position, player_changed_position)
