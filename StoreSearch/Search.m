//
//  Search.m
//  StoreSearch
//
//  Created by FLY.lxm on 11/20/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import "Search.h"
#import "SearchResult.h"
#import <AFNetworking/AFNetworking.h>

static NSOperationQueue *queue = nil;

@interface Search ()

@property (nonatomic, readwrite, strong) NSMutableArray *searchResults;

@end

@implementation Search

+ (void)initialize {
    if (self == [Search class]) {
        queue = [[NSOperationQueue alloc] init];
    }
}

- (void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block {
    if ([text length] > 0) {
        [queue cancelAllOperations];
        
        self.isLoading = YES;
        self.searchResults = [NSMutableArray arrayWithCapacity:20];
        
        NSURL *url = [self urlWithSearchText:text category:category];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        operation.responseSerializer = [AFJSONResponseSerializer serializer];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
            [self parseDictionary:responseObject];
            self.isLoading = NO;
            block(YES);
            
        } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
            self.isLoading = NO;
            block(NO);
            if (operation.isCancelled) {
                return;
            }
        }];
        
        [queue addOperation:operation];
    } else { // These code is left off in refaction
        self.searchResults = nil;
    }

}

- (NSURL *)urlWithSearchText:(NSString *)text category:(NSInteger)category {
    NSString *categoryName;
    switch (category) {
        case 0:
            categoryName = @"software";
            break;
            
        case 1:
            categoryName = @"musicTrack";
            break;
            
        default:
            break;
    }
    
    NSString *encodedText = [text stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];
    
    NSURL *searchURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/search?term=%@&country=cn&entity=%@&limit=50", encodedText, categoryName]];
    return searchURL;
}

- (SearchResult *)parseApp:(NSDictionary *)resultDictionary {
    SearchResult *searchResult = [SearchResult new];
    
    searchResult.name = resultDictionary[@"trackCensoredName"];
    searchResult.artistName = resultDictionary[@"artistName"];
    searchResult.artworkURL60 = resultDictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = resultDictionary[@"artworkUrl100"];
    searchResult.artworkURL512 = resultDictionary[@"artworkUrl512"];
    searchResult.trackViewUrl = resultDictionary[@"trackViewUrl"];
    searchResult.kind = resultDictionary[@"kind"];
    searchResult.currency = resultDictionary[@"currency"];
    searchResult.price = resultDictionary[@"formattedPrice"];
    searchResult.genres = (NSArray *)resultDictionary[@"genres"];
    searchResult.storeUrl = resultDictionary[@"trackViewUrl"];
    //    searchResult.image = [UIImage imageWithData:<#(nonnull NSData *)#>]
    
    return searchResult;
}

- (SearchResult *)parseMusic:(NSDictionary *)resultDictionary {
    SearchResult *searchResult = [SearchResult new];
    
    searchResult.name = resultDictionary[@"trackCensoredName"];
    searchResult.artistName = resultDictionary[@"artistName"];
    searchResult.artworkURL60 = resultDictionary[@"artworkUrl60"];
    searchResult.artworkURL100 = resultDictionary[@"artworkUrl100"];
    searchResult.trackViewUrl = resultDictionary[@"trackViewUrl"];
    searchResult.kind = resultDictionary[@"kind"];
    searchResult.currency = resultDictionary[@"currency"];
    searchResult.price = @"免费";
    searchResult.genres = @[resultDictionary[@"primaryGenreName"]];
    searchResult.storeUrl = resultDictionary[@"trackViewUrl"];
    
    return searchResult;
}

- (void)parseDictionary:(NSDictionary *)dictionary {
    NSArray *array = dictionary[@"results"];
    
    if (array == nil) {
        return;
    }
    
    for (NSDictionary *resultDictionary in array) {
        SearchResult *searchResult;
        
        NSString *wrapperType = resultDictionary[@"wrapperType"];
        
        if ([wrapperType isEqualToString:@"software"]) { 
            searchResult = [self parseApp:resultDictionary];
            [self.searchResults addObject:searchResult];
        } else if ([wrapperType isEqualToString:@"track"]) {
            searchResult = [self parseMusic:resultDictionary];
            [self.searchResults addObject:searchResult];
        }
    }
}

- (void)dealloc {
    NSLog(@"Dealloc %@", self);
}

@end
