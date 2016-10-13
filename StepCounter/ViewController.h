//
//  ViewController.h
//  StepCounter
//
//  Created by Achilles Xu on 2016/10/12.
//  Copyright © 2016年 Hukaa. All rights reserved.
//

#import <UIKit/UIKit.h>
@import HealthKit;

@interface ViewController : UIViewController

@property (nonatomic) HKHealthStore *healthStore;
@property (nonatomic) HKDevice *device;

- (IBAction)buttonPressed:(id)sender;
@end

