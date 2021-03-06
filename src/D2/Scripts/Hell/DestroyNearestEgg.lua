eggDecorationTypes = {
  Type()
}
lookTrigger = Instance()
npcSpawnControllerType = Type()
eggSound = Resource()
function DestroyNearestEgg()
  if IsNull(lookTrigger) == false then
    local origin = lookTrigger:GetPosition()
    local egg
    local i = 1
    for i = 1, #eggDecorationTypes do
      if IsNull(egg) then
        egg = gRegion:FindNearest(eggDecorationTypes[i], origin, 2)
      end
    end
    if IsNull(egg) == false then
      egg:PlaySound(eggSound, false)
      egg:FirePort("Destroy")
    end
  end
end
function EggDestroyed(instigator)
  Sleep(0)
  local origin = instigator:GetPosition()
  local spawn = gRegion:FindNearest(npcSpawnControllerType, origin, 1)
  if spawn ~= nil then
    local decoHealth = instigator:GetHealth()
    if decoHealth <= 0 then
      instigator:PlaySound(eggSound, false)
      spawn:FirePort("Start")
    end
  end
end
