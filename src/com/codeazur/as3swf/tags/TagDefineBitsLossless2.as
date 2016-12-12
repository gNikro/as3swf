package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.data.consts.BitmapFormat;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;

	public class TagDefineBitsLossless2 extends TagDefineBitsLossless implements IDefinitionTag
	{
		public static const TYPE:uint = 36;
		
		public function TagDefineBitsLossless2() {}
		
		override public function clone():IDefinitionTag {
			var tag:TagDefineBitsLossless2 = new TagDefineBitsLossless2();
			tag.characterId = characterId;
			tag.bitmapFormat = bitmapFormat;
			tag.bitmapWidth = bitmapWidth;
			tag.bitmapHeight = bitmapHeight;
			if (_zlibBitmapData.length > 0) {
				tag._zlibBitmapData.writeBytes(_zlibBitmapData);
			}
			return tag;
		}
		
		override protected function createBitmapData(width:Number, height:Number):BitmapData 
		{
			return new BitmapData(width, height, true, 0x0);
		}
		
		override protected function readColor24(data:ByteArray):uint 
		{
			var a:uint = data.readUnsignedByte();
			var r:uint = data.readUnsignedByte();
			var g:uint = data.readUnsignedByte();
			var b:uint = data.readUnsignedByte();
			
			return ((a << 24) | (r << 16) | (g << 8) | b);
		}
		
		override public function get type():uint { return TYPE; }
		override public function get name():String { return "DefineBitsLossless2"; }
		override public function get version():uint { return 3; }
		override public function get level():uint { return 2; }

		override public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Format: " + BitmapFormat.toString(bitmapFormat) + ", " +
				"Size: (" + bitmapWidth + "," + bitmapHeight + ")";
		}
	}
}
