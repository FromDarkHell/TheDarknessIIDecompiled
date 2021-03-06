sounds = {
  Resource()
}
location = {
  Instance()
}
agentName = {
  String()
}
agentAnims = {
  Resource()
}
delayBeforeSound = {0}
local StopScript = function()
  for i = 1, #agentName do
    local currentAgent = _T.agentArray[agentName[i]]
    currentAgent:StopScriptedMode()
  end
  return
end
function PlaySoundsInSequence()
  for i = 1, #sounds do
    if IsNull(delayBeforeSound[i]) then
      delayBeforeSound[i] = 0
    end
    Sleep(delayBeforeSound[i])
    if IsNull(agentName[i]) == false and IsNull(_T.agentArray) == false then
      if IsNull(_T.agentArray[agentName[i]]) == false then
        local currentAgent = _T.agentArray[agentName[i]]
        local currentAvatar = currentAgent:GetAvatar()
        if not currentAgent:IsAlerted() then
          if not IsNull(agentAnims[i]) then
            currentAvatar:PlayAnimation(agentAnims[i], false)
          end
          if not IsNull(sounds[i]) then
            currentAvatar:PlaySpeech(sounds[i], true)
          end
        else
          StopScript()
        end
      end
    elseif IsNull(location[i]) == false then
      location:PlaySound(sounds[i], true)
    else
      local player = gRegion:GetPlayerAvatar()
      player:PlaySound(sounds[i], true)
    end
  end
end
