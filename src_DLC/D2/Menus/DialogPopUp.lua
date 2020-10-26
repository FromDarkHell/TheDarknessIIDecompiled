local LIB = require("D2.Menus.SharedLibrary")
movieHUDW = WeakResource()
sndView = Resource()
local mStyleTextTotal, mStyleTextSpacing, mBanner
local function _SetMessage(movie, msg)
  if msg ~= nil then
    LIB.StyleTextSet(movie, msg)
    gRegion:PlaySound(sndView, Vector(), false)
  end
  return true
end
function SetMessage(movie, msg)
  return _SetMessage(movie, msg)
end
function ShowBannerMessage(movie, message)
  mBanner.loc = message
  mBanner.state = mBanner.STATE_FadeIn
  LIB.BannerDisplay(movie, mBanner)
  movie:SetVariable("StyleText._visible", false)
end
function HideBannerMessage(movie)
  mBanner.state = mBanner.STATE_FadeOut
  LIB.BannerDisplay(movie, mBanner)
end
local _Close = function(movie)
  local hud = gFlashMgr:FindMovie(movieHUDW)
  if not IsNull(hud) then
    hud:Execute("SetAdaptiveTrainingVisible", 1)
  end
  movie:Close()
  return true
end
function Close(movie)
  _Close(movie)
end
function BannerFadeOutComplete(movie)
  _Close(movie)
end
function Initialize(movie)
  mBanner = LIB.BannerInitialize(movie)
  local hud = gFlashMgr:FindMovie(movieHUDW)
  if not IsNull(hud) then
    hud:Execute("SetAdaptiveTrainingVisible", 0)
  end
end
function SetTitle(movie, title)
  return true
end
