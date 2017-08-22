//
//  AppDelegate.h
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#define kLogIsOn 1
#define kSearchCompletedNotification @"SearchCompletedNotification"


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;

@property BOOL searchIsAborted;
@property (nonatomic, strong) NSString* searchIsAbortedMessage;
@property (nonatomic, strong) NSDictionary* searchResultSet;
@property (nonatomic, strong) NSDictionary* searchResultSetItemDict;
@property BOOL searchIsLoadedFromCache;
@property (nonatomic, strong) UIImage* searchPlaceholderImage60x60;
@property (nonatomic, strong) UIImage* searchPlaceholderImage100x100;
@end

