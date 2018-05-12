local libuixml = require 'libuixml'


function blah(b,data)
	print(data)
end

libuixml.loadXMLFile("test.xml")
local btn1 = libuixml.getElementById('btn1')
btn1:Text("Click Here")
btn1:OnClicked(blah,"hi")
libuixml.Main()