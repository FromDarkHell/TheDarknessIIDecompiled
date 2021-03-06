darklingAvatarType = Type()
shrineHitSwitch = Instance()
useOnTouched = false
shrineDanceAnim = Resource()
shrineWaypoint = Instance()
alignWithWaypoint = false
spawnTrigger = Instance()
darklingSoundPadding = 0.5
darklingSoundArray = {
  Resource()
}
function ForceTalentShrineDance()
  local avatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
  local agent, dmgController
  local playerAvatar = gRegion:GetPlayerAvatar()
  _T.switchActivated = false
  ObjectPortHandler(shrineHitSwitch, "OnActivated")
  ObjectPortHandler(shrineHitSwitch, "OnDestroyed")
  if useOnTouched == true then
    ObjectPortHandler(shrineHitSwitch, "OnTouched")
  end
  if IsNull(avatar) then
    spawnTrigger:FirePort("Activate")
    while IsNull(avatar) do
      avatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
      Sleep(0)
    end
  end
  agent = avatar:GetAgent()
  dmgController = avatar:DamageControl()
  dmgController:SetDamageMultiplier(0)
  agent:MoveTo(shrineWaypoint, true, alignWithWaypoint, true)
  while Distance(playerAvatar:GetPosition(), avatar:GetPosition()) > 15 do
    Sleep(0.5)
  end
  agent:LoopAnimation(shrineDanceAnim)
  if not IsNull(darklingSoundArray) then
    for i = 1, #darklingSoundArray do
      if _T.switchActivated == true then
        break
      end
      if not IsNull(avatar) then
        agent:PlaySpeech(darklingSoundArray[i], true)
        Sleep(darklingSoundPadding)
      end
    end
  end
  if not IsNull(avatar) then
    dmgController:SetDamageMultiplier(1)
  end
end
local StopDarklingDance = function()
  local avatar = gRegion:FindNearest(darklingAvatarType, Vector(), INF)
  local agent
  _T.switchActivated = true
  if not IsNull(avatar) then
    agent = avatar:GetAgent()
    agent:ClearScriptActions()
    agent:StopScriptedMode()
  end
end
function OnActivated(entity)
  StopDarklingDance()
end
function OnDestroyed(entity)
  StopDarklingDance()
end
function OnTouched(entity)
  if useOnTouched == true then
    StopDarklingDance()
  end
end
