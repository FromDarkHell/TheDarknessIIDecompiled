local skipMessage = "/D2/Language/SPGame/MonologueSkip_Windows"
function Initialize(movie)
  _T.skipContentPressed = false
  FlashMethod(movie, "SetDescription", skipMessage)
end
function Update(movie)
end
function onKeyDown_MENU_CANCEL(movie)
  _T.skipContentPressed = true
  movie:Close()
end
function onKeyDown_MENU_SELECT(movie)
  _T.skipContentPressed = true
  movie:Close()
end
