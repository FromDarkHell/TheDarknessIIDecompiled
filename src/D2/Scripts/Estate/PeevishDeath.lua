deathFX = Type()
orbFX = Type()
orbPosition = Vector(0, 0, 0)
function DeathAttachment(deco)
  if not IsNull(deathFX) then
    local attachment = deco:Attach(deathFX, Symbol(), Vector(), Rotation())
  end
  local peevishPosition = deco:GetPosition()
  Sleep(3)
  if not IsNull(orbFX) then
    _T.peevishOrb = gRegion:CreateEntity(orbFX, peevishPosition + orbPosition, Rotation())
  end
end
function RemoveOrb()
  _T.peevishOrb:Destroy()
end
