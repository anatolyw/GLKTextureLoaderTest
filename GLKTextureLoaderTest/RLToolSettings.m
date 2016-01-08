//
//  RLToolSettings.m
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import "RLToolSettings.h"

@implementation RLToolSettings

+ (RLToolSettings*)shared {
    
    static dispatch_once_t once;
    static RLToolSettings * sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    
    if ((self = [super init])) {
        
        // set defaults
        self.brushSize     = 512.0f;
        self.brushStep     = 256.0f;
        self.transparency  = 0.05f;
        
        self.brushPath     = [[NSBundle mainBundle] pathForResource:@"brushRose.png" ofType:nil];
        self.applyPremultiplication = NO;
        
        self.color         = GLKVector3Make(0, 0, 50); // r g b
    }
    
    return self;
}

@end

