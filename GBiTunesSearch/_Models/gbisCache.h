//
//  gbisCache.h
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/21/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface gbisCache : NSObject
+ (id)sharedInstance; // Singleton method.


-(void) setSearchResult:(NSDictionary*)theResultSet forStoreString:(NSString*)storeString;

-(NSDictionary*) getSearchForStoreString:(NSString*)storeString;

-(BOOL) deleteSearchResultForStoreURLString:(NSString*)storeString;

@end
