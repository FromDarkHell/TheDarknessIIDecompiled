typeToDestroy = Type()
position = Vector()
referenceObject = Instance()
minDistance = 0
maxDistance = 50
function DestroyType()
  local objects = {}
  if not IsNull(referenceObject) then
    position = referenceObject:GetPosition()
  end
  objects = gRegion:FindAll(typeToDestroy, position, minDistance, maxDistance)
  if IsNull(objects) then
    return
  end
  for i = 1, #objects do
    objects[i]:Destroy()
  end
end
