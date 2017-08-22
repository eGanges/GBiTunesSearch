//
//  gbisCache.m
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/21/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//
//  Simple cache object to store and retrieve previous search terms
//  1) minimize API calls to Apple
//  2) can be replaced with Scaling calls to remote Caching Server
//

#import "gbisCache.h"
#import "AppDelegate.h"

static id sharedInstance = nil;

@interface gbisCache ()
    @property (strong, nonatomic) NSMutableDictionary* masterCacheDictionary;
@end

@implementation gbisCache
#pragma mark - Initialization Methods
+ (id)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}


-(id) init {
    if ((self = [super init])) {
        // customize
    }
    return self;
}

- (NSString*) getNormalizedKeyForStoreString:(NSString*)storeString {
    if (kLogIsOn) NSLog(@"cache %@:  %@", NSStringFromSelector(_cmd), storeString);
    NSString* theKey = [storeString lowercaseString];
    theKey = [theKey stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [NSString stringWithFormat:@"%lul", (unsigned long)[theKey hash]];
}

-(void) setSearchResult:(NSDictionary*)theResultSet forStoreString:(NSString*)storeString {
    if (kLogIsOn) NSLog(@"cache %@:  \nstoreString %@ \nresult: %@", NSStringFromSelector(_cmd), storeString, theResultSet);

    if (!_masterCacheDictionary) {
        _masterCacheDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    [_masterCacheDictionary setObject:theResultSet forKey:[self getNormalizedKeyForStoreString:storeString]];
}

-(NSDictionary*) getSearchForStoreString:(NSString*)storeString {
    if (kLogIsOn) NSLog(@"cache %@:  %@", NSStringFromSelector(_cmd), storeString);
    if (!_masterCacheDictionary) {
        _masterCacheDictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    return [_masterCacheDictionary objectForKey:[self getNormalizedKeyForStoreString:storeString]];
    
}

-(BOOL) deleteSearchResultForStoreURLString:(NSString*)storeString {
    if (kLogIsOn) NSLog(@"cache %@: %@", NSStringFromSelector(_cmd), storeString);
    
    NSString* theKey = [self getNormalizedKeyForStoreString:storeString];
    if (!_masterCacheDictionary) {
        return false;
    }
    else if ([_masterCacheDictionary objectForKey:theKey]) {
        [_masterCacheDictionary removeObjectForKey:theKey];
        return true;
    }
    else {
        return false;
    }
}

@end
