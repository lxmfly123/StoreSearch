//
//  Search.h
//  StoreSearch
//
//  Created by FLY.lxm on 11/20/15.
//  Copyright © 2015 FLY.lxm. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Search : NSObject

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, readonly, strong) NSMutableArray *searchResults;
@property (nonatomic, copy) NSString *test;

typedef void (^SearchBlock)(BOOL success);

- (void)performSearchForText:(NSString *)text category:(NSInteger)category completion:(SearchBlock)block;

@end
