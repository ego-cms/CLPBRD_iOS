import UIKit


/** Animation trigger here is a closure which initiates animation (either UIKit or CoreAnimation)
 
 like:
 ```
 {
    UIView.animate(0.4) {
        button.backgroundColor = .green
    }
 }
 ```
*/
func animate(triggers: [VoidClosure], delays: [TimeInterval]) {
    precondition(triggers.count == delays.count, "You must provide the same amount of delays and triggers")
    var launchTime: TimeInterval = 0
    let pairs = zip(triggers, delays)
    for (trigger, duration) in pairs {
        launchTime += duration
        delay(launchTime, closure: trigger)
    }
}
