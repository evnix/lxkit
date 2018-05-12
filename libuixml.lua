local ui = require "lui"
local XmlParser = require("XmlParser")
local inspect = require('inspect')


local libuixml = {}
libuixml.ui = ui
libuixml.App = {}
libuixml.elementMap = {}

local ret,err = libuixml.ui.Init();
if (not ret) then
  io.stderr:write(string.format("error initializing libui: %s", err));
  return 1;
end

libuixml.stringToBool = function (strBool,default)
  if strBool == "true" or strBool == true then
  	return true
  elseif strBool == "false" or strBool == false then 
  	return false
  else
  	return default
  end
end

libuixml.cleanNil = function (val)
  if val == nil  then
  	return "NILL"
  else
  	return val
  end
end



libuixml.drawChildren = function (xmlTree,parent)

	local children = {}
	for i,xmlNode in pairs(xmlTree.ChildNodes) do
   		if(xmlNode.Name == "Window") then
        	table.insert(children,libuixml.drawWindow(xmlNode,parent))
    	elseif xmlNode.Name == "Button" then
    		table.insert(children,libuixml.drawButton(xmlNode,parent))
    	elseif xmlNode.Name == "TextInput" then
    		table.insert(children,libuixml.drawTextInput(xmlNode,parent))
    	elseif xmlNode.Name == "VerticalBox" then
    		table.insert(children,libuixml.drawVerticalBox(xmlNode,parent))
    	end
	end

	return children
end

libuixml.drawWindow = function (window,parent)

    local title = window.Attributes.title
    local width = window.Attributes.width
    local height = window.Attributes.height
    local id = libuixml.cleanNil(window.Attributes.id)
    local hasMenubar = libuixml.stringToBool(window.Attributes.hasMenubar,false)
    windowObj = ui.NewWindow(title, width, height, hasMenubar)
	windowObj:Show()
	libuixml.elementMap[id] = windowObj

	local current = {}
	current.parent = parent
	current.type = 'Window'
	current.ref = windowObj
	current.children = libuixml.drawChildren(window,current)
	for i,child in pairs(current.children) do
		windowObj:SetChild(child.ref):Margined(true)
	end
	table.insert(current.children,child)
	return current
end


libuixml.drawVerticalBox = function (box,parent)

	local padded = libuixml.stringToBool(box.Attributes.padded,true)
	local id = libuixml.cleanNil(box.Attributes.id)
	local vbox = ui.NewVerticalBox():Padded(padded)
	libuixml.elementMap[id] = vbox
	local current = {}
	current.parent = parent
	current.type = 'VBox'
	current.ref = vbox
	current.children = libuixml.drawChildren(box,current)
	for i,child in pairs(current.children) do
		vbox:Append(child.ref,libuixml.stringToBool(child.stretchy,false))
	end
	table.insert(current.children,child)
	return current
end


libuixml.drawButton = function (button,parent)
    local text = button.Value
    local stretchy = button.Attributes.stretchy
    local id = libuixml.cleanNil(button.Attributes.id)

    local buttonObj = ui.NewButton(text)
    libuixml.elementMap[id] = buttonObj
    buttonObj:Show()

    local current = {}
	current.parent = parent
	current.type = 'Button'
	current.ref = buttonObj
	current.stretchy = stretchy
	return current
end

libuixml.drawTextInput = function (textInput,parent)
    local text = textInput.Value
    local stretchy = textInput.Attributes.stretchy
    local id = libuixml.cleanNil(textInput.Attributes.id)
    local readOnly = libuixml.stringToBool(textInput.Attributes.readOnly,false)
    local visible = libuixml.stringToBool(textInput.Attributes.visible,true)
    local enabled = libuixml.stringToBool(textInput.Attributes.enabled,true)
    local mode = textInput.Attributes.mode
	local textInputObj = nil

	if mode == "multiline" then
		textInputObj = ui.NewMultilineEntry(text)
	elseif mode =="search" then
		textInputObj = ui.NewSearchEntry(text)
	elseif mode=="password" then
		textInputObj = ui.NewPasswordEntry(text)
	else
     	textInputObj = ui.NewEntry(text)
 	end
    
    libuixml.elementMap[id] = textInputObj
    textInputObj:ReadOnly(readOnly)
    
	libuixml.setVisibleAndEnable(textInputObj,visible,enabled)

    local current = {}
	current.parent = parent
	current.type = 'TextInput'
	current.ref = textInputObj
	current.stretchy = stretchy
	return current
end

libuixml.getElementById = function(id)
	return libuixml.elementMap[id]
end

libuixml.setVisibleAndEnable = function (obj,visible,enabled)
    if visible then
    	obj:Show()
    else
    	obj:Hide()
    end
    
    if enabled then
    	obj:Enable()
    else
    	obj:Disable()
	end
end

libuixml.loadXML = function (xmlContents)
	local xmlTree=XmlParser:ParseXmlText(xmlContents)
	libuixml.App.children = {}
	libuixml.App.children = libuixml.drawChildren(xmlTree,libuixml.App)
	print(inspect((libuixml.App)))
	print(inspect(libuixml.elementMap))
end

libuixml.loadXMLFile = function (path)
	local file = io.open(path, "r")
	local xmlContents = file:read("*all")
	libuixml.loadXML(xmlContents)
end

libuixml.Main = function ()
	ui.Main();
end

return libuixml





