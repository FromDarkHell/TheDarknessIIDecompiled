objects = {
  Instance()
}
padding = {0}
delay = 0
animTarget = Instance()
animScene = Resource()
defaultAnim = Resource()
playSpeechOnObjects = false
replicate = true
audio = {
  Resource()
}
function PlayAudioOnObjects()
  Sleep(delay)
  if #objects > 0 then
    for k = 1, #audio do
      if IsNull(animTarget) == false and IsNull(animScene) == false then
        animTarget:LoopAnimation(animScene)
      end
      local wait = true
      for i = 1, #objects do
        if i < #objects then
          wait = false
        end
        if playSpeechOnObjects == true then
          objects[i]:PlaySpeech(audio[k], wait)
        else
          objects[i]:PlaySound(audio[k], wait, 1, replicate)
        end
      end
      if IsNull(animTarget) == false and IsNull(defaultAnim) == false then
        animTarget:LoopAnimation(defaultAnim)
      end
      if k <= #padding then
        Sleep(padding[k])
      else
        Sleep(0)
      end
    end
  else
    local playerAvatar = gRegion:GetLocalPlayer()
    if IsNull(playerAvatar) then
      return
    end
    for k = 1, #audio do
      playerAvatar:PlaySound(audio[k], true)
      if k <= #padding then
        Sleep(padding[k])
      else
        Sleep(0)
      end
    end
  end
end
