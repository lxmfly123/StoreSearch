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
@property (nonatomic, copy) NSString *sellerName;
@property (nonatomic, copy) NSString *artworkURL60;
@property (nonatomic, copy) NSString *artworkURL512;
@property (nonatomic, copy) NSString *trackViewUrl;
@property (nonatomic, copy) NSString *kind;
@property (nonatomic, copy) NSString *currency;
@property (nonatomic, copy) NSString *price;
@property (nonatomic, copy) NSArray *genres;
//@property (nonatomic, strong) UIImage *image;
//@property (nonatomic, copy)

@end
