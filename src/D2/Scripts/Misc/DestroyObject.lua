objectType = Type()
positionHint = Instance()
function Start()
  local ent = gRegion:FindNearest(objectType, positionHint:GetPosition(), INF)
  ent:Destroy()
end
