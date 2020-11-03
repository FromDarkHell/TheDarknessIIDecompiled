class StatusBarClassImpl
{
   var mAlignment = "right";
   var newMovieIndex = 0;
   var mReservedFillerID = 9999;
   var mSpacing = 15;
   var mCallbackOnPress = "";
   var mCallbackOnRollOver = "";
   var mCallbackOnRollOut = "";
   function StatusBarClassImpl(mc)
   {
      this.thisMC = mc;
      this.mElements = new Array();
      this.mLabels = new Array();
      this.thisMC.StatusText._visible = false;
      this.mReservedFillerID = 1;
      this.newMovieIndex = this.mReservedFillerID;
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
   function AddItem(c, enableEvents)
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
      _loc2_.statusClass = this;
      _loc2_.Txt.autoSize = true;
      _loc2_.Txt.text = c;
      _loc2_.Txt.visible = true;
      if(enableEvents)
      {
         _loc2_.onPress = function()
         {
            if(this.statusClass.mCallbackOnPress != "")
            {
               getURL("FSCommand:" add this.statusClass.mCallbackOnPress,this.index);
            }
         };
         _loc2_.onRollOver = function()
         {
            this._parent.ItemHighlighted._x = this._x + 3;
            this._parent.ItemHighlighted._width = this.Txt.textWidth;
            this._parent.ItemHighlighted._visible = true;
            if(this.statusClass.mCallbackOnRollOver != "")
            {
               getURL("FSCommand:" add this.statusClass.mCallbackOnRollOver,this.index);
            }
         };
         _loc2_.onRollOut = function()
         {
            this._parent.ItemHighlighted._visible = false;
            if(this.statusClass.mCallbackOnRollOut != "")
            {
               getURL("FSCommand:" add this.statusClass.mCallbackOnRollOut,this.index);
            }
         };
      }
      this.mElements.push(_loc2_);
      this.UpdateList();
   }
   function SetItem(idx, c)
   {
      this.mElements[idx] = c;
      this.UpdateList();
   }
   function FindItemIndexByName(s)
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_].Txt.text == s)
         {
            return _loc2_;
         }
         _loc2_ = _loc2_ + 1;
      }
      return -1;
   }
   function SetItemVisibleByIndex(idx, vis)
   {
      this.mElements[idx]._visible = vis;
      this.UpdateList();
   }
   function SetItemVisibleByName(s, vis)
   {
      var _loc2_ = this.FindItemIndexByName(s);
      this.mElements[_loc2_]._visible = vis;
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
      var _loc2_ = this.FindItemIndexByName(s);
      this.EraseItemByIndex(_loc2_);
   }
   function Clear()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.mElements.length)
      {
         if(this.mElements[_loc2_])
         {
            this.mElements[_loc2_].removeMovieClip();
         }
         _loc2_ = _loc2_ + 1;
      }
      this.mElements.splice(0);
      this.mElements.length = 0;
      this.newMovieIndex = this.mReservedFillerID;
      this.UpdateList();
   }
   function UpdateList()
   {
      this.thisMC.ItemHighlighted._visible = false;
      var _loc5_ = this.thisMC.StatusText;
      var _loc6_ = 0;
      if(this.mAlignment == "right")
      {
         var _loc4_ = _loc5_._x + _loc5_._width;
         var _loc3_ = this.mElements.length - 1;
         var _loc2_ = _loc3_;
         while(_loc2_ >= 0)
         {
            this.mElements[_loc2_].index = _loc2_;
            if(this.mElements[_loc2_]._visible)
            {
               if(_loc2_ < _loc3_)
               {
                  this.mElements[_loc2_]._x = _loc4_ - this.mElements[_loc2_].Txt.textWidth - this.mSpacing;
               }
               else
               {
                  this.mElements[_loc2_]._x = _loc4_ - this.mElements[_loc3_].Txt.textWidth - this.mSpacing;
               }
               _loc4_ = this.mElements[_loc2_]._x;
            }
            _loc2_ = _loc2_ - 1;
         }
      }
      else if(this.mAlignment == "left")
      {
         _loc4_ = 0;
         _loc2_ = 0;
         while(_loc2_ < this.mElements.length)
         {
            this.mElements[_loc2_].index = _loc2_;
            if(this.mElements[_loc2_]._visible)
            {
               if(_loc2_ > 0)
               {
                  this.mElements[_loc2_]._x = _loc4_ + this.mElements[_loc2_ - 1].Txt.textWidth + this.mSpacing;
                  _loc4_ = this.mElements[_loc2_ - 1]._x;
               }
            }
            _loc2_ = _loc2_ + 1;
         }
      }
   }
   function SetAlignment(a)
   {
      this.mAlignment = a;
      this.UpdateList();
   }
   function SetCallbackOnPress(c)
   {
      this.mCallbackOnPress = c;
   }
   function SetCallbackOnRollOver(c)
   {
      this.mCallbackOnRollOver = c;
   }
   function SetCallbackOnRollOut(c)
   {
      this.mCallbackOnRollOut = c;
   }
   function SetSpacing(f)
   {
      this.mSpacing = f;
   }
   function SetVisible(b)
   {
      this.thisMC._visible = b;
   }
}
