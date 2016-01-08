//
//  RLGLKView.m
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import "RLGLKView.h"

#import "RLEmmiterBrush.h"
#import "RLToolSettings.h"

@implementation RetainedEAGLLayer

- (void)setDrawableProperties:(NSDictionary *)drawableProperties {
    // Copy the dictionary and add/modify the retained property
    NSMutableDictionary *mutableDictionary = [[NSMutableDictionary alloc] initWithCapacity:drawableProperties.count + 1];
    [drawableProperties enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        // Copy all keys except the retained backing
        if (![key isKindOfClass:[NSString class]]
            || ![(NSString *)key isEqualToString:kEAGLDrawablePropertyRetainedBacking])
            [mutableDictionary setObject:object forKey:key];
    }];
    // Add the retained backing setting
    [mutableDictionary setObject:@(YES) forKey:kEAGLDrawablePropertyRetainedBacking];
    // Continue
    [super setDrawableProperties:mutableDictionary];
}

@end

@interface RLRetainedGLKView ()

@property (strong) GLKBaseEffect * effect;
@property (strong) RLEmmiterBrush* emitter;

@end

@implementation RLRetainedGLKView {
    Boolean needsErase;
    GLenum sfactor;
    GLenum dfactor;
    GLenum equation;
}

+ (Class)layerClass {
    return [RetainedEAGLLayer class];
}

#pragma mark - Life-Cycle

- (id)initWithFrame:(CGRect)frame context:(EAGLContext *)context {
    
    NSLog(@"RLRetainedGLKView: initWithFrame = %@", NSStringFromCGRect(frame));
    
    if ((self = [super initWithFrame:frame context:context])) {
        
        self.delegate           = self;
        self.contentScaleFactor = [[UIScreen mainScreen] scale];
        self.backgroundColor    = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    
    NSLog(@"RLRetainedGLKView: layoutSubviews = %@", NSStringFromCGRect(self.frame));
    
    // use self.effect as marker in order to execute initialization code below just once
    if (!self.effect) {
        
        self.effect = [[GLKBaseEffect alloc] init];
        
        CGRect frame = self.frame;
        GLKMatrix4 projectionMatrix;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            float w = frame.size.height > frame.size.width ? frame.size.height : frame.size.width;
            float h = frame.size.height < frame.size.width ? frame.size.height : frame.size.width;
            NSLog(@"projectionMatrix = %@", NSStringFromCGRect(CGRectMake(0, w * self.contentScaleFactor,
                                                                          0, h * self.contentScaleFactor)));
            projectionMatrix = GLKMatrix4MakeOrtho(0, w * self.contentScaleFactor,
                                                   0, h * self.contentScaleFactor,
                                                   -1024, 1024); //Ex: (0, 640, 0, 960, -1024, 1024) // left, right, bottom, top, nearZ, farZ
        } else {
            NSLog(@"projectionMatrix = %@", NSStringFromCGRect(CGRectMake(0, frame.size.width * self.contentScaleFactor,
                                                                          0, frame.size.height * self.contentScaleFactor)));
            projectionMatrix = GLKMatrix4MakeOrtho(0, frame.size.width * self.contentScaleFactor,
                                                   0, frame.size.height * self.contentScaleFactor,
                                                   -1024, 1024); //Ex: (0, 640, 0, 960, -1024, 1024) // left, right, bottom, top, nearZ, farZ
        }
        self.effect.transform.projectionMatrix = projectionMatrix;
        
        // Make sure to start with a cleared buffer
        needsErase = YES;
        
        [self updateBlendingMode];
        
        [self updateBrush];
    }

    [self setNeedsDisplay];
}

#pragma mark - ToolDelegate

- (UIView*)viewForUseWithTool {
    return self;
}

- (void)renderLineFromPoint:(CGPoint)start toPoint:(CGPoint)end {
    
    NSLog(@"renderLine: start=%@, end=%@", NSStringFromCGPoint(start), NSStringFromCGPoint(end));

    if (nil == _emitter) {
        [self updateBrush];
    }

    [_emitter renderWithModelViewMatrix:GLKMatrix4Identity fromPoint:start toPoint:end];
    
    [self setNeedsDisplay];
}

#pragma mark - Public Interface

- (void)clear {
    [EAGLContext setCurrentContext:self.context];
    needsErase = YES;
    [self setNeedsDisplay];
}

- (void)updateBlendingMode {
    
    [EAGLContext setCurrentContext:self.context];
    
    equation = 0;
    sfactor = GL_ONE;
    dfactor = GL_ONE_MINUS_SRC_ALPHA;
    
    glBlendFunc(sfactor, dfactor);
    glEnable(GL_BLEND);
}

- (void)updateBrush {
    [EAGLContext setCurrentContext:self.context];
    self.emitter = [[RLEmmiterBrush alloc] initWithProjectionMatrix:self.effect.transform.projectionMatrix];
}

#pragma mark - GLKViewDelegate

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    if (needsErase) {
        needsErase = NO;
        NSLog(@"needsErase");
        glClearColor(0.0, 0.0, 0.0, 0.0);
        glClear(GL_COLOR_BUFFER_BIT );
        
        glBlendFunc(sfactor, dfactor);
        glEnable(GL_BLEND);
    }
}

@end
