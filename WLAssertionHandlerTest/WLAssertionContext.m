//
//  WLAssertionContext.m
//  WLAssertionHandlerTest
//
//  Created by wulei on 2019/1/14.
//  Copyright © 2019 wulei. All rights reserved.
//

#import "WLAssertionContext.h"

@interface WLAssertionContext ()

@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, assign) NSInteger line;
@property (nonatomic, copy) NSString *message;

@end

@implementation WLAssertionContext

- (instancetype)initWithFile:(NSString *)fileName
                  lineNumber:(NSInteger)line
                     message:(NSString *)message {
    self = [super init];
    if (self) {
        _fileName = fileName;
        _line = line;
        _message = message;
    }
    return self;
}

- (BOOL)isEqual:(id)object {
    if (![object isKindOfClass:self.class]) {
        return NO;
    }
    WLAssertionContext *other = (WLAssertionContext *)object;
    if ([_fileName isEqual:other.fileName] &&
        _line == other.line) {
        return YES;
    }
    return NO;
}

- (NSString *)description {
    return [super description];
}

@end

@interface WLAssertionMethodContext ()

@property (nonatomic, strong) id object;
@property (nonatomic, assign) SEL selector;

@end

@implementation WLAssertionMethodContext

- (instancetype)initWithFile:(NSString *)fileName
                  lineNumber:(NSInteger)line
                     message:(NSString *)message
                      object:(id)object
                    selector:(SEL)selector {
    self = [super initWithFile:fileName
                    lineNumber:line
                       message:message];
    if (self) {
        _object = object;
        _selector = selector;
    }
    return self;
}

- (NSString *)description {
    NSArray *itemInfos = @
    [
     self.message,
     @"",
     [NSString stringWithFormat:@"[%@ %@]",
      [self.object class],
      NSStringFromSelector(self.selector)],
     [NSString stringWithFormat:@"line %zd in %@",
      self.line,
      self.fileName]
     ];
    
    return [itemInfos componentsJoinedByString:@"\n"];
}

@end

@interface WLAssertionFunctionContext ()

@property (nonatomic, copy) NSString *function;

@end

@implementation WLAssertionFunctionContext

- (instancetype)initWithFile:(NSString *)fileName
                  lineNumber:(NSInteger)line
                     message:(NSString *)message
                    function:(NSString *)function {
    self = [super initWithFile:fileName
                    lineNumber:line
                       message:message];
    if (self) {
        _function = function;
    }
    return self;
}

- (NSString *)description {
    NSArray *itemInfos = @
    [
     self.message,
     @"",
     [NSString stringWithFormat:@"%@",
      self.function],
     [NSString stringWithFormat:@"line %zd in %@",
      self.line,
      self.fileName]
     ];
    
    return [itemInfos componentsJoinedByString:@"\n"];
}

@end
