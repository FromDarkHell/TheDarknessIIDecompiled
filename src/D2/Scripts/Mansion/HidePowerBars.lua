movieHUD = WeakResource()
function HidePowerBars()
  local flashInstance = gFlashMgr:FindMovie(movieHUD)
  if not IsNull(flashInstance) then
    flashInstance:SetVariable("BankedPower0._visible", false)
    flashInstance:SetVariable("BankedPower1._visible", false)
  end
end
