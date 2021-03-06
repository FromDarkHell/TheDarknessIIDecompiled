initialDelay = 0
animArray = {
  Resource()
}
soundArray = {
  Resource()
}
avatarType = Type()
positionHint = Instance()
targetDecoration = Instance()
faceTo = false
local SoundLoop = function(target)
  local playerAvatar = gRegion:GetPlayerAvatar()
  if not IsNull(target) and faceTo then
    target:FaceTo(playerAvatar:GetPosition())
  end
  for i = 1, #soundArray do
    if not IsNull(target) then
      if IsNull(animArray[i]) == false then
        target:PlayAnimation(animArray[i], false)
      end
      local agent = target:GetAgent()
      if not IsNull(agent) then
        agent:PlaySpeech(soundArray[i], true)
      else
        target:PlaySpeech(soundArray[i], true)
      end
    else
      return
    end
    Sleep(Random(0.25, 0.75))
  end
end
local function LocalPlaySound(agent)
  Sleep(initialDelay)
  local localPlayer = gRegion:GetLocalPlayer()
  while IsNull(localPlayer) do
    localPlayer = gRegion:GetLocalPlayer()
    Sleep(0.1)
  end
  local playerPosition = localPlayer:GetPosition()
  local targetAvatar
  if IsNull(agent) == false then
    targetAvatar = agent:GetAvatar()
  elseif IsNull(positionHint) == false then
    targetAvatar = gRegion:FindNearest(avatarType, positionHint:GetPosition(), INF)
  else
    targetAvatar = gRegion:FindNearest(avatarType, playerPosition, INF)
  end
  SoundLoop(targetAvatar)
end
function PlaySpeechOnAvatar()
  LocalPlaySound()
end
function PlaySpeechOnSpawnPoint(agent)
  LocalPlaySound(agent)
end
function PlaySpeechOnDeco()
  Sleep(initialDelay)
  for i = 1, #soundArray do
    if IsNull(animArray[i]) == false then
      targetDecoration:PlayAnimation(animArray[i], false)
    end
    targetDecoration:PlaySpeech(soundArray[i], true)
    Sleep(Random(0.25, 0.75))
  end
end
