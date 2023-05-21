--This script displays all of the selected media items and allows you to go to one's position when clicking on it

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
end

loadfile(lib_path .. "Core.lua")()
loadfile(lib_path .. "Classes/Class - Tree.lua")()
loadfile(lib_path .. "Classes/Class - Label.lua")()

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end





-----------------
----- ITEMS -----
-----------------

SELECTED_ITEMS = {}
COLLAPSED_TRACKS = {}

--run through to see if any elements of the item have changed - takes two tables
function CompareInfo(original_info, new_info)
	for key, value in pairs(original_info) do
		if not new_info[key] or value ~= new_info[key] then
			return true
		end
	end

	return false
end


--run through to see if any items have changed
function CompareItems()
	local new_items = {}		--stores info of new items when comparing
	local is_refresh = false 	--keeps track of whether the item comparison needs to happen or not

	local item_count = reaper.CountSelectedMediaItems(0)	--hold how many items are selected

	if #SELECTED_ITEMS ~= item_count then
		is_refresh = true
	end

	for i = 0, item_count - 1 do
		local new_item = reaper.GetSelectedMediaItem(0, i)
		local new_position = reaper.GetMediaItemInfo_Value(new_item, "D_POSITION")
		
		local take = reaper.GetActiveTake(new_item)
		local retval, new_name

		if take then
			new_name = reaper.GetTakeName(take)
		else
			retval, new_name = reaper.GetSetMediaItemInfo_String(new_item, "P_NOTES", "", false)
		end

		--store item infomation
		table.insert(new_items, {
			item=new_item,
			track=reaper.GetMediaItem_Track(new_item),
			name=new_name,
			position=new_position,
		})

		--see if the item information has changed and set is_refresh to true if it has
		if not is_refresh and CompareInfo(SELECTED_ITEMS[i+1], new_items[i+1]) then
			is_refresh = true
		end
	end

	-- SortTable(new_items, "position") --return array in order of time position

	return is_refresh, new_items
end


--makes a table of only the names in SELECTED_ITEMS so the list can display them
function UpdateTree(new_items)
	GUI.elms.ItemTree:clear()

	local tracks = {}

	if #new_items > 0 then
		local items = {}
		local last_track

		for i, info in ipairs(new_items) do

			--parent the items to the track item
			if last_track and last_track.data ~= info["track"] then
				last_track:addchildren(items)

				if not COLLAPSED_TRACKS[tostring(last_track.data)] then
					last_track:setexpanded(true)
				end

				table.insert(tracks, last_track) --record top level item

				items = {}
				last_track = nil
			end

			--make the new track item
			if not last_track then
				local retval, track_name = reaper.GetTrackName(info["track"])

				last_track = GUI.TreeItem:new(track_name)

				last_track:setdata(info["track"])
				last_track:setselectable(false)
			end

			--make the item for the media item
			local item = GUI.TreeItem:new(info["name"])
			item:setparentable(false)
			item:setdata(info)

			table.insert(items, item)
		end

		last_track:addchildren(items) --catch the last loop
		if not COLLAPSED_TRACKS[tostring(last_track.data)] then
			last_track:setexpanded(true)
		end

		table.insert(tracks, last_track)

		GUI.elms.ItemTree:addtoplevelitems(tracks)
	end

	GUI.elms.ItemTree.header:setcaption(#new_items > 0 and "Selected Items: " .. tostring(#new_items) or "")

	return tracks
end





------------------
------ MISC ------
------------------

--sees when the GUI changes or the selected items change
function ObserveChanges()
	local width, height = gfx.w, gfx.h

	--resizes the GUI if you adjusted the size
	if (width ~= LAST_W) or (height ~= LAST_H) then
		ResizeList(width, height)
		LAST_W, LAST_H = width, height
	end

	local is_refresh, new_items = CompareItems()

	if is_refresh then
		UpdateTree(new_items)
		SELECTED_ITEMS = new_items
	end
end


--auto-resizes the list when you adjust the height
function ResizeList(width, height)
	GUI.elms.ItemTree.w = gfx.w - (GUI.elms.ItemTree.x * 2)
	GUI.elms.ItemTree.h = gfx.h - (GUI.elms.ItemTree.y * 2) + 50 -- +50 to account for other item positions (label and menubar)

	GUI.elms.ItemTree:init()
	GUI.elms.ItemTree:redraw()

	return true
end










-------------------
-----MAIN CODE-----
-------------------


--main code to get initially selected items
local _
_, SELECTED_ITEMS = CompareItems()





--start main GUI/beginning GUI elements stuff
GUI.name = "Display Selected Items"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 270, 600
GUI.anchor, GUI.corner = "mouse", "T"

GUI.no_menu = true

GUI.New("ItemTree", "Tree", {
    z = 20,
    x = 10,
    y = 25,
    w = 250,
    h = 565,
    header={caption="", alignment=GUI.AlignMode.center|GUI.AlignMode.left},
    is_multi = true,
    is_arrangeable = true,
    font_a = 3,
    font_b = 4,
    color = "txt",
    col_fill = "elm_fill",
    bg = "elm_bg",
    cap_bg = "wnd_bg",
    shadow = true,
    pad = 4,
    selection_mode = GUI.SelectionMode.text_space
})


GUI.Header.ascending_symbol = "(P) " 	--sorted by position
GUI.Header.descending_symbol = "(N) "	--sorted by name


-------------------
----- SIGNALS -----
-------------------

function GUI.elms.ItemTree:sortitems(sort_order, items)

	--sorts the array given to it by whatever key value you provide
	local function sort_by_key (temp_table, key)
		local item_count = #temp_table
		local has_changed

		repeat
			has_changed = false
			item_count = item_count - 1

			for i = 1, item_count do
				if temp_table[i].data[key] > temp_table[i + 1].data[key] then
					temp_table[i], temp_table[i + 1] = temp_table[i + 1], temp_table[i]
					has_changed = true
				end
			end
		until has_changed == false

		return temp_table
	end

	local key = ""
	if not sort_order then GUI.elms.ItemTree:togglesortmode() end

	if GUI.elms.ItemTree.current_sort == GUI.SortMode.ascending then
		key = "position"
	elseif GUI.elms.ItemTree.current_sort == GUI.SortMode.descending then
		key = "name"
	else
		return
	end

	if items then
		items = sort_by_key(items, key)
		self:redraw()
		return items

	--sort children of all top level items
	else
		for i, top_item in ipairs(GUI.elms.ItemTree.top_items) do
			if #top_item.children > 0 then
				top_item.children = sort_by_key(top_item.children, key)
			end
		end

		self:redraw()

		return GUI.elms.ItemTree.top_items
	end
end



-------------------
----- SIGNALS -----
-------------------

function GUI.elms.ItemTree:onrearrange(moved_items, up_item)
	if not moved_items or #moved_items == 0 then return false end

	local is_base = not moved_items[1].parent and true or false
	local track

	reaper.Undo_BeginBlock()

	reaper.PreventUIRefresh(1)

	--if parenting to a track then just move it to the track
	if not is_base then
		local track_item = up_item.parent or up_item
		track = track_item.data
	
	--if adding to the top layer then create a new track
	else

		local track_index = 0 --insert track at the top of the session

		if not GUI.elms.ItemTree.top_items[1] == moved_items[1] then

			--insert it at the end
			if not up_item then
				track_index = reaper.CountTracks(0)

			--insert it before/after the up_item
			else
				track_index = reaper.CSurf_TrackToID(up_item.data, false)
			end
		end

		reaper.InsertTrackAtIndex(track_index, true)
		track = reaper.GetTrack(0, track_index)

		reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "New Track", true)
	end

	for i, item in ipairs(moved_items) do
		reaper.MoveMediaItemToTrack(item.data["item"], track)
	end

	reaper.PreventUIRefresh(-1)
	reaper.UpdateArrange()

	reaper.Undo_EndBlock("Move Items to Track", -1)
end

--remove the expanded item from the collapsed list if it is in it
function GUI.elms.ItemTree:onexpand(item)

	--if the item was previously collapsed, remove it from the list
	local track = tostring(item.data)
	if COLLAPSED_TRACKS[track] then COLLAPSED_TRACKS[track] = nil end

	return item
end

--add the item to the collapsed table when it is collapsed
function GUI.elms.ItemTree:oncollapse(item)
	COLLAPSED_TRACKS[tostring(item.data)] = true
	
	return item
end


--go to the item in the project on selection
function GUI.elms.ItemTree:onselection(items)
	
	if #items > 0 then
		local item = items[1]
		local info = item.data

		reaper.SetEditCurPos(info["position"], true, false)

		reaper.SetOnlyTrackSelected(info["track"], true)
		reaper.Main_OnCommand(40913, 0) -- Track: Vertical scroll selected tracks into view

		--changes zoom level if it is smaller (more zoomed out) than 20 pixels/second and you are looking for a marker or an item
		if reaper.GetHZoomLevel() < 20 then reaper.adjustZoom(20.0, 1, true, -1) end
	end

	return items
end





--------------------
----- GUI START-----
--------------------

GUI.freq = 0.5
GUI.func = ObserveChanges

GUI.Init()

LAST_W, LAST_H = gfx.w, gfx.h

--if the tool is starting off docked then scale it appropriately
if gfx.dock(-1) ~= 0 then ResizeList(LAST_W, LAST_H) end

if #SELECTED_ITEMS > 0 then UpdateTree(SELECTED_ITEMS) end

GUI.Main()