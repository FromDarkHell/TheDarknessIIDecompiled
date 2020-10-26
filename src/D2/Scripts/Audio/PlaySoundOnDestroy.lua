destroyedAudio = Resource()
function PlaySoundOnDestroy(instigator)
  Sleep(0)
  local decoHealth = instigator:GetHealth()
  if decoHealth <= 0 then
    instigator:PlaySound(destroyedAudio, false)
  end
end
