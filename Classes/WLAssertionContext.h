//
//  WLAssertionContext.h
//  WLAssertionHandlerTest
//
//  Created by wulei on 2019/1/14.
//  Copyright © 2019 wulei. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface WLAssertionContext : NSObject

@property (nonatomic, copy, readonly) NSString *fileName;
@property (nonatomic, assign, readonly) NSInteger line;
@property (nonatomic, copy, readonly) NSString *message;
@property (nonatomic, strong) NSArray<NSString *> *callStackSymbols;

- (instancetype)initWithFile:(NSString *)fileName
                  lineNumber:(NSInteger)line
                     message:(NSString *)message;

@end

@interface WLAssertionMethodContext : WLAssertionContext

@property (nonatomic, strong, readonly) id object;
@property (nonatomic, assign, readonly) SEL selector;

- (instancetype)initWithFile:(NSString *)fileName
                  lineNumber:(NSInteger)line
                     message:(NSString *)message
                      object:(id)object
                    selector:(SEL)selector;

@end

@interface WLAssertionFunctionContext : WLAssertionContext

@property (nonatomic, copy, readonly) NSString *function;

- (instancetype)initWithFile:(NSString *)fileName
                  lineNumber:(NSInteger)line
                     message:(NSString *)message
                    function:(NSString *)function;

@end

NS_ASSUME_NONNULL_END
