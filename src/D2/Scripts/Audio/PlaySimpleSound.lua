delay = 0
sound = Resource()
function PlaySimpleSound()
  Sleep(delay)
  local player = gRegion:GetLocalPlayer()
  if not IsNull(player) then
    player:PlaySound(sound, false)
  end
end
function PlaySimpleSpeechOnAgent(agent)
  Sleep(delay)
  agent:PlaySpeech(sound, true)
end
