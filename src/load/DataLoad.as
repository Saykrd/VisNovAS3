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
			trace("[DataLoad] is starting up...");
			trace("[DataLoad] Loading up assets XML from: " + assetListURL);
			urlLoader.addEventListener(Event.COMPLETE, loaded);
			urlLoader.load(urlRequest);
			
			function loaded(e:Event):void{
				trace("[DataLoad] Assets XML succesfully loaded from: " + assetListURL);
				
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
				urlLoader = null;
				trace("[DataLoad] Startup completed succesfully.");
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
				if(!_assetList[String(asset)]) throw new Error("[DataLoadError] This asset is not defined in the assets XML: " + String(asset));
				assets.push(_assetList[String(asset)]);	
			}
			
			return assets;
		}
		
		public static function loadAsset(assetID:String, loadObj:LoadObject):void{
			
			if(!_assetList[assetID]) throw new Error("[DataLoadError] This asset is not defined in the assets XML: " + assetID);
			var asset:AssetInfo = _assetList[assetID];
			loadObj.setNumItems(1);
			load(asset, loadObj);
		}
		
		public static function loadAssets(assets:Vector.<AssetInfo>, loadObj:LoadObject):void{
			var iter:int = 0;

			trace("[DataLoad] Starting batch load of " + assets.length + " items...");
			loadObj.setNumItems(assets.length);
			load(assets[iter],loadObj,complete);
			
			function complete(e:Event):void{
				iter++;
				if(iter < assets.length){
					load(assets[iter], loadObj, complete);
				} else {
					trace("[DataLoad] Asset batch succesfully loaded.");
					loadObj.complete(e);
				}
			}
		}
		
		private static function load(asset:AssetInfo, loadObj:LoadObject, complete:Function = null):void{
			var loader:Loader;
			var urlLoader:URLLoader;
			var req:URLRequest  = new URLRequest(asset.url);
			
			
			trace("[DataLoad] Loading asset '" + asset.id +  "' from: " + asset.url);
			if(asset.type == LoadObject.TYPE_DISPLAY){
				loader = new Loader;
				
				loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadObj.progress);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onComplete);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				
				loader.load(req);
			} else {
				urlLoader = new URLLoader;
				urlLoader.addEventListener(ProgressEvent.PROGRESS, loadObj.progress);
				urlLoader.addEventListener(Event.COMPLETE, onComplete);
				urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				
				urlLoader.load(req);
			}
			
			function onComplete(e:Event):void{
				trace("[DataLoad] Asset '" + asset.id +  "' successfully loaded from: " + asset.url);
				
				if(urlLoader){
					urlLoader.removeEventListener(ProgressEvent.PROGRESS, loadObj.progress);
					urlLoader.removeEventListener(Event.COMPLETE, onComplete);
					urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				}
				
				if(loader){
					
					loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS, loadObj.progress);
					loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onComplete);
					loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, loadObj.error);
				}
				
				asset.appDomain = asset.type == LoadObject.TYPE_DISPLAY ?  e.currentTarget.applicationDomain : null;
				_assetBank[asset.id] = asset.type == LoadObject.TYPE_DISPLAY ? e.currentTarget.content : e.currentTarget.data;
				complete ? complete(e) :  loadObj.complete(e);
			}
		}
		
		public static function loadAssetsFromXML(xml:XML, loadObj:LoadObject):void{
			var assets:Vector.<AssetInfo> = getAssetsFromXML(xml);
			loadAssets(assets, loadObj);
		}
		
		public static function getImage(batchID:String, name:String):DisplayObject{
			return new DisplayObject;
		}
		
		public static function getSwf(assetID:String):DisplayObject{
			validateAsset(assetID, "swf");
			var swf:Object      = _assetBank[assetID];
			return swf;
		}
		
		public static function getClass(assetID:String, linkageName:String):Class{
			validateAsset(assetID, "swf");
			var asset:AssetInfo = _assetList[assetID];
			var cls:Class       = asset.appDomain.getDefinition(linkageName) as Class;
			
			return cls;
		}
		
		public static function getXML(assetID:String):XML{
			validateAsset(assetID, "xml");
			return XML(_assetBank[assetID]);
		}
		
		private static function validateAsset(assetID:String, extension:String):void{
			if(!_assetBank[assetID])throw new Error("[DataLoadError] AssetID: " + assetID + " has not been loaded yet");
			if(!_assetList[assetID].extension ==  "xml")throw new Error("[DataLoadError] AssetID: " + assetID + " is not an XML");
		}
		
	}
}