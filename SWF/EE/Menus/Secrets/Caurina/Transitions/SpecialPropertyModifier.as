class Caurina.Transitions.SpecialPropertyModifier
{
   function SpecialPropertyModifier(p_modifyFunction, p_getFunction)
   {
      this.modifyValues = p_modifyFunction;
      this.getValue = p_getFunction;
   }
   function toString()
   {
      var _loc2_ = "";
      _loc2_ = _loc2_ + "[SpecialPropertyModifier ";
      _loc2_ = _loc2_ + ("modifyValues:" + this.modifyValues.toString());
      _loc2_ = _loc2_ + ", ";
      _loc2_ = _loc2_ + ("getValue:" + this.getValue.toString());
      _loc2_ = _loc2_ + "]";
      return _loc2_;
   }
}
