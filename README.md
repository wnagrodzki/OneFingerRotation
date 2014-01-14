One Finger Rotation Gesture Recognizer
=================

NGRotationGestureRecognizer is a concrete subclass of UIGestureRecognizer that looks for rotation gestures involving one touch. Rotation is calculated between initial and current finger position around center of the view where gesture recognizer is added to.

Rotation can be set any time for convenience.

```Objective-C
- (void)handleRotationGesture:(NGRotationGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        gestureRecognizer.rotation = atan2(self.twirlImageView.transform.b, self.twirlImageView.transform.a);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.twirlImageView.transform = CGAffineTransformMakeRotation(gestureRecognizer.rotation);
    }
}
```
