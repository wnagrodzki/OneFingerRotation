//
//  RotationGestureRecognizerViewController.m
//  RotateView
//
//  Created by Wojtek Nagrodzki on 29/08/2013.
//  Copyright (c) 2013 Wojtek Nagrodzki. All rights reserved.
//

#import "RotationGestureRecognizerViewController.h"
#import "NGOneFingerRotationGestureRecognizer.h"

@interface RotationGestureRecognizerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *twirlImageView;

@end

@implementation RotationGestureRecognizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NGOneFingerRotationGestureRecognizer * gestureRecognizer = [[NGOneFingerRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    [self.twirlImageView addGestureRecognizer:gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.twirlImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)handleRotationGesture:(NGOneFingerRotationGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        gestureRecognizer.rotation = atan2(self.twirlImageView.transform.b, self.twirlImageView.transform.a);
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.twirlImageView.transform = CGAffineTransformMakeRotation(gestureRecognizer.rotation);
    }
}

@end
