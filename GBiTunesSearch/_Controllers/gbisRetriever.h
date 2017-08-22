//
//  gbisRetriever.h
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/21/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface gbisRetriever : NSObject

+ (id)sharedInstance; // Singleton method.

-(BOOL) retrieveTerm:(NSString*)term forEntity:(NSString*)entity;




@end


