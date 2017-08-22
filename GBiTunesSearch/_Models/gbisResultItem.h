//
//  gbisResultItem.h
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/19/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface gbisResultItem : NSObject

@property (nonatomic, strong) UIImage *artworkLarge;
@property (nonatomic, strong) UIImage *artworkSmall;
@property (nonatomic, strong) NSString *artworkURLLarge;
@property (nonatomic, strong) NSString *artworkURLSmall;
@property (nonatomic, strong) NSString *trackName;
@property (nonatomic, strong) NSString *entityType;
@property (nonatomic, strong) NSString *price;
@property (nonatomic, strong) NSString *description;





@end
