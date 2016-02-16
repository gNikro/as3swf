package com.codeazur.as3swf.data
{
	import com.codeazur.as3swf.SWFData;
	import com.codeazur.as3swf.exporters.core.IShapeExporter;
	
	import com.codeazur.utils.StringUtils;
	
	public class SWFShapeWithStyle extends SWFShape
	{
		protected var _initialFillStyles:Vector.<SWFFillStyle>;
		protected var _initialLineStyles:Vector.<SWFLineStyle>;
		
		public function SWFShapeWithStyle(data:SWFData = null, level:int = 1, unitDivisor:Number = 20) {
			_initialFillStyles = new Vector.<SWFFillStyle>();
			_initialLineStyles = new Vector.<SWFLineStyle>();
			super(data, level, unitDivisor);
		}
		
		override public function clear():void 
		{
			super.clear();
			
			var i:int;
			for (i = 0; i < _initialFillStyles.length; i++)
			{
				_initialFillStyles[i].clear();
			}
			
			for (i = 0; i < _initialLineStyles.length; i++)
			{
				_initialLineStyles[i].clear();
			}
			
			_initialFillStyles = null;
			_initialLineStyles = null;
		}
		
		public function get initialFillStyles():Vector.<SWFFillStyle> { return _initialFillStyles; }
		public function get initialLineStyles():Vector.<SWFLineStyle> { return _initialLineStyles; }
		
		override public function parse(data:SWFData, level:int = 1):void {
			data.resetBitsPending();
			var i:int;
			var fillStylesLen:int = readStyleArrayLength(data, level);
			for (i = 0; i < fillStylesLen; i++) {
				initialFillStyles.push(data.readFILLSTYLE(level));
			}
			var lineStylesLen:int = readStyleArrayLength(data, level);
			for (i = 0; i < lineStylesLen; i++) {
				initialLineStyles.push(level <= 3 ? data.readLINESTYLE(level) : data.readLINESTYLE2(level));
			}
			data.resetBitsPending();
			var numFillBits:int = data.readUB(4);
			var numLineBits:int = data.readUB(4);
			readShapeRecords(data, numFillBits, numLineBits, level);
		}
		
		override public function publish(data:SWFData, level:int = 1):void {
			data.resetBitsPending();
			var i:int;
			var fillStylesLen:int = initialFillStyles.length;
			writeStyleArrayLength(data, fillStylesLen, level);
			for (i = 0; i < fillStylesLen; i++) {
				initialFillStyles[i].publish(data, level);
			}
			var lineStylesLen:int = initialLineStyles.length;
			writeStyleArrayLength(data, lineStylesLen, level);
			for (i = 0; i < lineStylesLen; i++) {
				initialLineStyles[i].publish(data, level);
			}
			var fillBits:int = data.calculateMaxBits(false, [getMaxFillStyleIndex()]);
			var lineBits:int = data.calculateMaxBits(false, [getMaxLineStyleIndex()]);
			data.resetBitsPending();
			data.writeUB(4, fillBits);
			data.writeUB(4, lineBits);
			writeShapeRecords(data, fillBits, lineBits, level);
		}
				
		override public function export(handler:IShapeExporter = null):void {
			_fillStyles = _initialFillStyles.concat();
			_lineStyles = _initialLineStyles.concat();
			super.export(handler);
		}

		override public function toString(indent:int = 0):String {
			var i:int;
			var str:String = "";
			if (_initialFillStyles.length > 0) {
				str += "\n" + StringUtils.repeat(indent) + "FillStyles:";
				for (i = 0; i < _initialFillStyles.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 2) + "[" + (i + 1) + "] " + _initialFillStyles[i].toString();
				}
			}
			if (_initialLineStyles.length > 0) {
				str += "\n" + StringUtils.repeat(indent) + "LineStyles:";
				for (i = 0; i < _initialLineStyles.length; i++) {
					str += "\n" + StringUtils.repeat(indent + 2) + "[" + (i + 1) + "] " + _initialLineStyles[i].toString();
				}
			}
			return str + super.toString(indent);
		}
		

		
		protected function readStyleArrayLength(data:SWFData, level:int = 1):int {
			var len:int = data.readUI8();
			if (level >= 2 && len == 0xff) {
				len = data.readUI16();
			}
			return len;
		}
		
		protected function writeStyleArrayLength(data:SWFData, length:int, level:int = 1):void {
			if (level >= 2 && length > 0xfe) {
				data.writeUI8(0xff);
				data.writeUI16(length);
			} else {
				data.writeUI8(length);
			}
		}
	}
}
