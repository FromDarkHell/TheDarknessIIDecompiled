class StatusBarClassImpl
{
   var mAlignment = "right";
   var newMovieIndex = 0;
   var mFillerMC = null;
   var mReservedFillerID = 9999;
   function StatusBarClassImpl(mc)
   {
      this.thisMC = mc;
      this.mElements = new Array();
      this.mLabels = new Array();
      this.thisMC.StatusText._visible = false;
      this.mReservedFillerID = 1;
      this.newMovieIndex = this.mReservedFillerID;
      duplicateMovieClip(this.thisMC.StatusText,"StatusTextFiller",16384 + this.mReservedFillerID);
      this.mFillerMC = this.thisMC.StatusTextFiller;
      this.mFillerMC._visible = true;
      this.mFillerMC.onPress = function()
      {
      };
      this.mFillerMC.onRollOver = function()
      {
      };
      this.mFillerMC.onRollOut = function()
      {
      };
      this.UpdateList();
   }
   function ItemExists(c)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_] == c)
         {
            return true;
         }
         _loc2_ = _loc2_ + 1;
      }
      return false;
   }
   function GetMovieName(idx)
   {
      var _loc1_ = "SBCIItem" + idx;
      return _loc1_;
   }
   function AddItem(c)
   {
      var _loc3_ = this.GetMovieName(this.newMovieIndex);
      this.newMovieIndex = this.newMovieIndex + 1;
      if(this.newMovieIndex == this.mReservedFillerID)
      {
         this.newMovieIndex = this.mReservedFillerID + 1;
      }
      duplicateMovieClip(this.thisMC.StatusText,_loc3_,16384 + this.newMovieIndex);
      var _loc2_ = this.thisMC[_loc3_];
      _loc2_._visible = true;
      _loc2_.index = this.newMovieIndex - this.mReservedFillerID;
      _loc2_.Txt.text = c;
      _loc2_.Txt.autoSize = true;
      _loc2_.Txt.visible = true;
      _loc2_.onPress = function()
      {
      };
      _loc2_.onRollOver = function()
      {
      };
      _loc2_.onRollOut = function()
      {
      };
      this.mElements.push(_loc2_);
      this.UpdateList();
   }
   function SetItem(i, c, b)
   {
      this.mElements[i] = c;
      this.UpdateList();
   }
   function EraseItemByIndex(idx)
   {
      var _loc2_ = this.mElements[idx];
      this.mElements.splice(idx,1);
      removeMovieClip(_loc2_);
      this.UpdateList();
   }
   function EraseItemByName(s)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_].Txt.text == s)
         {
            this.EraseItemByIndex(_loc2_);
            break;
         }
         _loc2_ = _loc2_ + 1;
      }
   }
   function Clear()
   {
      this.mElements.length = 0;
      this.UpdateList();
   }
   function UpdateList()
   {
      var _loc4_ = this.thisMC.StatusText;
      var _loc5_ = 0;
      if(this.mAlignment == "right")
      {
         var _loc3_ = this.mElements.length - 1;
         var _loc2_ = _loc3_;
         while(_loc2_ >= 0)
         {
            if(_loc2_ < _loc3_)
            {
               this.mElements[_loc2_]._x = this.mElements[_loc2_ + 1]._x - this.mElements[_loc2_].Txt.textWidth;
            }
            else
            {
               this.mElements[_loc2_]._x = _loc4_._x + _loc4_._width - this.mElements[_loc3_].Txt.textWidth;
            }
            _loc2_ = _loc2_ - 1;
         }
         this.mFillerMC._visible = false;
      }
      else if(this.mAlignment == "left")
      {
         _loc2_ = 0;
         while(_loc2_ < this.mElements.length)
         {
            if(_loc2_ > 0)
            {
               this.mElements[_loc2_]._x = this.mElements[_loc2_ - 1]._x + this.mElements[_loc2_ - 1].Txt.textWidth;
            }
            this.mFillerMC._x = this.mElements[_loc2_]._x + this.mElements[_loc2_].Txt.textWidth;
            _loc2_ = _loc2_ + 1;
         }
      }
   }
}
