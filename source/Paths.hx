package;

#if MODS_ALLOWED
import sys.io.File;
import sys.FileSystem;
#end
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import modding.PolymodHandler;
import ModsMenuState;
import modding.ModsMenuStateOption;
import modding.ModList;
import flash.media.Sound;

class Paths
{
	inline public static final SOUND_EXT = #if web "mp3" #else "ogg" #end;
	inline public static final VIDEO_EXT = "mp4";
	inline public static final WEBM_EXT = "webm";
	static public var modDir:String = null;
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	public static var coolMods:ModsMenuState;
	public static var customImagesLoaded:Map<String, Bool> = new Map<String, Bool>();

	public static var ignoredFolders:Array<String> = [
		'characters', 
		'art', 
		'locales', 
		'data', 
		'songs',
		'music', 
		'sounds', 
		'fonts', 
		'videos', 
		'images', 
		'cutscenes', 
		'scripts'
	];

	public static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, ?type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static function getModPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibrarymodPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibrarymodPathForce(file, "images");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getmodPreloadPath(file);
	}


	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static function getLibrarymodPathForce(file:String, library:String)
	{
		return '$library:mods/$library/$file';
	}

	inline static function getmodPreloadPath(file:String)
	{
		return 'mods/$file';
	}

	inline static public function file(file:String, ?type:AssetType, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	static public function sound(key:String, ?library:String):Dynamic
	{
		var sound:Sound = addCustomSound('sounds', key);
		return sound;
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	static public function video(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modVideo(key);
		if (FileSystem.exists(file))
		{
			return file;
		}
		else
			return 'assets/videos/$key.$VIDEO_EXT';
		#else
		return 'assets/videos/$key.$VIDEO_EXT';
		#end
	}

	static public function webm(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modWebm(key);
		if (FileSystem.exists(file))
		{
			return file;
		}
		else
			return 'assets/videos/$key.$WEBM_EXT';
		#else
		return 'assets/videos/$key.$WEBM_EXT';
		#end
	}

	inline static public function music(key:String, ?library:String):Dynamic
	{
		var file:Sound = addCustomSound('music', key);
		return file;
	}

	inline static public function voices(song:String):Any
	{
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Voices'));
		if (file != null)
		{
			return file;
		}
		#end

		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Voices.$SOUND_EXT';
	}

	inline static public function inst(song:String):Any
	{
		#if MODS_ALLOWED
		var file:Sound = returnSongFile(modsSongs(song.toLowerCase().replace(' ', '-') + '/Inst'));
		if (file != null)
		{
			return file;
		}
		#end

		return 'songs:assets/songs/${song.toLowerCase().replace(' ', '-')}/Inst.$SOUND_EXT';
	}

	inline static private function returnSongFile(file:String):Sound
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(file))
		{
			if (!customSoundsLoaded.exists(file))
			{
				customSoundsLoaded.set(file, Sound.fromFile(file));
			}
			return customSoundsLoaded.get(file);
		}
		#end
		return null;
	}

	static public function addCustomGraphic(key:String):FlxGraphic
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(modsImages(key)))
		{
			if (!customImagesLoaded.exists(key))
			{
				var newBitmap:BitmapData = BitmapData.fromFile(modsImages(key));
				var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(newBitmap, false, key);
				newGraphic.persist = true;
				FlxG.bitmap.addGraphic(newGraphic);
				customImagesLoaded.set(key, true);
			}
			return FlxG.bitmap.get(key);
		}
		#end
		return null;
	}

	inline static public function image(key:String, ?library:String):Dynamic
	{
		#if MODS
		var imageToReturn:FlxGraphic = addCustomGraphic(key);
		if (imageToReturn != null)
			return imageToReturn;
		#end

		return getPath('images/$key.png', IMAGE);
	}

	inline static public function font(key:String)
	{
	}

	inline static public function font(key:String)
	{
		#if MODS_ALLOWED
		var file:String = modsFont(key);
		if (FileSystem.exists(file))
		{
			return file;
		}
		#end
		return 'assets/fonts/$key';
	}

	inline static public function locales(key:String, ?library:String)
	{
		return getPath('locales/$key/languageData.json', TEXT, library);
	}

	inline static public function cutscene(key:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath('cutscenes/$key.json', type, library);
	}

	inline static public function lua(key:String, ?library:String)
	{
		return getPath('$key.lua', TEXT, library);
	}

	inline static public function charJson(key:String, ?library:String)
	{
		return getPath('characters/$key.json', TEXT, library);
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		#if MODS_ALLOWED
		if (FileSystem.exists(mods(key)) || FileSystem.exists(mods(key)))
		{
			return true;
		}
		#end

		if (OpenFlAssets.exists(Paths.getPath(key, type, library)))
		{
			return true;
		}
		return false;
	}

	inline static public function modTxt(key:String)
	{
		return modFolder('data/$key.txt');
	}

	inline static public function mods(key:String = '')
	{
		return 'mods/' + key;
	}

	inline static public function modsSongs(key:String)
	{
		return modFolder('songs/' + key + '.' + SOUND_EXT);
	}

	inline static public function modSong(key:String)
	{
		return modFolder(key + '.json');
	}

	inline static public function modsJson(key:String)
	{
		return modFolder('data/' + key + '.json');
	}

	inline static public function modImage(key:String)
	{
		return modFolder('images/' + key + '.png');
	}

	inline static public function modsXml(key:String)
	{
		return modFolder('data/' + key + '.xml');
	}

	inline static public function modVideo(key:String)
	{
		return modFolder('videos/' + key + '.' + VIDEO_EXT);
	}

	inline static public function modWebm(key:String)
	{
		return modFolder('videos/' + key + '.' + WEBM_EXT);
	}

	inline static public function modsFont(key:String)
	{
		return modFolder('fonts/' + key);
	}

	inline static public function modLua(key:String)
	{
		return modFolder('$key.lua');
	}

	inline static public function modSound(path:String, key:String)
	{
		return modFolder(path + '/' + key + '.' + SOUND_EXT);
	}

	inline static public function modChar(key:String)
	{
		return modFolder('characters/$key.json');
	}

	inline static public function modCutscenes(key:String)
	{
		return modFolder('cutscenes/$key.json');
	}

	inline static public function getModsSparrowAtlas(key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var imageLoaded:FlxGraphic = addCustomGraphic(key);
		var xmlExists:Bool = false;
		if (FileSystem.exists(modsXml(key)))
		{
			xmlExists = true;
		}

		return FlxAtlasFrames.fromSparrow((imageLoaded != null ? imageLoaded : image(key, library)),
			(xmlExists ? File.getContent(modsXml(key)) : file('images/$key.xml', library)));
		#end
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}

	static public function modFolder(key:String)
	{
		#if MODS_ALLOWED
		var list:Array<String> = [];
		var modsFolder:String = Paths.mods();
		if (FileSystem.exists(modsFolder))
		{
			for (folder in FileSystem.readDirectory(modsFolder))
			{
				var path = haxe.io.Path.join([modsFolder, folder]);
				if (sys.FileSystem.isDirectory(path) && !Paths.ignoredFolders.contains(folder) && !list.contains(folder))
				{
					list.push(folder);
					for (i in 0...list.length)
					{
						modDir = list[i];
					}
				}
			}
		}
		if (ModList.getModEnabled(modDir))
		{
			if (modDir != null && modDir.length > 0)
			{
				// psych engine for the win
				var fileToCheck:String = mods(modDir + '/' + key);
				if (FileSystem.exists(fileToCheck))
				{
					return fileToCheck;
				}
			}
		}

		return 'mods/' + key;
		#else
		return key;
		#end
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];

	public static function addCustomSound(path:String, key:String, ?library:String)
	{
		#if MODS_ALLOWED
		var file:String = modSound(path, key);
		if (FileSystem.exists(file))
		{
			if (!currentTrackedSounds.exists(file))
			{
				currentTrackedSounds.set(file, Sound.fromFile(file));
			}
			localTrackedAssets.push(key);
			return currentTrackedSounds.get(file);
		}
		#end
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		if (!currentTrackedSounds.exists(gottenPath))
			#if MODS_ALLOWED
			currentTrackedSounds.set(gottenPath, Sound.fromFile('./' + gottenPath));
			#else
			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(getPath('$path/$key.$SOUND_EXT', SOUND, library)));
			#end
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}
}
