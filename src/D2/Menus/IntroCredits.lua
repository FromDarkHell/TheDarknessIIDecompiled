local _DisplayText = function(movie, locStr)
  FlashMethod(movie, "Animation.gotoAndPlay", "FadeIn")
  movie:SetLocalized("Animation.TxtHolder.Text.text", locStr)
end
function DisplayText(movie, locStr)
  _DisplayText(movie, locStr)
end
function Initialize(movie)
end
function Shutdown(movie)
end
function Update(movie)
end
