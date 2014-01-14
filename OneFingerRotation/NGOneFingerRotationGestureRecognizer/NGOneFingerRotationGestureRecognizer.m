/*
 * Copyright (c) 2013 Wojciech Nagrodzki
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "NGOneFingerRotationGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>


static CGFloat kMinimumAngle = 0.02;


CGPoint CGRectGetMidPoint(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}


@interface NGOneFingerRotationGestureRecognizer ()

@property (strong, nonatomic) UITouch * trackedTouch;
@property (assign, nonatomic) CGPoint initialTouchLocation;
@property (assign, nonatomic) CGPoint currentTouchLocation;
@property (assign, nonatomic) NSTimeInterval previousTimeStamp;

@end


@implementation NGOneFingerRotationGestureRecognizer

#pragma mark - Public Properties

- (void)setRotation:(CGFloat)rotation
{
    _rotation = rotation;
    [self adjustInitialTouchLocationToMatchRotation:rotation];
}

#pragma mark - Overriden

- (void)reset
{
    [super reset];
    self.trackedTouch = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if a touch is beeing tracked, we ignore all other touches
    if (self.trackedTouch != nil) {
        for (UITouch * touch in touches) {
            [self ignoreTouch:touch forEvent:event];
        }
        return;
    }
    
    // gesture fails if more then one finger touched the screen at once
    if ([event touchesForGestureRecognizer:self].count > 1) {
        self.state = UIGestureRecognizerStateFailed;
        return;
    }
    
    self.trackedTouch = [touches anyObject];
    self.previousTimeStamp = self.trackedTouch.timestamp;
    self.currentTouchLocation = [self.trackedTouch locationInView:[self referenceView]];
    self.rotation = 0;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.currentTouchLocation = [self.trackedTouch locationInView:[self referenceView]];
    
    CGPoint centerOfRotation = [self centerOfRotationInReferenceView];
    
    CGFloat initialVectorAngle = [self angleForVectorWithStartPoint:centerOfRotation endPoint:self.initialTouchLocation];
    CGFloat currentVectorAngle = [self angleForVectorWithStartPoint:centerOfRotation endPoint:self.currentTouchLocation];
    
    CGFloat currentRotation = currentVectorAngle - initialVectorAngle;
    CGFloat deltaRotation = currentRotation - self.rotation;
    
    // fix delta rotation
    if (deltaRotation > M_PI)
        deltaRotation -= 2 * M_PI;
    else if (deltaRotation < -M_PI)
        deltaRotation += 2 * M_PI;
    
    NSTimeInterval currentTimeStamp = self.trackedTouch.timestamp;
    CGFloat deltaTime = currentTimeStamp - self.previousTimeStamp;
    self.previousTimeStamp = currentTimeStamp;
    
    if (self.state == UIGestureRecognizerStatePossible) {
        if (fabsf(deltaRotation) < kMinimumAngle)
            return;
        
        _rotation = currentRotation;
        _velocity = deltaRotation / deltaTime;
        self.state = UIGestureRecognizerStateBegan;
        return;
    }
    
    _rotation = currentRotation;
    _velocity = deltaRotation / deltaTime;
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateChanged)
        self.state = UIGestureRecognizerStateEnded;
    else
        self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateCancelled;
}

#pragma mark - Private Methods

- (CGPoint)centerOfRotationInReferenceView
{
    CGPoint centerOfRotation = CGRectGetMidPoint(self.view.bounds);
    return [self.view convertPoint:centerOfRotation toView:[self referenceView]];
}

- (UIView *)referenceView
{
    return self.view.window;
}

- (float)angleForVectorWithStartPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint
{
    CGFloat componentX = endPoint.x - startPoint.x;
    CGFloat componentY = endPoint.y - startPoint.y;
    CGFloat angle = atan2f(componentY, componentX);
    if (angle < 0)
        angle += 2 * M_PI;
    
    return angle;
}

- (void)adjustInitialTouchLocationToMatchRotation:(CGFloat)rotation
{
    CGPoint centerOfRotation = [self centerOfRotationInReferenceView];
    CGAffineTransform translateTransform = CGAffineTransformMakeTranslation(centerOfRotation.x, centerOfRotation.y);
    CGAffineTransform rotationTransform = CGAffineTransformMakeRotation(-rotation);
    CGAffineTransform customRotation = CGAffineTransformConcat(CGAffineTransformConcat( CGAffineTransformInvert(translateTransform), rotationTransform), translateTransform);
    self.initialTouchLocation = CGPointApplyAffineTransform(self.currentTouchLocation, customRotation);
}

@end
