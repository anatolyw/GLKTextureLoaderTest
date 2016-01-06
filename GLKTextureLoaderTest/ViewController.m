//
//  ViewController.m
//  GLKTextureLoaderTest
//
//  Created by Anatoly Weinstein on 06/01/16.
//  Copyright © 2016 Anatoly Weinstein. All rights reserved.
//

#import "ViewController.h"

#import "RLGLKView.h"
#import "RLEmmiterBrushTool.h"
#import "RLToolSettings.h"

@interface ViewController ()
@property (strong) EAGLContext* context;
@property (strong) RLRetainedGLKView *activeGlView;

@property (strong) IBOutlet UIButton *btn1;
@property (strong) IBOutlet UIButton *btn2;
@property (strong) IBOutlet UIButton *btn3;
@property (strong) IBOutlet UIButton *btn4;
@property (strong) IBOutlet UIButton *btn5;
@property (strong) IBOutlet UIButton *btn6;

@end

@implementation ViewController {
    RLEmmiterBrushTool* _drawingTool;
    NSString* _downloadedBrushName;
}

#pragma mark - Helper

- (void)setDefaultBrushFromBundle {
    [RLToolSettings shared].brushPath = [[NSBundle mainBundle] pathForResource:@"brushRose.png" ofType:nil];
    [_drawingTool.drawingView updateBrush];
}

- (void)setDownloadedBrush {
    [RLToolSettings shared].brushPath = _downloadedBrushName;
    [_drawingTool.drawingView updateBrush];
}

- (NSString*)brushesDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES);
    NSString *documentsDirectory = paths[0];
    NSString *brushesDirectory = [documentsDirectory stringByAppendingPathComponent:@"brushes"];
    return brushesDirectory;
}

- (void)downloadRemoteBrush {
    
    NSString* brushURL = @"http%3A%2F%2Fwww.raptlook.com%2Fproducts%2Fadhoc%2Fbrushes%2Fps_roses.png";
    NSLog(@"brushURLencoded=%@", brushURL);
    NSString *brushURLdecoded = [brushURL stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"brushURLdecoded=%@", brushURLdecoded);
    
    NSString *brushName = [brushURLdecoded componentsSeparatedByString:@"/"].lastObject;
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURLSessionDownloadTask *getImageTask =
    [session downloadTaskWithURL:[NSURL URLWithString:brushURLdecoded]
               completionHandler:^(NSURL *location,
                                   NSURLResponse *response,
                                   NSError *error) {
                   UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                   if (downloadedImage) {
                       
                       [[NSFileManager defaultManager] createDirectoryAtPath:[self brushesDirectory]
                                                 withIntermediateDirectories:YES
                                                                  attributes:nil
                                                                       error:NULL];
                       
                       // can be done directly after getting dataWithContentsOfURL
                       NSData *photoData = UIImagePNGRepresentation(downloadedImage);
                       _downloadedBrushName = [[self brushesDirectory] stringByAppendingPathComponent:brushName];
                       [photoData writeToFile:_downloadedBrushName atomically:YES];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           self.btn2.enabled = YES;
                       });
                   }
               }];
    [getImageTask resume];

}

#pragma mark - View Life-Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    RLRetainedGLKView *layerView = [[RLRetainedGLKView alloc] initWithFrame:self.view.bounds context:self.context];
    layerView.multipleTouchEnabled = YES;
    self.activeGlView = layerView;
    [self.view insertSubview:self.activeGlView atIndex:0];
    
    _drawingTool = [[RLEmmiterBrushTool alloc] init];
    _drawingTool.drawingView = self.activeGlView;
    
    [self setDefaultBrushFromBundle];
    
    [self downloadRemoteBrush];
}

#pragma mark - Actions

- (IBAction)btn1Action:(id)sender {
    [self setDefaultBrushFromBundle];
}
- (IBAction)btn2Action:(id)sender {
    [self setDownloadedBrush];
}
- (IBAction)btn3Action:(id)sender {
    [RLToolSettings shared].color = GLKVector3Make(50, 0, 0);
}
- (IBAction)btn4Action:(id)sender {
    [RLToolSettings shared].color = GLKVector3Make(0, 50, 0);
}
- (IBAction)btn5Action:(id)sender {
    [RLToolSettings shared].color = GLKVector3Make(0, 0, 50);
}
- (IBAction)btn6Action:(id)sender {
    [_drawingTool.drawingView clear];
}

#pragma mark - Touch handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    _drawingTool.isFirstRendered = NO;
    [_drawingTool touchBegan:[touches anyObject]];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [_drawingTool touchMoved:[touches anyObject]];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [_drawingTool touchEnded:[touches anyObject]];
}


@end
