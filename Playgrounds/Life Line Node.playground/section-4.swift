func callbackAfter(seconds: Float, callback: () -> ()) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(Float(NSEC_PER_SEC) * seconds)), dispatch_get_main_queue(), callback)
}

extension SKScene {
    
    func getSceneScale() -> CGSize {
        return CGSize(width: getSceneScaleX(), height: getSceneScaleY())
    }
    
    func getSceneScaleX() -> CGFloat {
        return frame.width / view!.frame.width
    }
    
    func getSceneScaleY() -> CGFloat {
        return frame.height / view!.frame.height
    }
}

