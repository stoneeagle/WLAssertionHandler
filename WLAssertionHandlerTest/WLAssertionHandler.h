//
//  WLAssertionHandler.h
//  WLAssertionHandlerTest
//
//  Created by wulei on 2019/1/11.
//  Copyright © 2019 wulei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLAssertionHandler : NSObject

+ (instancetype)shareInstance;

@property (nonatomic, assign) BOOL enable;

@end

NS_ASSUME_NONNULL_END
