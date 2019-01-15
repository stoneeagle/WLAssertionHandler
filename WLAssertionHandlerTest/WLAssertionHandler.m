//
//  WLAssertionHandler.m
//  WLAssertionHandlerTest
//
//  Created by wulei on 2019/1/11.
//  Copyright © 2019 wulei. All rights reserved.
//

#import "WLAssertionHandler.h"
#import <JRSwizzle/JRSwizzle.h>
#import "WLAssertionContext.h"
#import <UIKit/UIKit.h>

@interface WLAssertionHandler () <UIAlertViewDelegate>

@property (atomic, strong) NSMutableArray<WLAssertionContext *> *assertArray;
@property (atomic, strong) NSMutableArray<WLAssertionContext *> *ignoredAssertArray;
@property (atomic, assign) BOOL isPresenting;

- (void)addAssert:(WLAssertionContext *)assert;
- (void)removeAssert:(WLAssertionContext *)assert;
- (void)ignoreAssert:(WLAssertionContext *)assert;

@end

@implementation WLAssertionHandler

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static WLAssertionHandler *hander = nil;
    dispatch_once(&onceToken, ^{
        hander = [WLAssertionHandler new];
        hander.enable = YES;
        hander.assertArray = [NSMutableArray array];
        hander.ignoredAssertArray = [NSMutableArray array];
    });
    return hander;
}

- (void)addAssert:(WLAssertionContext *)assert {
    if (assert == nil) {
        return;
    }
    [self.assertArray addObject:assert];
    [self handleFirstAssert];
}

- (void)removeAssert:(WLAssertionContext *)assert {
    [self.assertArray removeObject:assert];
}

- (void)ignoreAssert:(WLAssertionContext *)assert {
    if (assert == nil) {
        return;
    }
    [self.ignoredAssertArray addObject:assert];
}

- (void)handleFirstAssert {
    if (self.assertArray.count == 0 ||
        self.isPresenting) {
        return;
    }
    
    WLAssertionContext *first = [self.assertArray firstObject];
    if ([self.ignoredAssertArray containsObject:first]) {
        [self removeAssert:first];
        [self handleFirstAssert];
        return;
    }
    self.isPresenting = YES;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"断言"
                                                        message:first.description
                                                       delegate:self
                                              cancelButtonTitle:@"打印堆栈"
                                              otherButtonTitles:@"忽略此次", @"忽略此条", nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alertView show];
    });
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    WLAssertionContext *first = [self.assertArray firstObject];
    [self removeAssert:first];
    switch (buttonIndex) {
        case 0:             //cancel
            NSLog(@"WLAssertionHandler call symbols:\n %@", first.callStackSymbols);
            break;
        case 1:
            break;
        case 2:
            [self ignoreAssert:first];
            break;
        default:
            break;
    }
    self.isPresenting = NO;
    [self handleFirstAssert];
}

@end



#pragma mark - NSAssertionHandler Hook
@interface NSAssertionHandler (WLHook)
@end

@implementation NSAssertionHandler (WLHook)

+ (void)load {
    [self jr_swizzleMethod:@selector(handleFailureInMethod:object:file:lineNumber:description:) withMethod:@selector(wl_handleFailureInMethod:object:file:lineNumber:description:) error:nil];
    [self jr_swizzleMethod:@selector(handleFailureInFunction:file:lineNumber:description:) withMethod:@selector(wl_handleFailureInFunction:file:lineNumber:description:) error:nil];
}

- (void)wl_handleFailureInMethod:(SEL)selector
                          object:(id)object
                            file:(NSString *)fileName
                      lineNumber:(NSInteger)line
                     description:(NSString *)format, ... {
    
    va_list ap;
    va_start(ap, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    
    if (![WLAssertionHandler shareInstance].enable) {
        [self wl_handleFailureInMethod:selector
                                object:object
                                  file:fileName
                            lineNumber:line
                           description:description];
        return;
    }
    
    WLAssertionMethodContext *assert = [[WLAssertionMethodContext alloc]
                                        initWithFile:fileName
                                        lineNumber:line
                                        message:description
                                        object:object
                                        selector:selector];
    NSArray<NSString *> *callStackSymbols = [NSThread callStackSymbols];
    assert.callStackSymbols = [callStackSymbols subarrayWithRange:NSMakeRange(1, callStackSymbols.count - 1)];
    [[WLAssertionHandler shareInstance] addAssert:assert];
}

- (void)wl_handleFailureInFunction:(NSString *)functionName
                              file:(NSString *)fileName
                        lineNumber:(NSInteger)line
                       description:(NSString *)format, ... {
    va_list ap;
    va_start(ap, format);
    NSString *description = [[NSString alloc] initWithFormat:format arguments:ap];
    va_end(ap);
    if (![WLAssertionHandler shareInstance].enable) {
        [self wl_handleFailureInFunction:functionName
                                    file:fileName
                              lineNumber:line
                             description:description];
        return;
    }
    WLAssertionFunctionContext *assert = [[WLAssertionFunctionContext alloc]
                                          initWithFile:fileName
                                          lineNumber:line
                                          message:description
                                          function:functionName];
    NSArray<NSString *> *callStackSymbols = [NSThread callStackSymbols];
    assert.callStackSymbols = [callStackSymbols subarrayWithRange:NSMakeRange(1, callStackSymbols.count - 1)];
    [[WLAssertionHandler shareInstance] addAssert:assert];
}

@end
