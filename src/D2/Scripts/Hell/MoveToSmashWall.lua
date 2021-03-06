waypoint = Instance()
runToWaypoint = true
smashAnim = Resource()
animLength = 3
delayBeforeSmash = 0.2
wallDeco = Instance()
wallDecoTypes = {
  Type()
}
bulldozeRadius = 0.5
function MoveToSmashWall(agent)
  agent:MoveTo(waypoint, runToWaypoint, false, true)
  agent:PlayAnimation(smashAnim, false)
  Sleep(delayBeforeSmash)
  if not IsNull(wallDeco) then
    wallDeco:Destroy()
  end
  Sleep(animLength - delayBeforeSmash)
  agent:StopScriptedMode()
end
function MoveToSmashWallInstant(agent)
  agent:MoveTo(waypoint, runToWaypoint, false, false)
  Sleep(delayBeforeSmash)
  if not IsNull(wallDeco) then
    wallDeco:Destroy()
  end
  agent:StopScriptedMode()
end
function BulldozeWall(agent)
  local destinationReached = false
  local avatar = agent:GetAvatar()
  local currentLocation = avatar:GetPosition()
  local player = gRegion:GetPlayerAvatar()
  local playerLocation = player:GetPosition()
  local currentDeco
  local wasStunned = false
  agent:MoveTo(waypoint, runToWaypoint, true, false)
  Sleep(delayBeforeSmash)
  while destinationReached == false and not IsNull(agent) do
    if avatar:HasPostureModifier(Engine.PM_STUN) or avatar:HasPostureModifier(Engine.PM_BLOCKING_ANIM) then
      wasStunned = true
      Sleep(0)
    else
      if wasStunned == true then
        agent:MoveTo(waypoint, runToWaypoint, true, false)
        wasStunned = false
      end
      currentLocation = avatar:GetPosition()
      playerLocation = player:GetPosition()
      for i = 1, #wallDecoTypes do
        currentDeco = gRegion:FindNearest(wallDecoTypes[i], currentLocation, bulldozeRadius)
        if not IsNull(currentDeco) then
          currentDeco:Destroy()
        end
      end
      if 1 > Distance(currentLocation, waypoint:GetPosition()) or Distance(currentLocation, playerLocation) < Distance(currentLocation, waypoint:GetPosition()) then
        agent:StopScriptedMode()
        return
      end
      Sleep(0)
    end
  end
  agent:StopScriptedMode()
end
