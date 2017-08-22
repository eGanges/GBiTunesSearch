//
//  gbisDetailViewController.h
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "gbisResultItem.h"

@interface gbisDetailViewController : UIViewController

@property (nonatomic, strong) gbisResultItem *resultItem;
@property (nonatomic, strong) NSDictionary* resultSetItemDict;
//-(void) configureViewFromDict:(NSDictionary*)dict;

@end
