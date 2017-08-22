//
//  gbisRetriever.m
//  GBiTunesSearch
//
//  Created by Edward C Ganges on 8/21/17.
//  Copyright © 2017 Edward C Ganges. All rights reserved.
//

#import "gbisRetriever.h"
#import "AppDelegate.h"
#import "gbisCache.h"

@interface gbisRetriever ()
@property (strong, nonatomic) NSString* countryCode;
@property (strong, nonatomic) NSString* storeString;
@property (weak, nonatomic) AppDelegate* appDelegate;
@property (weak, nonatomic) gbisCache* searchCache;
@end

#define kAppStoreLinkUniversal              @"https://itunes.apple.com/search?term=%@&entity=%@"
#define kAppStoreLinkCountrySpecific        @"https://itunes.apple.com/search?term=%@&entity=%@&country=%@"

static id sharedInstance = nil;
@implementation gbisRetriever

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
        _countryCode = @"US";
        _appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    }
    return self;
}

- (void) loadSearchCacheObjectIfNecessary {
    if (!_searchCache) {
        _searchCache = [gbisCache sharedInstance];
    }
}

-(BOOL) retrieveTerm:(NSString*)argTerm forEntity:(NSString*)argEntity {
    if (kLogIsOn) NSLog(@"retriever %@: ", NSStringFromSelector(_cmd));
    
   // validate inputs
    if ([self validateAndBuildStoreURLStringForTerm:argTerm forEntity:argEntity]) {
        
        // check for a cached query
        [self loadSearchCacheObjectIfNecessary];
        NSDictionary* theResultSet = [_searchCache getSearchForStoreString:_storeString];
        if (theResultSet) {
            if (kLogIsOn) NSLog(@"retriever %@: \nCached ResultSet retrieved for %@", NSStringFromSelector(_cmd), _storeString);
            _appDelegate.searchIsLoadedFromCache = true;
            [self postCompletionNotificationForResultSet:theResultSet];
            
        } else {
            // is new query; dispatch Async
            _appDelegate.searchIsLoadedFromCache = false;
            [self performSearchForStoreURLString:_storeString];
            
        }
        return true;
    }
    
    // else op is aborted
    if (kLogIsOn) NSLog(@"retriever %@: FAILED: %@ ", NSStringFromSelector(_cmd), _appDelegate.searchIsAbortedMessage);
    return false;
}

- (BOOL) validateAndBuildStoreURLStringForTerm:(NSString*)theArgTerm forEntity:(NSString*)argEntity {
    if (kLogIsOn) NSLog(@"retriever %@: %@, %@", NSStringFromSelector(_cmd), theArgTerm, argEntity);

    // Trim, and Convert spaces to plus signs (+) in term
    NSString* argTerm = [theArgTerm stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //argTerm = [argTerm stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    if (!argTerm || argTerm.length == 0) {
        _appDelegate.searchIsAborted = true;
        _appDelegate.searchIsAbortedMessage =  @"Search term cannot be empty.";
    }
    
    if (!argEntity || argEntity.length == 0) {
        _appDelegate.searchIsAborted = true;
        _appDelegate.searchIsAbortedMessage =  @"Entity selection cannot be empty.";
    }
    
    if (_appDelegate.searchIsAborted) {
        return false;
    }
    
    
    // URL encrypt the TERM, including symbols iOS traditionally does not encrypt.
    //NSString* encTerm = [argTerm stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"+"]];
    //NSString* encEntity = [argEntity stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    NSString* encTerm = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                              NULL,
                                                                                              (CFStringRef)argTerm,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 ));
    
    // URL encrypt the ENTITY, including symbols iOS traditionally does not encrypt.
    NSString* encEntity = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                NULL,
                                                                                                (CFStringRef)argEntity,
                                                                                                NULL,
                                                                                                (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                kCFStringEncodingUTF8 ));
    
    // build app store url and search string
    if ( [self countryCode] ) {
        _storeString = [NSString stringWithFormat:kAppStoreLinkCountrySpecific, encTerm, encEntity, self.countryCode];
    } else {
        _storeString = [NSString stringWithFormat:kAppStoreLinkUniversal, encTerm, encEntity];
    }
    
    return true;
 }

- (void) performSearchForStoreURLString:(NSString*)storeString {
    if (kLogIsOn) NSLog(@"retriever %@: %@", NSStringFromSelector(_cmd), storeString);
    
    NSURL *storeURL = [NSURL URLWithString:storeString];
    // validate storeURL is NOT NULL
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:storeURL];
    [request setHTTPMethod:@"GET"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
     // dispatch Async
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if ( [data length] > 0 && !error ) { // Success
            
            NSDictionary *appData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if (kLogIsOn) NSLog(@"retriever %@:  appData:\n%@", NSStringFromSelector(_cmd), appData);
            
            // Cache results
            [self loadSearchCacheObjectIfNecessary];
            [_searchCache setSearchResult:appData forStoreString:_storeString];
            
            
            // return the data to main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self postCompletionNotificationForResultSet:appData];
            });
            
        } else {
            _appDelegate.searchIsAborted = true;
            _appDelegate.searchIsAbortedMessage =  @"Failed to receive results from Search Server.";
        }
        
    }];
}

- (void) postCompletionNotificationForResultSet:(NSDictionary*)searchResultSet {
    if (kLogIsOn) NSLog(@"retriever %@: \nsearchResultSet:\n%@ \n%@", NSStringFromSelector(_cmd), searchResultSet, _appDelegate);
    
     NSNotification* note = [NSNotification notificationWithName:kSearchCompletedNotification object:self userInfo:searchResultSet];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}
@end
