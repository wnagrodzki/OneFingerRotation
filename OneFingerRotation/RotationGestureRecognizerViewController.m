//
//  RotationGestureRecognizerViewController.m
//  RotateView
//
//  Created by Wojtek Nagrodzki on 29/08/2013.
//  Copyright (c) 2013 Wojtek Nagrodzki. All rights reserved.
//

#import "RotationGestureRecognizerViewController.h"
#import "NGRotationGestureRecognizer.h"

@interface RotationGestureRecognizerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *twirlImageView;

@end

@implementation RotationGestureRecognizerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    NGRotationGestureRecognizer * gestureRecognizer = [[NGRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotationGesture:)];
    [self.twirlImageView addGestureRecognizer:gestureRecognizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.twirlImageView.center = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
}

- (void)handleRotationGesture:(NGRotationGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        gestureRecognizer.rotation = atan2(self.twirlImageView.transform.b, self.twirlImageView.transform.a);
        return;
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        self.twirlImageView.transform = CGAffineTransformMakeRotation(gestureRecognizer.rotation);
    }
}

@end
