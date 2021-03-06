local CONFIRMTYPE_INVALID = -1
local CONFIRMTYPE_OKCANCEL = 0
local OKCANCEL_LEFT = 1
local OKCANCEL_RIGHT = 2
local confirmType = CONFIRMTYPE_INVALID
local optionList = {" ", " "}
function Initialize(movie)
  optionList = {" "}
end
function SetDescriptionText(movie, locTag)
  movie:SetLocalized("ItemDescription.text", locTag)
end
local function _SetItemText(movie, index, text)
  FlashMethod(movie, "SetItemText", index, text)
  optionList[index] = text
end
function SetItemText(movie, index, text)
  _SetItemText(movie, index, text)
end
function SetItemTextL(movie, text)
  if confirmType == CONFIRMTYPE_OKCANCEL then
    _SetItemText(movie, OKCANCEL_LEFT, text)
  end
end
function SetItemTextR(movie, text)
  if confirmType == CONFIRMTYPE_OKCANCEL then
    _SetItemText(movie, OKCANCEL_RIGHT, text)
  end
end
local _SetCallback = function(movie, args)
  movie:SetVariable("_root.scriptCallback", args)
end
function SetCallback(movie, args)
  _SetCallback(movie, args)
end
function CreateOkCancel(movie)
  confirmType = CONFIRMTYPE_OKCANCEL
  _SetItemText(movie, OKCANCEL_LEFT, "/EE_Menus/Confirm_Item_Ok")
  _SetItemText(movie, OKCANCEL_RIGHT, "/EE_Menus/Confirm_Item_Cancel")
  _SetCallback(movie, "ConfirmCallback")
  movie:SetFocus("ItemL")
end
local NotifyCallback = function(movie, selection)
  local parentMovie = movie:GetParent()
  local scriptCallback = movie:GetVariable("_root.scriptCallback")
  parentMovie:Execute(scriptCallback, selection)
  movie:Close()
end
function ItemL_onPress(movie)
  if confirmType == CONFIRMTYPE_OKCANCEL then
    NotifyCallback(movie, optionList[OKCANCEL_LEFT])
  end
end
function ItemR_onPress(movie)
  if confirmType == CONFIRMTYPE_OKCANCEL then
    movie:Close()
  end
end
function onKeyDown_MENU_SELECT(movie)
end
function onKeyDown_MENU_CANCEL(movie)
  if confirmType == CONFIRMTYPE_OKCANCEL then
    NotifyCallback(movie, optionList[OKCANCEL_RIGHT])
  end
end
