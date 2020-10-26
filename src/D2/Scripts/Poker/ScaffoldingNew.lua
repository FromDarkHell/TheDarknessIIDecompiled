effects = {
  Type()
}
scaffoldMesh = Instance()
effectSpawnLocation = Instance()
objectSpawner = Instance()
function Collapse()
  local position = scaffoldMesh:GetPosition()
  local rotation = scaffoldMesh:GetRotation()
  for i = 1, #effects do
    gRegion:CreateEntity(effects[i], position, rotation)
  end
  scaffoldMesh:Destroy()
  objectSpawner:FirePort("Disable")
  objectSpawner:FirePort("Hide")
end
