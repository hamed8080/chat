# Managing Maps
Converting lat, long to an address or searching through a map, or finding a route getting an image of lat, long. 


### Reverse a lat, long to an address
Reverse a latitude or longitude to a human readable address ``Chat/MapProtocol/reverse(_:)`` like this:
```swift
let req = MapReverseRequest(lat: 37.33900249783756 , lng: -122.00944807880965)
ChatManager.activeInstance?.map.reverse(req)
```

### Search for Items inside an area
Search for items inside an area with lat and long you should use method ``Chat/MapProtocol/search(_:)`` like this:
```swift
let req = MapSearchRequest(lat: 37.33900249783756 , lng: -122.00944807880965)
ChatManager.activeInstance?.map.search(req)
```

### Finding route
Finding a route between two point. 
If you want to receive more than one route please set alternative to true.
Use method ``Chat/MapProtocol/routes(_:)`` like this:
```swift
let origin = Cordinate(lat: 37.33900249783756, lng: -122.00944807880965)
let destination = Cordinate(lat: 22.33900249783756, lng: -110.00944807880965)
let req = MapRoutingRequest(origin: origin, destination: destination)
ChatManager.activeInstance?.map.routes(req)
```

### Convert an cordinate to an image
Convert an location to an image use the method ``Chat/MapProtocol/image(_:)`` like this:
```swift
let center = Cordinate(lat: 37.33900249783756, lng: -122.00944807880965)
let req = MapStaticImageRequest(center: center)
ChatManager.activeInstance?.map.image(req)
```
