SirenEffect = Type()
function Siren(entity)
  while true do
    entity:Attach(SirenEffect, Symbol(), Vector(), Rotation())
    Sleep(0.62)
  end
end
