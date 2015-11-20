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
@property (nonatomic, readonly, strong) NSArray *searchResult;

- (void)performSearchForText:(NSString *)text category:(NSInteger)category;

@end
