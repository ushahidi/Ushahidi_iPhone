# Ushahidi iOS #

Ushahidi is an open source platform for democratizing information, increasing transparency and lowering the barriers for individuals to share their stories. 

The iPhone and iPad app synchronizes with any Ushahidi deployment allowing viewing and creation of incident reports on the go. 

The app supports loading of multiple deployments at one time, quick filtering through incident reports, exploring incident locations on the map, viewing incident photos, news article, media as well as sharing incident reports via email, SMS or Twitter. Once the data has been downloaded, the app can function without an internet connection, allowing accurate collection of data utilizing the device's camera and GPS capabilities.

For more information visit:

* [About Ushahidi](http://www.ushahidi.com)
* [Issue Tracker](http://dev.ushahidi.com/projects/roadmap/Ushahidi_iPhone)
* [API Documentation](http://wiki.ushahidi.com/doku.php?id=ushahidi_api)
* [Code Repository](http://github.com/ushahidi/Ushahidi_iPhone)

### How To White-Label The App ###
* Duplicate the Ushahidi target with the name of your map (ex MapATL)
* Right-click on your new target (ex MapATL) select Get Info > Build tab > rename Product Name to name of map without spaces (ex MapATL)
* Duplicate the /Themes/Ushahidi folder with the name of your map as folder name (ex /Themes/MapATL)
* Replace each image in the folder with your own custom graphic, maintaining the image dimensions and filenames
* In XCode, on your new theme folder (ex /Themes/MapATL) Right-Click > Get Info > Targets tab, uncheck Ushahidi and check your new target (ex MapATL)
* Duplicate the Ushahidi.plist file using the name of your map as filename (ex MapATL.plist)
* Edit BUNDLE NAME AND VERSION section with name of your map and an unique Bundle Indentifer (ex com.ushahidi.ios.mapatl)
* Edit SUPPORT INFORMATION section with email and website for your map
* Edit SINGLE DEPLOYMENT URL section with the URL for your map
* Edit STYLING COLOR CODES section with various HEX color codes to match your map styling
* Optionally edit BITLY AND TWITTER API KEYS if you have your own API keys for these services
* For BITLY, Sign Up for a [Bitly Account](http://bitly.com/a/sign_up), then visit [Your bitly API Key](http://bitly.com/a/your_api_key) to find your BitlyLogin and BitlyApiKey
* For TWITTER, Sign Up for a [Twitter Dev Account](https://dev.twitter.com/apps/new), entering your application name, description, website, organization, etc then visit [Using Twitter xAuth](https://dev.twitter.com/pages/xauth) for information on obtaining xAuth which is not enabled by default. Note, you'll need to email api@twitter.com explaining that your mobile application requires xAuth to skip the request_token and authorize steps and jump right to the access_token step.
* In Xcode, Right-Click target (ex MapATL) > Get Info > Targets tab, edit the Info.plist File to your new plist file (ex MapATL.plist)
* You should now be able to deploy your white-labelled version of the app to the Simulator for testing, enjoy!