visible = false
hudMovie = WeakResource()
function SetWheelVisibility()
  local hudMovie = gFlashMgr:FindMovie(hudMovie)
  if visible == true then
    hudMovie:Execute("SetWeaponWheelVisible", "1")
  elseif visible == false then
    hudMovie:Execute("SetWeaponWheelVisible", "0")
  end
end
