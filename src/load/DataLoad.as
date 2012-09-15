package load
{
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;

	public class DataLoad
	{
		
		private static var _assetList:Dictionary;
		private static var _assetBank:Dictionary;
		
		
		public static function startup(assetListURL:String, callback:Function):void{
			var asset:AssetInfo;
			var list:XML;
			var xml:XML;
			var extension:String;
			var type:String;
			
			var urlLoader:URLLoader = new URLLoader;
			var urlRequest:URLRequest = new URLRequest(assetListURL);
			
			urlLoader.addEventListener(Event.COMPLETE, loaded);
			urlLoader.load(urlRequest);
			
			function loaded(e:Event):void{
				var assetsXML:XML = XML(e.currentTarget.data);
				_assetList = new Dictionary;
				_assetBank = new Dictionary;
				
				for each(list in assetsXML.assetList){
					extension = String(list.@extension);
					type	  = String(list.@type);
					
					for each(xml in list.asset){
						asset = new AssetInfo;
						asset.loadXML(xml, type, extension);
						
						_assetList[asset.id] = asset;
					}
				}
				
				urlLoader.removeEventListener(Event.COMPLETE, loaded);
				if(callback)callback();
			}
		}
		
		private static function getAssetInfoByID(id:String):AssetInfo{
			return _assetList[id];
		}
		
		private static function getAssetInfoByType(type:String):Vector.<AssetInfo>{
			var assets:Vector.<AssetInfo> = new Vector.<AssetInfo>;
			var asset:AssetInfo;
			
			for each(asset in _assetList){
				if(asset.type == type){
					assets.push(asset);
				}
			}
			
			return assets;
		}
		
		private static function getAssetsFromXML(xml:XML):Vector.<AssetInfo>{
			var xmlList:XMLList = xml..@assetID;
			var assets:Vector.<AssetInfo> = new Vector.<AssetInfo>;
			var asset:XML;
			
			for each(asset in xmlList){
				if(!_assetList[asset.@assetID]) throw new Error("This asset is not defined in the assets XML: " + String(asset.@assetID));
				assets.push(_assetList[asset.@assetID]);	
			}
			
			return assets;
		}
		
		public static function loadXML(assetID:String, loadObj:LoadObject):void{
			
			if(!_assetList[assetID]) throw new Error("This asset is not defined in the assets XML: " + assetID);
			if(_assetList[assetID].extension != "xml") throw new Error("This asset is not an XML: " + assetID);
			var asset:AssetInfo = _assetList[assetID];
			
			load(asset, loadObj);
		}
		
		public static function loadImage(id:String, path:String):void{
			
		}
		
		public static function loadSwf(id:String, path:String):void{
			
		}
		
		public static function loadSound(id:String, name:String):void{
			
		}
		
		public static function loadAssets(assets:Vector.<AssetInfo>, loadObj:LoadObject):void{
			var iter:int = -1;
			
			setBytes();
			function setBytes():void{
				iter++;
				if(iter < assets.length){
					loadObj.appendTotalBytes(assets[iter].url, assets[iter].type, setBytes);
				} else {
					iter = 0;
					load(assets[iter],loadObj);
				}
			}
			
			function complete(e:Event):void{
				iter++;
				if(iter < assets.length){
					load(assets[iter], loadObj, complete);
				} else {
					loadObj.complete(e);
				}
			}
		}
		
		private function load(asset:AssetInfo, loadObj:LoadObject, complete:Function = null):void{
			var loader:Loader;
			var urlLoader:URLLoader;
			var req:URLRequest  = new URLRequest(asset.url);
			
			if(asset.type == LoadObject.TYPE_DISPLAY){
				loader = new Loader;
				
				loader.addEventListener(ProgressEvent.PROGRESS, loadObj.progress);
				loader.addEventListener(Event.COMPLETE, onComplete);
				loader.addEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				
				loader.load(req);
			} else {
				urlLoader = new URLLoader;
				urlLoader.addEventListener(ProgressEvent.PROGRESS, loadObj.progress);
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
			}
			
			function onComplete(e:Event):void{
				_assetBank[asset.id] = asset.type == LoadObject.TYPE_DISPLAY ? e.currentTarget.content : e.currentTarget.data;
				complete ? complete() :  loadObj.complete(e);
			}
		}
		
		public static function loadAssetsForXML(xml:XML, loadObj:LoadObject):void{
			var assets:Vector.<AssetInfo> = getAssetsFromXML(xml);
			loadAssets(assets, loadObj);
		}
		
		public static function getImage(batchID:String, name:String):DisplayObject{
			
			
			return new DisplayObject;
		}
		
		public static function getSwf(batchID:String, swfName:String):DisplayObject{
			var swf:DisplayObject;
			
			return swf;
		}
		
		public static function getClass(batchID:String, swfName:String, linkageName:String):Class{
			var cls:Class;
			
			return cls;
		}
		
		public static function getXML(assetID:String):XML{
			
			if(!_assetBank[assetID])throw new Error("AssetID: " + assetID + " has not been loaded yet");
			if(_assetBank[assetID].extension ==  "xml")throw new Error("AssetID: " + assetID + " is not an XML");
			
			return XML(_assetBank[assetID]);
		}
		
	}
}