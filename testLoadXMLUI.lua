local libuixml = require 'libuixml'


function blah(b,data)
	print(data)
end

libuixml.loadXMLFile(arg[1])
-- local btn1 = libuixml.getElementById('btn1')
-- btn1:Text("Click Here")
-- btn1:OnClicked(blah,"hi")
libuixml.Main()