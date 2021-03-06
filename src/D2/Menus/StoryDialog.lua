function Initialize(movie)
  local gameRules = gRegion:GetGameRules()
  movie:SetLocalized("OkText.text", "/D2/Language/Menu/StoryDialog_OK")
  movie:SetFocus("OkText")
  gameRules:RequestPause()
end
function SetText(movie, locTag)
  movie:SetLocalized("DialogText.text", locTag)
end
function SetCallback(movie, args)
  movie:SetVariable("_root.scriptCallback", args)
end
local Ok = function(movie)
  local parentMovie = movie:GetParent()
  local scriptCallback = movie:GetVariable("_root.scriptCallback")
  if parentMovie ~= nil then
    parentMovie:Execute(scriptCallback, "Ok")
  end
  local gameRules = gRegion:GetGameRules()
  movie:Close()
  gameRules:RequestUnpause()
end
function Ok_onPress(movie)
  Ok(movie)
end
function onKeyDown_MENU_SELECT(movie)
  local platform = movie:GetVariable("$platform")
  if platform ~= "WINDOWS" then
    Ok(movie)
  end
end
