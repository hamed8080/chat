# Managing Maps
Converting lat, long to an address or searching through a map, or finding a route getting an image of lat, long. 



### Reverse a lat, long to an address

Reverse a latitude or longitude to a human readable address ``Chat/mapReverse(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.mapReverse(.init(lat: 37.33900249783756 , lng: -122.00944807880965)) { mapReverse, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Search for Items inside an area

Search for items inside an area with lat and long you should use method ``Chat/mapSearch(_:completion:uniqueIdResult:)`` like this:
```swift
Chat.sharedInstance.mapSearch(.init(lat: 37.33900249783756 , lng: -122.00944807880965)) { mapItems, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Finding route

Finding a route between two point. 
If you want to receive more than one route please set alternative to true.
Use method ``Chat/mapSearch(_:completion:uniqueIdResult:)`` like this:
```swift
let origin = Cordinate(lat: 37.33900249783756, lng: -122.00944807880965)
let destination = Cordinate(lat: 22.33900249783756, lng: -110.00944807880965)
Chat.sharedInstance.mapRouting(.init(alternative: true, origin: origin, destination: destination) ) { routes, uniqueId, error in
    if error == nil{
        // Write your code
    }
}
```

### Convert an cordinate to an image

Convert an location to an image use the method ``Chat/mapStaticImage(_:_:completion:uniqueIdResult:)`` like this:
```swift
let center = Cordinate(lat: 37.33900249783756, lng: -122.00944807880965)
let req = MapStaticImageRequest(center: center)
Chat.sharedInstance.mapStaticImage(req) { imageData, uniqueId, error in
    if let data = data, let image = UIImage(data: data){
        // Write your code
    }
}
```
