
import UIKit

func callbackAfter(seconds: CGFloat, callback: () -> ()) {
  callbackAfter(Float(seconds), callback)
}


func callbackAfter(seconds: Float, callback: () -> ()) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Float(NSEC_PER_SEC) * seconds)), dispatch_get_main_queue(), callback)
}
