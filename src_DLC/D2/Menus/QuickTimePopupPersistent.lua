local jennyEndMessage = "/D2/Language/Menu/QuickTimePopupJenny_Message"
local leftPillsMessage = "/D2/Language/Menu/QuickTimePopup_TakePills"
local rightPillsMessage = "/D2/Language/Menu/QuickTimePopup_RefusePills"
local leftEndingMessage = "/D2/Language/Menu/QuickTimePopup_Stay"
local rightEndingMessage = "/D2/Language/Menu/QuickTimePopup_Leave"
function Initialize(movie)
  _T.qteDecision = nil
  if _T.qtePopupMode == "BUTTONPRESS" then
    FlashMethod(movie, "SetDescription", jennyEndMessage)
  elseif _T.qtePopupMode == "ROOFDECISION" then
    FlashMethod(movie, "SetDecisionOptions", leftPillsMessage, rightPillsMessage)
  elseif _T.qtePopupMode == "ENDINGDECISION" then
    FlashMethod(movie, "SetDecisionOptions", leftEndingMessage, rightEndingMessage)
  end
end
function Update(movie)
end
function onKeyDown_LEAN_LEFT(movie)
  if _T.qtePopupMode == "BUTTONPRESS" then
    return true
  elseif _T.qtePopupMode == "ROOFDECISION" or _T.qtePopupMode == "ENDINGDECISION" then
    _T.qteDecision = "LEFT"
    movie:Close()
  end
end
function onKeyDown_LEAN_RIGHT(movie)
  if _T.qtePopupMode == "BUTTONPRESS" then
    return true
  elseif _T.qtePopupMode == "ROOFDECISION" or _T.qtePopupMode == "ENDINGDECISION" then
    _T.qteDecision = "RIGHT"
    movie:Close()
  end
end
function onKeyDown_PICKUP(movie)
  if _T.qtePopupMode == "BUTTONPRESS" then
    _T.qteDecision = true
    movie:Close()
  elseif _T.qtePopupMode == "ROOFDECISION" or _T.qtePopupMode == "ENDINGDECISION" then
    return true
  end
end
function onKeyDown_MENU_GENERIC1(movie)
  if _T.qtePopupMode == "BUTTONPRESS" then
    _T.qteDecision = true
    movie:Close()
  elseif _T.qtePopupMode == "ROOFDECISION" or _T.qtePopupMode == "ENDINGDECISION" then
    return true
  end
end
