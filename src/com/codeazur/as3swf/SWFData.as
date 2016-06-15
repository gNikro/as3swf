package com.codeazur.as3swf
{
	import com.codeazur.as3swf.data.*;
	import com.codeazur.as3swf.data.actions.IAction;
	import com.codeazur.as3swf.data.filters.*;
	import com.codeazur.as3swf.factories.*;
	import com.codeazur.utils.BitArray;
	import com.codeazur.utils.HalfPrecisionWriter;
	
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	
	public class SWFData extends BitArray
	{
		public static const FLOAT16_EXPONENT_BASE:Number = 15;
		
		public function SWFData() {
			endian = Endian.LITTLE_ENDIAN;
		}

		/////////////////////////////////////////////////////////
		// Integers
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readSI8():int {
			resetBitsPending();
			return readByte();
		}
		
		public function writeSI8(value:int):void {
			resetBitsPending();
			writeByte(value);
		}

		[Inline]
		public final function readSI16():int {
			resetBitsPending();
			return readShort();
		}
		
		public function writeSI16(value:int):void {
			resetBitsPending();
			writeShort(value);
		}

		[Inline]
		public final function readSI32():int {
			resetBitsPending();
			return readInt();
		}
		
		public function writeSI32(value:int):void {
			resetBitsPending();
			writeInt(value);
		}

		[Inline]
		public final function readUI8():uint {
			resetBitsPending();
			return readUnsignedByte();
		}
		
		public function writeUI8(value:uint):void {
			resetBitsPending();
			writeByte(value);
		}

		[Inline]
		public final function readUI16():uint {
			resetBitsPending();
			return readUnsignedShort();
		}
		
		public function writeUI16(value:uint):void {
			resetBitsPending();
			writeShort(value);
		}

		[Inline]
		public final function readUI24():uint {
			resetBitsPending();
			var loWord:uint = readUnsignedShort();
			var hiByte:uint = readUnsignedByte();
			return (hiByte << 16) | loWord;
		}
		
		public function writeUI24(value:uint):void {
			resetBitsPending();
			writeShort(value & 0xffff);
			writeByte(value >> 16);
		}
		
		[Inline]
		public final function readUI32():uint {
			resetBitsPending();
			return readUnsignedInt();
		}
		
		public function writeUI32(value:uint):void {
			resetBitsPending();
			writeUnsignedInt(value);
		}
		
		/////////////////////////////////////////////////////////
		// Fixed-point numbers
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readFIXED():Number {
			resetBitsPending();
			return readInt() / 65536;
		}
		
		public function writeFIXED(value:Number):void {
			resetBitsPending();
			writeInt(int(value * 65536));
		}

		[Inline]
		public final function readFIXED8():Number {
			resetBitsPending();
			return readShort() / 256;
		}

		public function writeFIXED8(value:Number):void {
			resetBitsPending();
			writeShort(int(value * 256));
		}

		/////////////////////////////////////////////////////////
		// Floating-point numbers
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readFLOAT():Number {
			resetBitsPending();
			return readFloat();
		}
		
		public function writeFLOAT(value:Number):void {
			resetBitsPending();
			writeFloat(value);
		}

		[Inline]
		public final function readDOUBLE():Number {
			resetBitsPending();
			return readDouble();
		}

		public function writeDOUBLE(value:Number):void {
			resetBitsPending();
			writeDouble(value);
		}

		[Inline]
		public final function readFLOAT16():Number {
			resetBitsPending();
			var word:uint = readUnsignedShort();
			var sign:int = ((word & 0x8000) != 0) ? -1 : 1;
			var exponent:uint = (word >> 10) & 0x1f;
			var significand:uint = word & 0x3ff;
			if (exponent == 0) {
				if (significand == 0) {
					return 0;
				} else {
					// subnormal number
					return sign * Math.pow(2, 1 - FLOAT16_EXPONENT_BASE) * (significand / 1024);
				}
			}
			if (exponent == 31) { 
				if (significand == 0) {
					return (sign < 0) ? Number.NEGATIVE_INFINITY : Number.POSITIVE_INFINITY;
				} else {
					return Number.NaN;
				}
			}
			// normal number
			return sign * Math.pow(2, exponent - FLOAT16_EXPONENT_BASE) * (1 + significand / 1024);
		}
		
		[Inline]
		public final function writeFLOAT16(value:Number):void {
			HalfPrecisionWriter.write(value, this);
		}

		/////////////////////////////////////////////////////////
		// Encoded integer
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readEncodedU32():uint {
			resetBitsPending();
			var result:uint = readUnsignedByte();
			if (result & 0x80) {
				result = (result & 0x7f) | (readUnsignedByte() << 7);
				if (result & 0x4000) {
					result = (result & 0x3fff) | (readUnsignedByte() << 14);
					if (result & 0x200000) {
						result = (result & 0x1fffff) | (readUnsignedByte() << 21);
						if (result & 0x10000000) {
							result = (result & 0xfffffff) | (readUnsignedByte() << 28);
						}
					}
				}
			}
			return result;
		}
		
		public function writeEncodedU32(value:uint):void {
			for (;;) {
				var v:uint = value & 0x7f;
				if ((value >>= 7) == 0) {
					writeUI8(v);
					break;
				}
				writeUI8(v | 0x80);
			}
		}

		/////////////////////////////////////////////////////////
		// Bit values
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readUB(bits:uint):uint {
			return readBits(bits);
		}

		public function writeUB(bits:uint, value:uint):void {
			writeBits(bits, value);
		}

		[Inline]
		public final function readSB(bits:uint):int {
			var shift:uint = 32 - bits;
			return int(readBits(bits) << shift) >> shift;
		}
		
		public function writeSB(bits:uint, value:int):void {
			writeBits(bits, value);
		}
		
		[Inline]
		public final function readFB(bits:uint):Number {
			return Number(readSB(bits)) / 65536;
		}
		
		public function writeFB(bits:uint, value:Number):void {
			writeSB(bits, value * 65536);
		}
		
		/////////////////////////////////////////////////////////
		// String
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readString():String {
			var index:uint = position;
			while (this[index++]) {}
			resetBitsPending();
			return readUTFBytes(index - position);
		}
		
		public function writeString(value:String):void {
			if (value && value.length > 0) {
				writeUTFBytes(value);
			}
			writeByte(0);
		}
		
		/////////////////////////////////////////////////////////
		// Labguage code
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readLANGCODE():uint {
			resetBitsPending();
			return readUnsignedByte();
		}
		
		public function writeLANGCODE(value:uint):void {
			resetBitsPending();
			writeByte(value);
		}
		
		/////////////////////////////////////////////////////////
		// Color records
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readRGB():uint {
			resetBitsPending();
			var r:uint = readUnsignedByte();
			var g:uint = readUnsignedByte();
			var b:uint = readUnsignedByte();
			return 0xff000000 | (r << 16) | (g << 8) | b;
		}
		
		public function writeRGB(value:uint):void {
			resetBitsPending();
			writeByte((value >> 16) & 0xff);
			writeByte((value >> 8) & 0xff);
			writeByte(value  & 0xff);
		}

		[Inline]
		public final function readRGBA():uint {
			resetBitsPending();
			var rgb:uint = readRGB() & 0x00ffffff;
			var a:uint = readUnsignedByte();
			return a << 24 | rgb;
		}
		
		public function writeRGBA(value:uint):void {
			resetBitsPending();
			writeRGB(value);
			writeByte((value >> 24) & 0xff);
		}

		[Inline]
		public final function readARGB():uint {
			resetBitsPending();
			var a:uint = readUnsignedByte();
			var rgb:uint = readRGB() & 0x00ffffff;
			return (a << 24) | rgb;
		}
		
		[Inline]
		public final function writeARGB(value:uint):void {
			resetBitsPending();
			writeByte((value >> 24) & 0xff);
			writeRGB(value);
		}

		/////////////////////////////////////////////////////////
		// Rectangle record
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readRECT():SWFRectangle {
			return new SWFRectangle(this);
		}
		
		public function writeRECT(value:SWFRectangle):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Matrix record
		/////////////////////////////////////////////////////////
		
		public function readMATRIX():SWFMatrix {
			return new SWFMatrix(this);
		}
		
		public function writeMATRIX(value:SWFMatrix):void {
			this.resetBitsPending();

			var hasScale:Boolean = (value.scaleX != 1) || (value.scaleY != 1);
			var hasRotate:Boolean = (value.rotateSkew0 != 0) || (value.rotateSkew1 != 0);
			
			writeBits(1, hasScale ? 1 : 0);
			if (hasScale) {
				var scaleBits:uint;
				if(value.scaleX == 0 && value.scaleY == 0) {
					scaleBits = 1;
				} else {
					scaleBits = calculateMaxBits(true, [value.scaleX * 65536, value.scaleY * 65536]);
				}
				writeUB(5, scaleBits);
				writeFB(scaleBits, value.scaleX);
				writeFB(scaleBits, value.scaleY);
			}
			
			writeBits(1, hasRotate ? 1 : 0);
			if (hasRotate) {
				var rotateBits:uint = calculateMaxBits(true, [value.rotateSkew0 * 65536, value.rotateSkew1 * 65536]);
				writeUB(5, rotateBits);
				writeFB(rotateBits, value.rotateSkew0);
				writeFB(rotateBits, value.rotateSkew1);
			}
			
			var translateBits:uint = calculateMaxBits(true, [value.translateX, value.translateY]);
			writeUB(5, translateBits);
			writeSB(translateBits, value.translateX);
			writeSB(translateBits, value.translateY);
		}

		/////////////////////////////////////////////////////////
		// Color transform records
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readCXFORM():SWFColorTransform {
			return new SWFColorTransform(this);
		}
		
		public function writeCXFORM(value:SWFColorTransform):void {
			value.publish(this);
		}

		[Inline]
		public final function readCXFORMWITHALPHA():SWFColorTransformWithAlpha {
			return new SWFColorTransformWithAlpha(this);
		}
		
		public function writeCXFORMWITHALPHA(value:SWFColorTransformWithAlpha):void {
			value.publish(this);
		}

		/////////////////////////////////////////////////////////
		// Shape and shape records
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readSHAPE(unitDivisor:Number):SWFShape {
			return new SWFShape(this, 1, unitDivisor);
		}
		
		public function writeSHAPE(value:SWFShape):void {
			value.publish(this);
		}
		
		[Inline]
		public final function readSHAPEWITHSTYLE(level:uint, unitDivisor:Number):SWFShapeWithStyle {
			return new SWFShapeWithStyle(this, level, unitDivisor);
		}

		public function writeSHAPEWITHSTYLE(value:SWFShapeWithStyle, level:uint):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readSTRAIGHTEDGERECORD(numBits:uint):SWFShapeRecordStraightEdge {
			return new SWFShapeRecordStraightEdge(this, numBits);
		}
		
		public function writeSTRAIGHTEDGERECORD(value:SWFShapeRecordStraightEdge):void {
			value.publish(this);
		}
		
		[Inline]
		public final function readCURVEDEDGERECORD(numBits:uint):SWFShapeRecordCurvedEdge {
			return new SWFShapeRecordCurvedEdge(this, numBits);
		}
		
		public function writeCURVEDEDGERECORD(value:SWFShapeRecordCurvedEdge):void {
			value.publish(this);
		}
		
		[Inline]
		public final function readSTYLECHANGERECORD(states:uint, fillBits:uint, lineBits:uint, level:uint):SWFShapeRecordStyleChange {
			return new SWFShapeRecordStyleChange(this, states, fillBits, lineBits, level);
		}
		
		public function writeSTYLECHANGERECORD(value:SWFShapeRecordStyleChange, fillBits:uint, lineBits:uint, level:uint = 1):void {
			value.numFillBits = fillBits;
			value.numLineBits = lineBits;
			value.publish(this, level);
		}
		

		/////////////////////////////////////////////////////////
		// Fill- and Linestyles
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readFILLSTYLE(level:uint):SWFFillStyle {
			return new SWFFillStyle(this, level);
		}
		
		public function writeFILLSTYLE(value:SWFFillStyle, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readLINESTYLE(level:uint):SWFLineStyle {
			return new SWFLineStyle(this, level);
		}
		
		public function writeLINESTYLE(value:SWFLineStyle, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readLINESTYLE2(level:uint):SWFLineStyle2 {
			return new SWFLineStyle2(this, level);
		}
		
		public function writeLINESTYLE2(value:SWFLineStyle2, level:uint = 1):void {
			value.publish(this, level);
		}
		
		/////////////////////////////////////////////////////////
		// Button record
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readBUTTONRECORD(level:uint):SWFButtonRecord {
			if (readUI8() == 0) {
				return null;
			} else {
				position--;
				return new SWFButtonRecord(this, level);
			}
		}

		public function writeBUTTONRECORD(value:SWFButtonRecord, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readBUTTONCONDACTION():SWFButtonCondAction {
			return new SWFButtonCondAction(this);
		}
		
		public function writeBUTTONCONDACTION(value:SWFButtonCondAction):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Filter
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readFILTER():IFilter {
			var filterId:uint = readUI8();
			var filter:IFilter = SWFFilterFactory.create(filterId);
			filter.parse(this);
			return filter;
		}
		
		public function writeFILTER(value:IFilter):void {
			writeUI8(value.id);
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Text record
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readTEXTRECORD(glyphBits:uint, advanceBits:uint, previousRecord:SWFTextRecord, level:uint):SWFTextRecord {
			if (readUI8() == 0) {
				return null;
			} else {
				position--;
				return new SWFTextRecord(this, glyphBits, advanceBits, previousRecord, level);
			}
		}
		
		public function writeTEXTRECORD(value:SWFTextRecord, glyphBits:uint, advanceBits:uint, previousRecord:SWFTextRecord = null, level:uint = 1):void {
			value.publish(this, glyphBits, advanceBits, previousRecord, level);
		}

		[Inline]
		public final function readGLYPHENTRY(glyphBits:uint, advanceBits:uint):SWFGlyphEntry {
			return new SWFGlyphEntry(this, glyphBits, advanceBits);
		}

		public function writeGLYPHENTRY(value:SWFGlyphEntry, glyphBits:uint, advanceBits:uint):void {
			value.publish(this, glyphBits, advanceBits);
		}
		
		/////////////////////////////////////////////////////////
		// Zone record
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readZONERECORD():SWFZoneRecord {
			return new SWFZoneRecord(this);
		}

		public function writeZONERECORD(value:SWFZoneRecord):void {
			value.publish(this);
		}
		
		[Inline]
		public final function readZONEDATA():SWFZoneData {
			return new SWFZoneData(this);
		}

		public function writeZONEDATA(value:SWFZoneData):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Kerning record
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readKERNINGRECORD(wideCodes:Boolean):SWFKerningRecord {
			return new SWFKerningRecord(this, wideCodes);
		}

		public function writeKERNINGRECORD(value:SWFKerningRecord, wideCodes:Boolean):void {
			value.publish(this, wideCodes);
		}
		
		/////////////////////////////////////////////////////////
		// Gradients
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readGRADIENT(level:uint):SWFGradient {
			return new SWFGradient(this, level);
		}
		
		public function writeGRADIENT(value:SWFGradient, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readFOCALGRADIENT(level:uint):SWFFocalGradient {
			return new SWFFocalGradient(this, level);
		}
		
		public function writeFOCALGRADIENT(value:SWFFocalGradient, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readGRADIENTRECORD(level:uint):SWFGradientRecord {
			return new SWFGradientRecord(this, level);
		}
		
		public function writeGRADIENTRECORD(value:SWFGradientRecord, level:uint = 1):void {
			value.publish(this, level);
		}
		
		/////////////////////////////////////////////////////////
		// Morphs
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readMORPHFILLSTYLE(level:uint):SWFMorphFillStyle {
			return new SWFMorphFillStyle(this, level);
		}
		
		public function writeMORPHFILLSTYLE(value:SWFMorphFillStyle, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readMORPHLINESTYLE(level:uint):SWFMorphLineStyle {
			return new SWFMorphLineStyle(this, level);
		}
		
		public function writeMORPHLINESTYLE(value:SWFMorphLineStyle, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readMORPHLINESTYLE2(level:uint):SWFMorphLineStyle2 {
			return new SWFMorphLineStyle2(this, level);
		}
		
		public function writeMORPHLINESTYLE2(value:SWFMorphLineStyle2, level:uint):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readMORPHGRADIENT(level:uint):SWFMorphGradient {
			return new SWFMorphGradient(this, level);
		}
		
		public function writeMORPHGRADIENT(value:SWFMorphGradient, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readMORPHFOCALGRADIENT(level:uint):SWFMorphFocalGradient {
			return new SWFMorphFocalGradient(this, level);
		}
		
		public function writeMORPHFOCALGRADIENT(value:SWFMorphFocalGradient, level:uint = 1):void {
			value.publish(this, level);
		}
		
		[Inline]
		public final function readMORPHGRADIENTRECORD():SWFMorphGradientRecord {
			return new SWFMorphGradientRecord(this);
		}
		
		public function writeMORPHGRADIENTRECORD(value:SWFMorphGradientRecord):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Action records
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readACTIONRECORD():IAction {
			var pos:uint = position;
			var action:IAction;
			var actionCode:uint = readUI8();
			if (actionCode != 0) {
				var actionLength:uint = (actionCode >= 0x80) ? readUI16() : 0;
				action = SWFActionFactory.create(actionCode, actionLength, pos);
				action.parse(this);
			}
			return action;
		}
		
		public function writeACTIONRECORD(action:IAction):void {
			action.publish(this);
		}
		
		[Inline]
		public final function readACTIONVALUE():SWFActionValue {
			return new SWFActionValue(this);
		}
		
		public function writeACTIONVALUE(value:SWFActionValue):void {
			value.publish(this);
		}
		
		[Inline]
		public final function readREGISTERPARAM():SWFRegisterParam {
			return new SWFRegisterParam(this);
		}
		
		public function writeREGISTERPARAM(value:SWFRegisterParam):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Symbols
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readSYMBOL():SWFSymbol {
			return new SWFSymbol(this);
		}
		
		public function writeSYMBOL(value:SWFSymbol):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// Sound records
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readSOUNDINFO():SWFSoundInfo {
			return new SWFSoundInfo(this);
		}
		
		public function writeSOUNDINFO(value:SWFSoundInfo):void {
			value.publish(this);
		}
		
		[Inline]
		public final function readSOUNDENVELOPE():SWFSoundEnvelope {
			return new SWFSoundEnvelope(this);
		}
		
		public function writeSOUNDENVELOPE(value:SWFSoundEnvelope):void {
			value.publish(this);
		}
		
		/////////////////////////////////////////////////////////
		// ClipEvents
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readCLIPACTIONS(version:uint):SWFClipActions {
			return new SWFClipActions(this, version);
		}
		
		public function writeCLIPACTIONS(value:SWFClipActions, version:uint):void {
			value.publish(this, version);
		}
		
		[Inline]
		public final function readCLIPACTIONRECORD(version:uint):SWFClipActionRecord {
			var pos:uint = position;
			var flags:uint = (version >= 6) ? readUI32() : readUI16();
			if (flags == 0) {
				return null;
			} else {
				position = pos;
				return new SWFClipActionRecord(this, version);
			}
		}
		
		public function writeCLIPACTIONRECORD(value:SWFClipActionRecord, version:uint):void {
			value.publish(this, version);
		}
		
		[Inline]
		public final function readCLIPEVENTFLAGS(version:uint):SWFClipEventFlags {
			return new SWFClipEventFlags(this, version);
		}
		
		public function writeCLIPEVENTFLAGS(value:SWFClipEventFlags, version:uint):void {
			value.publish(this, version);
		}
		
		
		/////////////////////////////////////////////////////////
		// Tag header
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readTagHeader():SWFRecordHeader {
			var pos:uint = position;
 			var tagTypeAndLength:uint = readUI16();
			var tagLength:uint = tagTypeAndLength & 0x003f;
			if (tagLength == 0x3f) {
				// The SWF10 spec sez that this is a signed int.
				// Shouldn't it be an unsigned int?
				tagLength = readSI32();
			}
			return new SWFRecordHeader(tagTypeAndLength >> 6, tagLength, position - pos);
		}

		public function writeTagHeader(type:uint, length:uint, forceLongHeader:Boolean = false):void {
			if (length < 0x3f && !forceLongHeader) {
				writeUI16((type << 6) | length);
			} else {
				writeUI16((type << 6) | 0x3f);
				// The SWF10 spec sez that this is a signed int.
				// Shouldn't it be an unsigned int?
				writeSI32(length);
			}
		}
		
		/////////////////////////////////////////////////////////
		// SWF Compression
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function swfUncompress(compressionMethod:String, uncompressedLength:uint):void {
			var pos:uint = position;
			var ba:ByteArray = new ByteArray();
			
			if(compressionMethod == SWF.COMPRESSION_METHOD_ZLIB) {
				readBytes(ba);
				ba.position = 0;
				ba.uncompress();
			} else if(compressionMethod == SWF.COMPRESSION_METHOD_LZMA) {

				// LZMA compressed SWF:
				//   0000 5A 57 53 0F   (ZWS, Version 15)
				//   0004 DF 52 00 00   (Uncompressed size: 21215)
				//   0008 94 3B 00 00   (Compressed size: 15252)
				//   000C 5D 00 00 00 01   (LZMA Properties)
				//   0011 00 3B FF FC A6 14 16 5A ...   (15252 bytes of LZMA Compressed Data, until EOF)
				// 7z LZMA format:
				//   0000 5D 00 00 00 01   (LZMA Properties)
				//   0005 D7 52 00 00 00 00 00 00   (Uncompressed size: 21207, 64 bit)
				//   000D 00 3B FF FC A6 14 16 5A ...   (15252 bytes of LZMA Compressed Data, until EOF)
				// (see also https://github.com/claus/as3swf/pull/23#issuecomment-7203861)

				// Write LZMA properties
				for(var i:uint = 0; i < 5; i++) {
					ba.writeByte(this[i + 12]);
				}
				
				// Write uncompressed length (64 bit)
				ba.endian = Endian.LITTLE_ENDIAN;
				ba.writeUnsignedInt(uncompressedLength - 8);
				ba.writeUnsignedInt(0);
				
				// Write compressed data
				position = 17;
				readBytes(ba, 13);
				
				// Uncompress
				ba.position = 0;
				ba.uncompress(compressionMethod);
				
			} else {
				throw(new Error("Unknown compression method: " + compressionMethod));
			}
			
			length = position = pos;
			writeBytes(ba);
			position = pos;
		}
		
		public function swfCompress(compressionMethod:String):void {
			var pos:uint = position;
			var ba:ByteArray = new ByteArray();
			
			if(compressionMethod == SWF.COMPRESSION_METHOD_ZLIB) {
				readBytes(ba);
				ba.position = 0;
				ba.compress();
			} else if(compressionMethod == SWF.COMPRESSION_METHOD_LZMA) {
				// Never should get here (unfortunately)
				// We're forcing ZLIB compression on publish, see CSS.as line 145
				throw(new Error("Can't publish LZMA compressed SWFs"));
				// This should be correct, but doesn't seem to work:
				var lzma:ByteArray = new ByteArray();
				readBytes(lzma);
				lzma.position = 0;
				lzma.compress(compressionMethod);
				// Write compressed length
				ba.endian = Endian.LITTLE_ENDIAN;
				ba.writeUnsignedInt(lzma.length - 13);
				// Write LZMA properties
				for(var i:uint = 0; i < 5; i++) {
					ba.writeByte(lzma[i]);
				}
				// Write compressed data
				ba.writeBytes(lzma, 13);
			} else {
				throw(new Error("Unknown compression method: " + compressionMethod));
			}
			
			length = position = pos;
			writeBytes(ba);
		}
		
		/////////////////////////////////////////////////////////
		// etc
		/////////////////////////////////////////////////////////
		
		[Inline]
		public final function readRawTag():SWFRawTag {
			return new SWFRawTag(this);
		}
		
		[Inline]
		public final function skipBytes(length:uint):void {
			position += length;
		}
		
		public static function dump(ba:ByteArray, length:uint, offset:int = 0):void {
			var posOrig:uint = ba.position;
			var pos:uint = ba.position = Math.min(Math.max(posOrig + offset, 0), ba.length - length);
			var str:String = "[Dump] total length: " + ba.length + ", original position: " + posOrig;
			for (var i:uint = 0; i < length; i++) {
				var b:String = ba.readUnsignedByte().toString(16);
				if(b.length == 1) { b = "0" + b; }
				if(i % 16 == 0) {
					var addr:String = (pos + i).toString(16);
					addr = "00000000".substr(0, 8 - addr.length) + addr;
					str += "\r" + addr + ": ";
				}
				b += " ";
				str += b;
			}
			ba.position = posOrig;
			trace(str);
		}
	}
}
