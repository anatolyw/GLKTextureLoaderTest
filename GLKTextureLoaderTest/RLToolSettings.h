//
//  RLToolSettings.h
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface RLToolSettings : NSObject 

@property (nonatomic, assign) float brushSize;
@property (nonatomic, assign) float brushStep;
@property (nonatomic, assign) float transparency;

@property (nonatomic, copy)   NSString* brushPath;
@property (nonatomic, assign) BOOL applyPremultiplication;

@property (nonatomic, assign) GLKVector3 color;

+ (RLToolSettings*)shared;

@end
