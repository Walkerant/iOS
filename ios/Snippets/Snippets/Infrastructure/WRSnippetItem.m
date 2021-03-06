//
//  WRSnippetItem.m
//  Snippets
//
//  Created by Walker on 2020/11/10.
//  Copyright © 2020 Walker. All rights reserved.
//

#import "WRSnippetItem.h"
#import <UIKit/UIViewController.h>

@implementation WRSnippetItem{
    id viewController;
}

+ (instancetype)itemWithName:(NSString *)name viewControllerClassName:(NSString *)className detail:(nonnull NSString *)detailDesc{
    return [[self alloc] initWithName:name
              viewControllerClassName:className
                           detailDesc:detailDesc
                             selector:nil
                       selectorTarget:nil
                       selectorObject:nil
                              handler:nil];
}

+ (instancetype)itemWithName:(NSString *)name detail:(NSString *)detailDesc selector:(SEL)aSelector target:(id)target object:(id)obj{
    return [[self alloc] initWithName:name
              viewControllerClassName:@""
                           detailDesc:detailDesc
                             selector:aSelector
                       selectorTarget:target
                       selectorObject:obj
                              handler:nil];
}

+ (instancetype)itemWithName:(NSString *)name detail:(NSString *)detailDesc block:(void (^)(void))handler{
    return [[self alloc] initWithName:name
              viewControllerClassName:@""
                           detailDesc:detailDesc
                             selector:nil
                       selectorTarget:nil
                       selectorObject:nil
                              handler:handler];
}

- (instancetype)initWithName:(NSString*)name
     viewControllerClassName:(NSString*)className
                  detailDesc:(NSString*)detailDesc
                    selector:(SEL)aSelector
              selectorTarget:(id)target
              selectorObject:(id)obj
                     handler:(id)handler{
    if ((self = [super init])) {
        self.name = name;
        self.viewControllerClassName = className;
        self.detailedDescription = detailDesc;
        self.aSelector = aSelector;
        self.handler = handler;
        self.selectorTarget = target;
        self.selectorObject = obj;
    }
    return self;
}

- (void)start{
    if (self.aSelector) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.selectorTarget performSelector:self.aSelector withObject:self.selectorObject];
#pragma clang diagnostic pop
    } else if (self.handler) {
        [NSThread detachNewThreadWithBlock:^{
            self.handler();
        }];
    }
}

- (id)relatedViewController{
    if (self.viewControllerClassName.length>0 && !viewController) {
        viewController = [[NSClassFromString(self.viewControllerClassName) alloc] init];
        [viewController setTitle:self.name];
    }
    return viewController;
}

- (BOOL)isEqual:(id)object{
    if (![object isMemberOfClass:[WRSnippetItem class]])
        return NO;
    
    WRSnippetItem *other = (WRSnippetItem*)object;
    
    BOOL nameIsEqual = self.name == other.name || [self.name isEqualToString:other.name];
    BOOL classIsEqual = [self.relatedViewController isEqualToString:other.relatedViewController];
    BOOL selIsEqual = self.aSelector == other.aSelector;
    
    return nameIsEqual && (classIsEqual || selIsEqual);
}

- (NSUInteger)hash{
    return self.name.hash ^ self.detailedDescription.hash;
}

- (id)copyWithZone:(NSZone *)zone{
    return [[WRSnippetItem alloc] initWithName:self.name
                       viewControllerClassName:self.viewControllerClassName
                                    detailDesc:self.detailedDescription
                                      selector:self.aSelector
                                selectorTarget:self.selectorTarget
                                selectorObject:self.selectorObject
                                       handler:self.handler];
}

@end
