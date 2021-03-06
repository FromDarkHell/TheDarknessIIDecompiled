target = Instance()
particleSysTypes = {
  Type()
}
function EnableAttachments()
  local particleSys
  for i = 1, #particleSysTypes do
    particleSys = target:GetAllAttachments(particleSysTypes[i])
    for j = 1, #particleSys do
      particleSys[j]:FirePort("Enable")
    end
  end
end
function DisableAttachments()
  local particleSys
  for i = 1, #particleSysTypes do
    particleSys = target:GetAllAttachments(particleSysTypes[i])
    for j = 1, #particleSys do
      particleSys[j]:FirePort("Disable")
    end
  end
end
