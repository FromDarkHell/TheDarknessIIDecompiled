generatorTag = Symbol()
liftDoorActionType = WeakResource()
local destroyedGeneratorPositions = {
  Vector(),
  Vector(),
  Vector(),
  Vector()
}
local numDestroyedGenerators = 0
local failureTag = Symbol("FAILED")
function MatchDecorationDestructionEvent(player, deco)
  if not IsNull(deco) and deco:GetTag() == generatorTag then
    numDestroyedGenerators = numDestroyedGenerators + 1
    destroyedGeneratorPositions[numDestroyedGenerators] = deco:GetPosition()
  end
  return false
end
function MatchAttackEvent(scriptDamageData, player)
  local victim = scriptDamageData:GetVictim()
  if IsNull(victim) then
    return false
  end
  local victimPos = victim:GetPosition()
  local liftDoorActions = gRegion:FindAll(liftDoorActionType, victimPos, 0, 30)
  if #liftDoorActions == 0 then
    return false
  end
  local testPos = liftDoorActions[1]:GetPosition()
  for i = 1, numDestroyedGenerators do
    local dpos = destroyedGeneratorPositions[i] - testPos
    local dist = dpos.x * dpos.x + dpos.z * dpos.z
    if dist < 784 then
      return true
    end
  end
  local humans = gRegion:GetHumanPlayers()
  for i = 1, #humans do
    gChallengeMgr:NotifyTag(humans[i], failureTag)
  end
  return false
end
