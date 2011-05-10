# Ushahidi iOS #

Ushahidi is an open source platform for democratizing information, increasing transparency and lowering the barriers for individuals to share their stories. 

The iPhone and iPad app synchronizes with any Ushahidi deployment allowing viewing and creation of incident reports on the go. 

The app supports loading of multiple deployments at one time, quick filtering through incident reports, exploring incident locations on the map, viewing incident photos, news article, media as well as sharing incident reports via email, SMS or Twitter. Once the data has been downloaded, the app can function without an internet connection, allowing accurate collection of data utilizing the device's camera and GPS capabilities.

For more information visit:

* [About Ushahidi](http://www.ushahidi.com)
* [Issue Tracker](http://dev.ushahidi.com/projects/roadmap/Ushahidi_iPhone)
* [API Documentation](http://wiki.ushahidi.com/doku.php?id=ushahidi_api)
* [Code Repository](http://github.com/ushahidi/Ushahidi_iPhone)

## White-Labeled App ##

To Create A Custom White-Labeled App For A Specific Map:

### Technique #1 (Simple) ###
* Open /Themes/Default/Settings.plist in XCode or Property List Editor
* Specify the MapURL with the web address of your map
* Specify the MapName with the name of your map
* Change the color code properties (NavBarTintColor, TableOddRowColor...) according to the styling of your map
* Replace each image with a more appropriate graphic for your map (maintaining file name and image dimensions)
* Note, you can use the /Themes/MapATL as an example of a custom white-labeled map
* Edit Info.plist Bundle Name and Bundle Display Name to what you'd like to see below your app icon
* Optionally edit Info.plist UshahidiWebsite and UshahidiEmail if you want point to your own map and use your own support email

### Technique #2 (Advanced) ###
* Create a duplicate copy of the /Themes/Default folder with a new name, for example MyMap
* Open /Themes/MyMap/Settings.plist in XCode or Property List Editor
* Specify the MapURL with the web address of your map
* Specify the MapName with the name of your map
* Change the color code properties (NavBarTintColor, TableOddRowColor...) according to the styling of your map
* Replace each image with a more appropriate graphic for your map (maintaining file name and image dimensions)
* Note, you can use the /Themes/MapATL as an example of a custom white-labeled map
* Drag your MyMap theme folder into XCode under the Themes group
* IMPORTANT Remove the Default folder from Ushahidi_iOS target (right-click Default -> Get Info -> Targets tab -> uncheck)
* IMPORTANT Add the MyMap folder to the Ushahidi_iOS target (right-click Default -> Get Info -> Targets tab -> check)
* Edit Info.plist Bundle Name and Bundle Display Name to what you'd like to see below your app icon
* Optionally edit Info.plist UshahidiWebsite and UshahidiEmail if you want point to your own map and use your own support email