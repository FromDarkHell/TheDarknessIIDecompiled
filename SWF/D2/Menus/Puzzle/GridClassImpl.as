class GridClassImpl
{
   var DEFAULT_DIMENSION = 20;
   var INVALID_DIMENSION = -1;
   var mIsEnabled = true;
   var mSelectedX = -1;
   var mSelectedY = -1;
   var mItemOffsetX = 0;
   var mItemOffsetY = 0;
   var mItemSpacingX = 0;
   var mItemSpacingY = 0;
   var mItemWidth = 0;
   var mItemHeight = 0;
   var mDimensionX = GridClassImpl.prototype.DEFAULT_DIMENSION;
   var mDimensionY = GridClassImpl.prototype.DEFAULT_DIMENSION;
   var mClipDimensionX = GridClassImpl.prototype.INVALID_DIMENSION;
   var mClipDimensionY = GridClassImpl.prototype.INVALID_DIMENSION;
   var mEnablePressedAnim = false;
   var mSelectedCallback = "";
   var mUnselectedCallback = "";
   var mPressedCallback = "";
   static var ACTIVE_INDEX = 0;
   function GridClassImpl(mc)
   {
      this.thisMC = mc;
      this.thisMC.Previewer._visible = false;
      this.mIdentifier = GridClassImpl.ACTIVE_INDEX * 1000;
      GridClassImpl.ACTIVE_INDEX = GridClassImpl.ACTIVE_INDEX + 1;
   }
   function SetEnabled(isEnabled)
   {
      this.mIsEnabled = isEnabled;
      var _loc4_ = 0;
      while(_loc4_ < this.mDimensionY)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.mDimensionX)
         {
            var _loc3_ = this.GetMovieClip(_loc2_,_loc4_);
            _loc3_.enabled = isEnabled;
            _loc2_ = _loc2_ + 1;
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   function SetDimensions(x, y)
   {
      this.mDimensionX = x;
      this.mDimensionY = y;
   }
   function SetClipDimensions(cx, cy)
   {
      this.mClipDimensionX = cx;
      this.mClipDimensionY = cy;
   }
   function GetIndex(x, y)
   {
      return y * this.mDimensionX + x;
   }
   function GetMovieName(gx, gy)
   {
      var _loc2_ = this.thisMC._name + "_Item" + gx + "x" + gy;
      return _loc2_;
   }
   function GetMovieClip(gx, gy)
   {
      var _loc3_ = this.GetMovieName(gx,gy);
      return _root[_loc3_];
   }
   function IsMCValid(mc)
   {
      if(mc != null && mc != undefined)
      {
         return true;
      }
      return false;
   }
   function SetVisible(v)
   {
      var _loc3_ = 0;
      while(_loc3_ < this.mDimensionY)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.mDimensionX)
         {
            this.SetItemVisible(_loc2_,_loc3_,v);
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function SetItemVisible(gx, gy, v)
   {
      var _loc2_ = this.GetMovieClip(gx,gy);
      if(this.IsMCValid(_loc2_))
      {
         _loc2_._visible = v;
      }
   }
   function ItemGotoAndPlay(gx, gy, m)
   {
      var _loc2_ = this.GetMovieClip(gx,gy);
      if(this.IsMCValid(_loc2_))
      {
         _loc2_.gotoAndPlay(m);
      }
   }
   function ItemGotoAndStop(gx, gy, m)
   {
      var _loc2_ = this.GetMovieClip(gx,gy);
      if(this.IsMCValid(_loc2_))
      {
         _loc2_.gotoAndStop(m);
      }
   }
   function UpdateItemPos(gx, gy)
   {
      var _loc10_ = this.GetMovieClip(gx,gy);
      if(!this.IsMCValid(_loc10_))
      {
         return undefined;
      }
      var _loc12_ = _loc10_._width;
      var _loc11_ = _loc10_._height;
      if(this.mItemWidth != 0)
      {
         _loc12_ = this.mItemWidth;
      }
      if(this.mItemHeight != 0)
      {
         _loc11_ = this.mItemHeight;
      }
      var _loc4_ = this.thisMC._y;
      var _loc7_ = this.thisMC._x;
      var _loc6_ = gx - this.mItemOffsetX;
      while(_loc6_ < this.mDimensionX)
      {
         var _loc5_ = 0;
         if(this.mItemWidth == 0)
         {
            var _loc3_ = gy - this.mItemOffsetY;
            while(_loc3_ < this.mDimensionY)
            {
               var _loc2_ = this.GetMovieClip(_loc6_,_loc3_);
               if(_loc2_ != undefined && _loc2_ != null)
               {
                  if(_loc2_._width > _loc5_)
                  {
                     _loc5_ = _loc2_._width;
                  }
               }
               _loc3_ = _loc3_ + 1;
            }
         }
         else
         {
            _loc5_ = this.mItemWidth;
         }
         _loc4_ = this.thisMC._y;
         _loc3_ = gy - this.mItemOffsetY;
         while(_loc3_ < this.mDimensionY)
         {
            _loc2_ = this.GetMovieClip(_loc6_,_loc3_);
            _loc2_._x = _loc7_;
            _loc2_._y = _loc4_;
            if(_loc2_ == undefined || _loc2_ == null || this.mItemHeight != 0)
            {
               _loc4_ = _loc4_ + this.mItemHeight;
            }
            else
            {
               _loc4_ = _loc4_ + _loc2_._height;
            }
            _loc4_ = _loc4_ + this.mItemSpacingY;
            _loc3_ = _loc3_ + 1;
         }
         _loc7_ = _loc7_ + _loc5_;
         _loc7_ = _loc7_ + this.mItemSpacingX;
         _loc6_ = _loc6_ + 1;
      }
   }
   function IsItemInClipArea(x, y)
   {
      if(x >= this.mItemOffsetX && x < this.mItemOffsetX + this.mClipDimensionX && y >= this.mItemOffsetY && y < this.mItemOffsetY + this.mClipDimensionY)
      {
         return true;
      }
      return false;
   }
   function Scroll(dirX, dirY)
   {
      this.mItemOffsetX = this.mItemOffsetX + dirX;
      if(this.mItemOffsetX < 0)
      {
         this.mItemOffsetX = 0;
      }
      this.mItemOffsetY = this.mItemOffsetY + dirY;
      if(this.mItemOffsetY < 0)
      {
         this.mItemOffsetY = 0;
      }
      this.Update();
      var _loc4_ = 0;
      while(_loc4_ < this.mDimensionY)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.mDimensionX)
         {
            var _loc3_ = false;
            if(this.IsItemInClipArea(_loc2_,_loc4_))
            {
               _loc3_ = true;
            }
            this.SetItemVisible(_loc2_,_loc4_,_loc3_);
            _loc2_ = _loc2_ + 1;
         }
         _loc4_ = _loc4_ + 1;
      }
   }
   function ScrollX(x)
   {
      this.Scroll(x,0);
   }
   function ScrollY(y)
   {
      this.Scroll(0,y);
   }
   function Update()
   {
      var _loc2_ = this.mDimensionY;
      if(this.mClipDimensionY > 0)
      {
         _loc2_ = this.mClipDimensionY;
      }
      var _loc3_ = this.mDimensionX;
      if(this.mClipDimensionX > 0)
      {
         _loc3_ = this.mClipDimensionX;
      }
      this.UpdateItemPos(this.mItemOffsetX,this.mItemOffsetY);
   }
   function SetItemSpacing(sx, sy)
   {
      this.mItemSpacingX = sx;
      this.mItemSpacingY = sy;
      this.Update();
   }
   function SetItemDimensions(sx, sy)
   {
      this.mItemWidth = sx;
      this.mItemHeight = sy;
      this.Update();
   }
   function RemoveItem(gx, gy)
   {
      var _loc2_ = this.GetMovieClip(gx,gy);
      if(this.IsMCValid(_loc2_))
      {
         _loc2_.removeMovieClip();
         if(this.IsMCValid(_loc2_))
         {
            removeMovieClip(_loc2_);
         }
      }
   }
   function Clear()
   {
      var _loc3_ = 0;
      while(_loc3_ < this.mDimensionY)
      {
         var _loc2_ = 0;
         while(_loc2_ < this.mDimensionX)
         {
            this.RemoveItem(_loc2_,_loc3_);
            _loc2_ = _loc2_ + 1;
         }
         _loc3_ = _loc3_ + 1;
      }
   }
   function SetItem(gx, gy, templateMCName, update)
   {
      var _loc4_ = this.GetIndex(gx,gy);
      var _loc5_ = this.GetMovieName(gx,gy);
      duplicateMovieClip(_root[templateMCName]._name,_loc5_,16384 + (_loc4_ + this.mIdentifier));
      var _loc3_ = _root[_loc5_];
      _loc3_._visible = this.IsItemInClipArea(gx,gy);
      if(this.IsMCValid(_loc3_))
      {
      }
      this.UpdateItemPos(this.mItemOffsetX,this.mItemOffsetY);
      _loc3_.index = _loc4_;
      _loc3_.GridClass = this;
      _loc3_.onPress = function()
      {
         this.GridClass.Pressed(this);
      };
      _loc3_.onRollOver = function()
      {
         this.GridClass.Selected(this.index);
      };
      _loc3_.onRollOut = function()
      {
         this.GridClass.Unselected(this.index);
      };
      if(update == undefined || update)
      {
         this.Update();
      }
   }
   function SetCallbackPressed(c)
   {
      this.mPressedCallback = c;
   }
   function SetCallbackSelected(c)
   {
      this.mSelectedCallback = c;
   }
   function SetCallbackUnselected(c)
   {
      this.mUnselectedCallback = c;
   }
   function Selected(itemIdx)
   {
      if(this.mSelectedCallback != "")
      {
         getURL("FSCommand:" add this.mSelectedCallback,itemIdx);
      }
      var _loc4_ = itemIdx % this.mDimensionX;
      var _loc3_ = Math.floor(itemIdx / this.mDimensionX);
      this.mSelectedX = _loc4_;
      this.mSelectedY = _loc3_;
      var _loc5_ = this.GetMovieName(_loc4_,_loc3_);
      Selection.setFocus(_root[_loc5_]);
   }
   function Unselected(itemIdx)
   {
      if(this.mUnselectedCallback != "")
      {
         getURL("FSCommand:" add this.mUnselectedCallback,itemIdx);
      }
      this.mSelectedX = -1;
      this.mSelectedY = -1;
      Selection.setFocus("");
   }
   function Pressed(mc)
   {
      if(this.mEnablePressedAnim)
      {
         mc.gotoAndPlay("Pressed");
      }
      if(this.mPressedCallback != "")
      {
         getURL("FSCommand:" add this.mPressedCallback,mc.index);
      }
   }
}
