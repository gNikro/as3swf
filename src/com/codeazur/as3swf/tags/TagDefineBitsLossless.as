package com.codeazur.as3swf.tags
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.data.consts.BitmapFormat;
	import flash.display.BitmapData;
	
	import flash.utils.ByteArray;
	
	public class TagDefineBitsLossless implements IBitmapTag
	{
		public static const TYPE:uint = 20;
		
		public var bitmapFormat:uint;
		public var bitmapWidth:uint;
		public var bitmapHeight:uint;
		public var bitmapColorTableSize:uint;
		
		protected var _characterId:uint;
		
		private var _bitmapData:BitmapData;
		protected var _zlibBitmapData:ByteArray;
		
		public function TagDefineBitsLossless() {
			_zlibBitmapData = new ByteArray();
		}
		
		public function clear():void 
		{
			_zlibBitmapData.clear();
			_zlibBitmapData = null;
		}
		
		public function get characterId():uint { return _characterId; }
		public function set characterId(value:uint):void { _characterId = value; }
		
		public function get completeBitmapData():BitmapData { return _bitmapData; }
		public function get bitmapData():ByteArray { return _zlibBitmapData; }
		public function get bitmapAlphaData():ByteArray { return null; }
		
		protected function createBitmapData(width:Number, height:Number):BitmapData
		{
			return new BitmapData(bitmapWidth, bitmapHeight, false, 0x0);
		}
		
		public function parse(data:SWFData, length:uint, version:uint, async:Boolean = false):void
		{
			_characterId = data.readUI16();
			bitmapFormat = data.readUI8();
			bitmapWidth = data.readUI16();
			bitmapHeight = data.readUI16();
			
			if (bitmapFormat == BitmapFormat.BIT_8) 
			{
				bitmapColorTableSize = data.readUI8() + 1;
			}
			
			data.readBytes(_zlibBitmapData, 0, length - ((bitmapFormat == BitmapFormat.BIT_8) ? 8 : 7));
			_zlibBitmapData.uncompress();
			_zlibBitmapData.position = 0;
			
			var bitmapPixels:Vector.<uint> = new Vector.<uint>(bitmapWidth * bitmapHeight, true); 
			_bitmapData = createBitmapData(bitmapWidth, bitmapHeight);
			
			var pixelReadFunction:Function;
			
			//if (bitmapFormat == 4)
			//	pixelReadFunction = readColor15;
			//else
			if (bitmapFormat == 5)
				pixelReadFunction = readColor24;
			else
				throw new Error("Unknow or not implemented BitmapData format"); //TODO: 3 and 4 format
			
			var c:int = 0;
			for (var j:int = 0; j < bitmapHeight; j++)
			{
				for (var i:int = 0; i < bitmapWidth; i++)
				{
					bitmapPixels[c++] = pixelReadFunction(_zlibBitmapData);
				}
			}
			
			_bitmapData.setVector(_bitmapData.rect, bitmapPixels);
		}
		
		private function readColor8():void
		{
			
		}
		
		private function readColor15(data:ByteArray):uint
		{
			//var padding:uint = data.readUB(1);
			//var r:uint = data.readUB(5);
			//var g:uint = data.readUB(5);
			//var b:uint = data.readUB(5);
			
			//return ((r << 16) | (g << 8) | b);
			
			return 0;
		}
		
		protected function readColor24(data:ByteArray):uint
		{
			var padding:uint = data.readUnsignedByte();
			var r:uint = data.readUnsignedByte();
			var g:uint = data.readUnsignedByte();
			var b:uint = data.readUnsignedByte();
			
			return ((r << 16) | (g << 8) | b);
		}
		
		public function publish(data:SWFData, version:uint):void
		{
			var body:SWFData = new SWFData();
			body.writeUI16(_characterId);
			body.writeUI8(bitmapFormat);
			body.writeUI16(bitmapWidth);
			body.writeUI16(bitmapHeight);
			if (bitmapFormat == BitmapFormat.BIT_8) {
				body.writeUI8(bitmapColorTableSize);
			}
			if (_zlibBitmapData.length > 0) {
				body.writeBytes(_zlibBitmapData);
			}
			data.writeTagHeader(type, body.length, true);
			data.writeBytes(body);
		}
		
		public function clone():IDefinitionTag {
			var tag:TagDefineBitsLossless = new TagDefineBitsLossless();
			tag.characterId = characterId;
			tag.bitmapFormat = bitmapFormat;
			tag.bitmapWidth = bitmapWidth;
			tag.bitmapHeight = bitmapHeight;
			if (_zlibBitmapData.length > 0) {
				tag._zlibBitmapData.writeBytes(_zlibBitmapData);
			}
			return tag;
		}
		
		public function get type():uint { return TYPE; }
		public function get name():String { return "DefineBitsLossless"; }
		public function get version():uint { return 2; }
		public function get level():uint { return 1; }
		
		public function toString(indent:uint = 0, flags:uint = 0):String {
			return Tag.toStringCommon(type, name, indent) +
				"ID: " + characterId + ", " +
				"Format: " + BitmapFormat.toString(bitmapFormat) + ", " +
				"Size: (" + bitmapWidth + "," + bitmapHeight + ")";
		}
	}
}
