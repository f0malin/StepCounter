//
//  ViewController.m
//  StepCounter
//
//  Created by Achilles Xu on 2016/10/12.
//  Copyright © 2016年 Hukaa. All rights reserved.
//

#import "ViewController.h"



@interface ViewController ()

- (void)alertWithTitle:(NSString*)title message:(NSString*)message;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];
        self.device = [[HKDevice alloc] initWithName:@"iPhone" manufacturer:@"Apple" model:@"iPhone" hardwareVersion:@"iPhone7,1" firmwareVersion:nil softwareVersion:@"10.0.2" localIdentifier:nil UDIDeviceIdentifier:nil];
        HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
        NSSet *set = [NSSet setWithObject:quantityType];
        [self.healthStore requestAuthorizationToShareTypes:set readTypes:set completion:^(BOOL success, NSError * _Nullable error) {
            if (!success) {
                NSLog(@"request authorization failed: %@", error);
            } else {
                
                NSCalendar *calendar = [NSCalendar currentCalendar];
                
                NSDate *now = [NSDate date];
                
                NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:now];
                
                NSDate *startDate = [calendar dateFromComponents:components];
                
                NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
                
                HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
                NSPredicate *predicate = [HKQuery predicateForSamplesWithStartDate:startDate endDate:endDate options:HKQueryOptionNone];
                
                HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:nil resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                    NSLog(@"query end");
                    for (HKQuantitySample *sample in results) {
                        NSLog(@"sample device: %@, metadata %@, source reversion %@", sample.device, sample.metadata, sample.sourceRevision);
                        if (sample.device && [sample.device.model  isEqual: @"iPhone"]) {
                            
                            NSLog(@"device detail: %@ %@ %@ %@ %@", sample.device.hardwareVersion, sample.device.firmwareVersion, sample.device.softwareVersion, sample.device.localIdentifier, sample.device.UDIDeviceIdentifier);
                            if (!self.device) {
                                self.device = sample.device;
                            }
                            //break;
                        }
                    }
                }];
                [self.healthStore executeQuery:query];
                
            }
        }];
        
        
        
        
    } else {
        [self alertWithTitle:@"错误" message:@"不支持 HealthKit"];
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)buttonPressed:(id)sender {
    //[self alertWithTitle:@"haha" message:@"hehe"];
    
    NSDate *now = [NSDate date];
    HKQuantityType *quantityType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    HKUnit *count = [HKUnit unitFromString:@"count"];
    
    long randSteps = arc4random() % 2500 + 5000;
    NSLog(@"random steps: %ld", randSteps);
    
    HKQuantity *quantity = [HKQuantity quantityWithUnit:count
                                            doubleValue:randSteps];
    
    HKQuantitySample *sample =
    [HKQuantitySample quantitySampleWithType:quantityType
                                    quantity:quantity
                                   startDate:[now dateByAddingTimeInterval:-1123]
                                     endDate:now device:self.device metadata:nil];
    [self.healthStore saveObject:sample withCompletion:^(BOOL success, NSError * _Nullable error) {
        //
        if (success) {
            [self alertWithTitle:@"succeed" message:@"finish saved"];
        } else {
            NSLog(@"error: %@", error);
        }
    }];
}

- (void)alertWithTitle:(NSString*)title message:(NSString*)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
