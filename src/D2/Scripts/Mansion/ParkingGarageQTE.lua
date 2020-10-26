carHitCinematic = Instance()
carHitModifier = Instance()
carExplosionCinematic = Instance()
sedan = Instance()
function OnDamaged()
  _T.carDamaged = true
end
function RegisterSedan()
  _T.carDamaged = false
  if IsNull(sedan) == false then
    ObjectPortHandler(sedan, "OnDamaged")
  end
end
function CheckState()
  if _T.carDamaged == true then
    carExplosionCinematic:FirePort("StartPlaying")
  else
    carHitCinematic:FirePort("StartPlaying")
  end
end
