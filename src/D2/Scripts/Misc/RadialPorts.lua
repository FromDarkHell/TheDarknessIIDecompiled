searchType = Type()
origin = Instance()
portName = String()
searchRadius = 20
function Start()
  local ents = gRegion:FindAll(searchType, origin:GetPosition(), 0, searchRadius)
  for i = 1, #ents do
    ents[i]:FirePort(portName)
  end
end
