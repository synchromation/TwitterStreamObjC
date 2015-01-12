# TwitterStreamObjC
##Description
A simple iOS app writtent in Objective-C to demonstrate how to use the Twitter Streaming APIs https://dev.twitter.com/streaming/overview.  It uses the https://stream.twitter.com/1.1/statuses/filter.json endpoint which returns a filtered version of the public stream based on a search term (in this case the string 'hotels'). The app uses the built-in iOS Twitter integration (which needs to be setup before the running the app).
##Limitations
This code was not designed to handle high-frequency updates (some additional UI update buffering would be recommended in this instance)
##Requirements
- iOS 8+
- Xcode 6+
