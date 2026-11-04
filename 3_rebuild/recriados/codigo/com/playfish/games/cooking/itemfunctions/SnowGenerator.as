package com.playfish.games.cooking.itemfunctions
{
   import com.playfish.games.cooking.RoomItem;

   // Recriado (2026-10-26): o mesmo gerador serve a funcao nova "PetalGenerator" (Cherry Blossom Tree),
   // com param2 = true. A neve da Snow Machine continua igual (param2 = false).
   public class SnowGenerator extends RoomEffectGenerator
   {

      private static const MAX_SNOW_ON_SCREEN:int = 6;

      // 2026-10-28: 13 -> 15, a pedido da dona
      private static const MAX_PETALS_ON_SCREEN:int = 15;

      private var petals:Boolean;

      // 2026-11-03: efeitos de julho/2010 com a arte deles. param3 = {simbolos:[...], modo:"cai"|"petala"|"sobe",
      // max:int, velMin, velMax}; ver RoomSnowEffectObject. Sem param3, neve e petalas como antes.
      private var cfg:Object;

      public function SnowGenerator(param1:RoomItem, param2:Boolean = false, param3:Object = null)
      {
         super(param1,param3 != null ? int(param3.max) : (param2 ? MAX_PETALS_ON_SCREEN : MAX_SNOW_ON_SCREEN));
         this.petals = param2;
         this.cfg = param3;
      }

      override public function createEffectObject(param1:int, param2:int) : EffectObject
      {
         return new RoomSnowEffectObject(param1,param2,this.petals,this.cfg);
      }
   }
}
