# ``Mocks/MockTimer``

## MockTimer

For mocking the timer class just inject an instance of type `Additive.TimerProtocol` like code below:
```swift
final class ViewModel {
    let timer: TimerProtocol
    init(timer: TimerProtocol) {
        self.timer = timer
    }   
}
```

Then you have the power to control this instance variable with ``MockTimer`` like:

```swift
final class TestViewModel: XCTestCase {
    var mockTimer: MockTimer!
    override func setUp() {
        mockTimer = MockTimer()
    }

    func test_timer() {
        mockTimer.blockResult = { timer in
            XCTAssertTrue(true)
        }
        mockTimer.fire()
    }
}
```
