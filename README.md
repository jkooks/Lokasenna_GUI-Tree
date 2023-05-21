# Lokasenna_GUI-Tree
  A tree class for the ReaScript Lokasenna_GUI/Scythe module. It was delevloped for use with Lokasenna_GUI v2 on both Mac (i7) and Windows environments. It works similarily to PyQt's Tree class, as that is what I am most familiar with, but it relies on similar function naming schemes as Lokasenna_GUI and (hopefully) works similarly to what you would expect.





# Installation
  In order to install the class, take the "Class - Tree.lua" file and place it along with all of the other Lokasenna_GUI classes, somewhere along the lines of "*Lokasenna_GUI_Path*/Lokasenna_GUI-master/Lokasenna_GUI v2/Library/Classes/". Once you've placed the class file in that location you will be able to load it like any other class after loading the Core file. But in case you need a refresher, that would look something like this:
  ```
  local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
    if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
  end

  loadfile(lib_path .. "Core.lua")()
  loadfile(lib_path .. "Classes/Class - Tree.lua")()
  loadfile(lib_path .. "Classes/Class - Label.lua")()
  ```




# Getting Started

## Creating a Tree
Creating a tree is fairly similar to most (if not all) Lokasenna_GUI class creations - all you need to do is call `GUI.New`, give it a name as the first argument, tell it to create a "Tree" as the second, and pass it either a table to unpack or all of the individual parameters. An example is below, where we create a tree named "NewTree":
```
GUI.New("NewTree", "Tree", {
	z = 20,
	x = 10,
	y = 10,
	w = 250,
	h = 500,
	font_a = 3,
	font_b = 4,
	color = "txt",
	col_fill = "elm_fill",
	bg = "elm_bg",
	cap_bg = "wnd_bg",
	shadow = true,
	pad = 4,
})
```

This will create a new tree element and assign it the proper parameters. Once you initialize it, by calling `GUI.Init()`, and display it, by calling `GUI.Main()`, you will see the tree show up along with all of the other elements.

## Adding TreeItems
Now that you have a basic element, the next step is to add some items. The items of a tree use a class called a "TreeItem", which can added either upon tree creation (pass a table to the "list" paramenter) or post initialization. The only items that are associated with the tree are the top level items (i.e. the items with no parent) - after that every item is parented to a different item, creating the hierarchy and structure that tree GUI elements are known for.

To create a tree that displays all of the items on the selected track, place the following code before creating the tree, and pass the `track_items` table to the list parameter:
```
local track_items = {}

for i = 0, reaper.CountTracks(0) - 1 do
local track = reaper.GetTrack(0, i)
local retval, track_name = reaper.GetTrackName(track)

local track_item = GUI.TreeItem:new(track_name)
track_item:setdata(track)

local items = {}
for j = 0, reaper.CountTrackMediaItems(track) - 1 do
  local media_item = reaper.GetTrackMediaItem(track, j)
  local media_take = reaper.GetActiveTake(media_item)

  if media_take then
      local name = reaper.GetTakeName(media_take)

      local tree_item = GUI.TreeItem:new(name)
      tree_item:setdata(media_item)

      table.insert(items, tree_item)
  end
end

if #items > 0 then
  track_item:addchildren(items)
end

table.insert(track_items, track_item)
end
```

What you should now notice is that your tree is populated with TreeItems, with the top layer ones being all of the tracks in your session and the parented items being the media items that are on those tracks! Additionally, this code also associates the track/media item to the respective tree item by using the function `tree_item:setdata()`, so if you ever need to do something within Reaper to the specific object that the tree item represents you can easily get that information by using the variable `tree_TreeItem:data`! More on that later, however. If, you need to remove all of those items, though, you can easily call `GUI.elms.NewTree:clear()` and it will remove all items from the Tree.

## Adding A Header
Along with trees and tree items there is also a new element: Headers. By defualt, these place themselves on top of the tree and act as a sort of "caption" for it - telling the user what they are looking at in a nice and clean manner. You can create a header in two ways: by creating a header with `GUI.New("NewHeader", "Header", {caption="My New Header"})` and supplying the header to `Tree:addheader()`, or you can take the easier way of having the tree create the header for you when you create the tree by supplying the "header" argument a table of the parameters you want the new header to have.

To test this out, pass your "NewTree" the following line of code by assigning the "header" key to it:
`header = {caption="My new header!"}`

This should create a header with the following caption at the top of the Tree. By default headers don't do much other than look somewhat nice, but if a tree can be sorted than clicking on them will toggle the sort mode of that tree and sort it either in an ascending or descending view (based off of how `Tree:sortitems()` is handling the sorting).

Now that you have all of that done, you should be ready to make a tree of your very own!





# Classes
As mentioned before, this module comes with three classes: Tree, Header, and TreeTreeItem: Each one of these has various variables and functions you can utilize and reimplement, which are listed below. These are only the basic interaction functions, so if you are looking to do more advance things you can take a look at the class functions in the script and read the documentation within the.

And as a general note, if you see something like "*type(s)*" below (i.e. "*TreeItem(s)*") it means you can either pass a single instance of that type or a table of them and the function can handle either case. And if you see "*TreeItems*" that just means a table of tree items.


## Tree Class

### Variables
**These are read-only variables! Please use the appropriate setter functions to set them!**

**Tables**
|Variable|Definition|
|Tree.list|The items you want to be on the top level, can also be a string but must be in CSV form|
|Tree.top_items|Holds the top level items in the tree (after initialization)|
|Tree.selected_items|Holds all the items that are currently selected|
|Tree.showing_items|Holds the items that are currently displayed in the window|

**Booleans**
Tree.is_doubleclick_expand
: If the user can expand a parent on double-click, default = true
Tree.is_expandable
: If the user can expand any parent items in the tree, default = true
Tree.is_multi
: If the user can select multiple items at once, default = false
Tree.is_arrangeable
: If the user can re-arrange the items in the tree by dragging, default = false
Tree.is_selectable
: If the user can select any items in the tree, default = true
Tree.is_sortable
: If the user can sort the table or not (mainly by clicking on the header), default = true

**GUI Types**
Tree.header *(GUI.Header)*
: The header that is assigned to the tree
Tree.selection_mode *(GUI.SelectionMode)*
: Where the user needs to click on in the GUI in order to select an item, default = GUI.SelectionMode.row
Tree.current_sort *(GUI.SortMode)*
: The mode that the tree is currently sorted in, default = GUI.SortMode.ignore
Tree.down_item *(TreeItem)*
: The last item that the mouse was clicked on
Tree.up_item *(TreeItem)*
: The last item that the mouse click was released on

### Functions

**Creation**
Tree:new(*string* name, *int* z, *int* x, *int* y, *int* w, *int* h, *table* list, *GUI.Header* header, *str* caption, *int* pad)
: Used to create a new Tree. Assigns the tree name to "name" and the other parameters to their defaults, unless a table is passed as the second element with the keys being the various parameters.

**Selection**
Tree:selectrange(*TreeItem* item1, *TreeItem* item2, *bool* state)
: Changes all items from the first item to the second item to the selection state that is passed.

Tree:selectitem(*TreeItem* item)
: Sets the item to be selected.

Tree:unselectitem(*TreeItem* item)
: Sets the item to be unselected.

Tree:toggleselected(*TreeItem* item)
: Toggles the selection status of the TreeItem:

Tree:selectonly(*TreeItem* item)
: Sets the item to be selected and unselects any other selected items.

Tree:clearselection()
: Unselects all selected items.

**Parenting**
*table* = Tree:addtoplevelitems(*TreeItem(s)* items, *optional int* index)
: Adds the TreeItems passed to the top, base layer of the list. If index is provided it places them at that spot of the list, otherwise appends them to the end. Returns table of items that were added on success.

*table* = Tree:removetoplevelitems(*TreeItem(s)* items)
: Removes the TreeItems if they are on the top, base layer of the list

*table* = Tree:clear()
: Clears the entire list of TreeItems that were part of the Tree. Returns the top level items that were cleared.

**Setters**
*GUI.Header* = Tree:setheader(*GUI.Header or table or string* new_header)
: Sets the passed header/parameters to be the header of the Tree and removes the current one (if there is one). Requires a reinitialization of the tree element, so other things may be lost - must call this manually after creating the header.

Tree:setdoubleclickexpand(*boolean* state)
: Allows the user to expand/collapse parent items by double-clicking on them

Tree:setarrangeable(*boolean* state)
: Allows the user to re-arrange items by dragging them around

Tree:setexpandable(*boolean* state)
: Allows the user to expand parent items

Tree:setmulti(*boolean* state)
: Allows the user to select multiple items at once

Tree:setselectable(*boolean* state)
: Makes it so no items in the tree are able to be selected

Tree:setsortable(*boolean* state)
: Allows the user to sort the items by selecting the header

Tree:setcurrentsort(*GUI.SortMode* sort_mode)
: Sets the current sort to whatever you want it to ascending, descending, or ignore

Tree:setselectionmode(GUI.SelectionMode)
: Sets where the user has to click in the GUI in order select the row (either row, text, or text_space)

**Helpers**
*string* = Tree:copyitemtext(*TreeItem(s)* items)
:Writes the text of all the items passed to the clipboard, with each item's text separated by a new line. By default, every tree can do this when you hit the `Cntrl + c` key. **Need SWS for this functionality.**

*TreeItem* = Tree:finditem(*string* text, *optional bool* is_partial, *optional bool* ignore_case)
: Finds the first item that matches the passed text. If `is_partial` is true it will only need to be within the item's text, and if `ignore_case` is true then the case sensitivity won't have to match (both dedault to false). Returns the item that matches the text, otherwise nil.

*TreeItems* = Tree:sortitems(*optional GUI.SortMode* sort_mode, *optional table* items)
: Sorts the specific items, if `items` is given, otherwise sorts the entire Tree. If `sort_mode` is provided it will sort to that, otherwise it will toggle the tree's `current_sort` and sort it to that. Can be reimplemented if you want it to sort in a specific manner, but default is alphanumerically based off of the item's text. Returns the sorted items.

*GUI.SortMode* = Tree:togglesortmode()
: Helper function for `Tree:sortitems` - toggles the `current_sort` and returns the new value.

**Signals**
All of these signals/functions can be reimplementable if you would like specific things to occur when they happen. They are additional ones to the usual that Lokasenna_GUI provides.

Tree:onitemadd(*TreeItems* items)
: Occurs whenever a TreeItem is parented to another or added as a top level item

Tree:onitemremove(*TreeItems* items)
: Occurs whenever a TreeItem is removed from a parent or removed as a top level item

Tree:onexpand(*TreeItem* item)
: Occurs whenever a TreeItem is expanded 

Tree:oncollapse(*TreeItem* item)
: Occurs whenever a TreeItem is collapsed

Tree:onrearrange(*TreeItems* moved_items, *TreeItem* up_item)
: Occurs whenever the user re-arranges items by dragging them around. `moved_items` are the items that are being moved and `up_item` is the item that the mouse was released on (can be nil if no item was released on)

Tree:onselection(*TreeItems* items)
: Occurs whenever the user selects (or unselects) an item


## TreeItem Class

### Variables
**These are read-only variables! Please use the appropriate setter functions to set them!**

**strings**
TreeItem:text
: The text that the item is displaying

**booleans**
TreeItem:is_hidden
: If the item is not supposed to be displayed or hidden from view
TreeItem:expanded
: If the item is expanded/collapsed
TreeItem:selected
: If the item is currently selected
TreeItem:showing
:If the item is currently being displayed
TreeItem:is_selectable
: If the item is able to be selected, default = true
TreeItem:is_expandable
: If the item is able to be expanded/collapsed, default = true
TreeItem:is_parentable
: If the item can be made a parent on user re-arrange, default = true

**ints**
TreeItem:depth
: The depth of the item in a hierarchy - base level items have a depth of 0, otherwise increments of 1

**objects**
TreeItem:data
: The object/information that this item is holding - used to easily store info in the item rather than having it in a separate table
TreeItem:parent
: The TreeItem that this one is a child of
TreeItem:children
: The table of items that are directly nested under this one, if any
TreeItem:tree
: The tree that this item is displayed in

### Functions

**Parenting**
*TreeItems* = TreeItem:addchildren(*TreeItem(s)* children, *optional int* index)
: Makes the item the parent of the children items. Default is to append them to the bottom of the list, but if index is passed it will add them at that spot in the list.

*TreeItems* = TreeItem:removechildren(*TreeItem(s)* children)
: Removes the items as children items of the TreeItem.

*TreeItems* = TreeItem:clearchildren()
: Removes all children items from being parented to the item.

**Setters**
*object* = TreeItem:setdata(*optional object* data)
: The information that the item is holding on to.

TreeItem:setexpanded(*optional boolean* state)
: Expands or collapses the item as long as it is expandable.

TreeItem:sethidden(*optional boolean* state)
: Whether the item is able to be shown or not.

TreeItem:setselected(*optional boolean* state)
: Whether the item currently selected or not.

TreeItem:settext(*optional string* text)
: The text that the item should display.

TreeItem:setexpandable(*optional boolean* state)
: Whether the item is able to be expanded or not.

TreeItem:setparentable(*optional boolean* state)
: Whether the item is able to become a parent on re-arrange.

TreeItem:setselectable(*optional boolean* state)
: If the item is able to be selected by the user or not.

**Helpers**
*int* = TreeItem:getindex(*TreeItem* child)
: Returns the index that the child is in in the parent's children

*TreeItem* = TreeItem:getgrandparent()
: Returns the highest, base layer item in the item's hierarchy

*boolean* = TreeItem:inhierarchy(*TreeItem* check_item)
: Checks to see if the `check_item` is above the the item's hierarchy


## Header Class

### Variables
**These are read-only variables! Please use the appropriate setter functions to set them!**

**strings**
Header.caption
: The text that the header displays

**booleans**
Header.alignment
: The GUI.Alignment that the caption of the header should have. Can use the bitwise `|` operator to pass a vertical and horizontal alignment at the same time

**objects**
Header.tree
: The tree that this header is associated with

### Functions
name, z, x, y, w, h, )
**Creation**
Header:new(*string* name, *int* z, *int* x, *int* y, *int* w, *int* h, *string* caption, *int* alignment, *GUI.Tree* tree, *GUI.Font* text_font, *GUI.Font* symbol_font, *GUI.Color* color, *GUI.Color* bg)
: Used to create a new Header. Assigns the header name to "name" and the other parameters to their defaults, unless a table is passed as the second element with the keys being the various parameters.

**Setters**
 Header:setalignment(*int* alignment)
: Sets the alignment for the caption.

Header:setcaption(*string* caption)
: Sets the text to the provided caption.

**Signals**
The Header class has access to all normal signals/"on" functions that the usual GUI class have access to, including `ondoubleclick`, `onmousedown`, etc. It does make use of `onmouseup` to control sorting of the tree, however, so be careful if you reimplement that function.





# Other Things
This script comes with some other useful functions, or tables with set values that mean something to the classes.

## Functions
*string* = GUI.EscapeString(*string* str)
: Returns a string with all special characters escaped.

*table* = GUI.ExpandTable(*table* table1, *table* table2, *optional boolean* is_reverse)
: Combines table1 and table2 into a new table. If `is_reverse` is set to true, table2 will be added in reverse order.

*int* = GUI.CheckInTable(*table* table1, *object* object)
: Checks to see if the object is in the table. This is a shallow scan, and not a deep search. Returns the index of the object if it is in the table, otherwise 0.

*boolean* = GUI.IsTreeItem(*object* object)
: Checks if the passed object is a TreeItem.

## Symbols
Various symbols, such as the expanded/collapsed symbol or the sorting symbols, can be changed if you assign them before creating the tree or headers. They all take string values.

GUI.Tree.indent
: The indent of each TreeItem depth, defaults to 4 spaces
GUI.Tree.expanded_symbol
: The symbol you want the parent item to have when expanded, defaults to "▼"
GUI.Tree.collapsed_symbol
: The symbol you want the parent item to have when collapsed, defaults to "►"

GUI.Header.ascending_symbol
: The symbol for when the tree is in an ascending sort mode, defaults to "▲"	
GUI.Header.descending_symbol
: The symbol for when the tree is in a descending sort mode, defaults to "▼"

## Tables
```
GUI.ClampMode = {
    none = 0,
    force = 1,
    ignore = 2,
}
```
: Controls how the index of an item in the list is figured out

```
GUI.AlignMode = {
    left = 0,
    horizontal = 1,
    right = 2,

top = 4,
    center = 8,
    bottom = 16,
    ignore = 256,
}
: Controls position of the text - can be combined with | operator

```
GUI.SelectionMode = {
    row = 1,		--selecting anywhere on the row selects the item
    text = 2,		--only selecting the text selects the item
    text_space = 3,	--selecting the text or empty space to the left selects the item
}
: Controls where you need to click within the tree in order to select an item

```
GUI.SortMode = {
    ascending = 1,	--a -> z, 1 -> 10
    descending = 2, --z -> a, 10 -> 1
    ignore = 3,		--don't sort unless specifically told to in script
}
```
: Controls the order that the Tree is sorts with
