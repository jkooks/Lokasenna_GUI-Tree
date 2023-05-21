--This script is just so I can check returns in Reaper

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
end

loadfile(lib_path .. "Core.lua")()
loadfile(lib_path .. "Classes/Class - Tree.lua")()
loadfile(lib_path .. "Classes/Class - Button.lua")()





function Existing(num, table1)
    for check in ipairs(table1) do
        if check == num then
            return false
        end
    end

    return true
end



function GenerateItems()

    local all_items = {} --stores all items to randomly parent
    local top_items = {} --store only top level items, since that is what we add to the tree

    local numbers = {} 

    math.randomseed(os.time())

    for i = 1, 1000 do
        
        --make sure we don't have any repetetive item text
        local number = 0
        while number == 0 or not Existing(number, numbers) do
            number = math.random(1, 1000)
        end

        local new_item = GUI.TreeItem:new(number)

        --store top items
        if i == 1 or number % 100 == 0 then
            table.insert(top_items, new_item)

        --parent new item to a different, random item
        else
           local top = all_items[math.random(1, #all_items)]

           top:addchildren(new_item)

           if not top.expanded then top:setexpanded(true) end
        end

        table.insert(all_items, new_item)

        table.insert(numbers, number)
    end

    return top_items, all_items
end





GUI.name = "Random Tree Generator"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 400, 700
GUI.anchor, GUI.corner = "mouse", "TR"


GUI.New("MyTree", "Tree", {
    z = 20,
    x = 15,
    y = 30,
    w = 370,
    h = 610,
    is_multi = true,
    header = {caption = "Header", alignment=GUI.AlignMode.center|GUI.AlignMode.horizontal},
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

GUI.New("MyButton", "Button", {
    z = 10,
    x = 15,
    y = 650,
    w = 370,
    h = 35,
    caption = "Generate New Tree",
}) 


function GUI.elms.MyButton:onmouseup()
    GUI.Button.onmouseup(GUI.elms.MyButton)

    GUI.elms.MyTree:clear()

    local top_items, all_items = GenerateItems()

    GUI.elms.MyTree:addtoplevelitems(top_items)
end


GUI.Init()
GUI.Main()