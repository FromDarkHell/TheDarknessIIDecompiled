lifespan = 3
function KillMe(toBeKilled)
  if not IsNull(toBeKilled) then
    Sleep(lifespan)
    toBeKilled:Destroy()
  end
end
