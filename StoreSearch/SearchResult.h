//
//  SearchResult.h
//  StoreSearch
//
//  Created by FLY.lxm on 11/10/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchResult : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, copy) NSString *artworkURL60;
@property (nonatomic, copy) NSString *artworkURL100;
@property (nonatomic, copy) NSString *artworkURL512; //仅用于 App
@property (nonatomic, copy) NSString *trackViewUrl;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *price; //仅用于 App
@property (nonatomic, copy) NSArray *genres;
@property (nonatomic, copy) NSString *storeUrl;

- (NSString *)kindForDisplay;

@end
