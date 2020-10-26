local LIB = require("D2.Menus.SharedLibrary")
local _UpdateCharacter = function(movie, character)
  character = tonumber(character)
  FlashMethod(movie, "Character.Frame.Image.gotoAndStop", character + 1)
end
function UpdateCharacter(movie, character)
  _UpdateCharacter(movie, character)
  return 1
end
local function _Show(movie, character)
  FlashMethod(movie, "Character.gotoAndPlay", "Show")
  _UpdateCharacter(movie, character)
end
function Show(movie, character)
  _Show(movie, character)
  return 1
end
local _Hide = function(movie)
  FlashMethod(movie, "Character.gotoAndPlay", "Hide")
end
function Hide(movie)
  _Hide(movie)
  return 1
end
function Initialize(movie)
end
