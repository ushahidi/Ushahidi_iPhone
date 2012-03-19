# Ushahidi iOS #

Ushahidi is an open source platform for democratizing information, increasing transparency and lowering the barriers for individuals to share their stories. 

The iPhone and iPad app synchronizes with any Ushahidi deployment allowing viewing and creation of incident reports on the go. 

The app supports loading of multiple deployments at one time, quick filtering through incident reports, exploring incident locations on the map, viewing incident photos, news article, media as well as sharing incident reports via email, SMS or Twitter. Once the data has been downloaded, the app can function without an internet connection, allowing accurate collection of data utilizing the device's camera and GPS capabilities.

For more information visit:

* [About Ushahidi](http://www.ushahidi.com)
* [Issue Tracker](https://github.com/ushahidi/ushahidi_iphone/issues)
* [API Documentation](http://wiki.ushahidi.com/doku.php?id=ushahidi_api)
* [Code Repository](http://github.com/ushahidi/Ushahidi_iPhone)

### How To White-Label The App ###
* Duplicate the Ushahidi target with the name of your map (ex MapATL)
* Right-click on your new target (ex MapATL) select Get Info > Build tab > rename Product Name to name of map without spaces (ex MapATL)
* Duplicate the /Themes/Ushahidi folder with the name of your map as folder name (ex /Themes/MapATL)
* Replace each image in the folder with your own custom graphic, maintaining the image dimensions and filenames
* In XCode, on your new theme folder (ex /Themes/MapATL) Right-Click > Get Info > Targets tab, uncheck Ushahidi and check your new target (ex MapATL)
* Duplicate the Ushahidi.plist file using the name of your map as filename (ex MapATL.plist)
* In Xcode, Right-Click target (ex MapATL) > Get Info > Targets tab, edit the Info.plist File to your new plist file (ex MapATL.plist)
* Customize your app by editing the following properties in your plist file

Name and identifier of your map
* CFBundleIdentifier: unique indentifer of your app (ex com.ushahidi.ios.mapatl)
* CFBundleName: title of your application (ex MapATL)
* CFBundleDisplayName: name of your application (ex MapATL)

URL of your custom or Crowdmap deployment
* USHMapURL: URL for your map (ex http://crime.mapatl.com)

Email and website for your map
* USHSupportEmail: support email for your deployment (ex crime@mapatl.com)
* USHSupportURL: website for your deployment (ex http://crime.mapatl.com)
* USHAppStoreURL: link on App Store to download your application (ex http://itunes.apple.com/app/ushahidi-ios/id410609585)

HEX color codes to match your map styling
* USHNavBarColor: code for navigation bar 
* USHSearchBarColor: code for searchbars 
* USHToolBarColor: code for toolbars
* USHTablePlainColor: background color for plain tables
* USHTableGroupedColor: background color for grouped tables
* USHTableEvenRowColor: color of even rows in tables
* USHTableOddRowColor: color of odd rows in tables
* USHTableHeaderColor: background color of header sections
* USHTableHeaderTextColor: font color of header text
* USHTableSelectedRowColor: background of selected rows
* USHVerifiedTextColor: text color for verified label
* USHUnverifiedTextColor: text color for unverified label

Visibility of elements
* USHReportNewsURL: should news link be should in reports?

Optionally you can edit the Bit.ly API information, sign Up for a [Bitly Account](http://bitly.com/a/sign_up), then visit [Your bitly API Key](http://bitly.com/a/your_api_key)
* USHBitlyApiKey: your Bit.ly API key 
* USHBitlyApiLogin: your Bit.ly API login 

Optionally you can edit the Twitter API information, sign Up for a [Twitter Dev Account](https://dev.twitter.com/apps/new), entering your application name, description, website, organization, etc then visit [Using Twitter xAuth](https://dev.twitter.com/pages/xauth) for information on obtaining xAuth which is not enabled by default. Note, you'll need to email api@twitter.com explaining that your mobile application requires xAuth to skip the request_token and authorize steps and jump right to the access_token step.
* USHTwitterApiKey: your Twitter API key
* USHTwitterApiSecret: your Twitter API secret

You should now be able to deploy your white-labelled version of the app to the Simulator for testing, enjoy!