class Caurina.Transitions.PropertyInfoObj
{
   function PropertyInfoObj(p_valueStart, p_valueComplete, p_originalValueComplete, p_arrayIndex, p_extra, p_isSpecialProperty, p_modifierFunction, p_modifierParameters)
   {
      this.valueStart = p_valueStart;
      this.valueComplete = p_valueComplete;
      this.originalValueComplete = p_originalValueComplete;
      this.arrayIndex = p_arrayIndex;
      this.extra = p_extra;
      this.isSpecialProperty = p_isSpecialProperty;
      this.hasModifier = p_modifierFunction != undefined;
      this.modifierFunction = p_modifierFunction;
      this.modifierParameters = p_modifierParameters;
   }
   function clone()
   {
      var _loc2_ = new Caurina.Transitions.PropertyInfoObj(this.valueStart,this.valueComplete,this.originalValueComplete,this.arrayIndex,this.extra,this.isSpecialProperty,this.modifierFunction,this.modifierParameters);
      return _loc2_;
   }
   function toString()
   {
      var _loc2_ = "\n[PropertyInfoObj ";
      _loc2_ = _loc2_ + ("valueStart:" + String(this.valueStart));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("valueComplete:" + String(this.valueComplete));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("originalValueComplete:" + String(this.originalValueComplete));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("arrayIndex:" + String(this.arrayIndex));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("extra:" + String(this.extra));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("isSpecialProperty:" + String(this.isSpecialProperty));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("hasModifier:" + String(this.hasModifier));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("modifierFunction:" + String(this.modifierFunction));
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("modifierParameters:" + String(this.modifierParameters));
      _loc2_ = _loc2_ + "]\n";
      return _loc2_;
   }
}
