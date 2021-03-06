delay = 2
location = Instance()
sounds = {
  Resource()
}
ignoreMutex = false
function PlaySimpleSound()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  for i = 1, #sounds do
    if IsNull(location) == false then
      location:PlaySound(sounds[i], true)
    else
      player:PlaySound(sounds[i], true)
    end
    Sleep(delay + Random(0.5, 1))
  end
end
function PlayOnAgent(agent)
  local avatar = agent:GetAvatar()
  for i = 1, #sounds do
    avatar:PlaySound(sounds[i], true)
    Sleep(delay + Random(0.5, 1))
  end
end
function PlayRandomBark(agent)
  local avatar = agent:GetAvatar()
  if IsNull(_T.gBarkMutex) then
    _T.gBarkMutex = false
  end
  Sleep(delay)
  if ignoreMutex then
    avatar:PlaySpeech(sounds[math.random(1, #sounds)], true)
  elseif not _T.gBarkMutex then
    _T.gBarkMutex = true
    avatar:PlaySpeech(sounds[math.random(1, #sounds)], true)
    _T.gBarkMutex = false
  end
end
