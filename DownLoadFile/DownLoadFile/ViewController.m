//
//  ViewController.m
//  DownLoadFile
//
//  Created by Ethank on 16/7/14.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "ViewController.h"
#import "DownLoadManager.h"

@interface ViewController ()
@property (nonatomic, strong)DownLoadManager *downLoader;
@property (weak, nonatomic) IBOutlet UIProgressView *preogressView;

- (IBAction)start:(id)sender;
- (IBAction)clear:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (DownLoadManager *)downLoader {
    if (!_downLoader) {
        _downLoader = [[DownLoadManager alloc] init];
        _downLoader.urlStr = @"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg";
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [path stringByAppendingPathComponent:@"sogou_mac_32c_V3.2.0.1437101586.dmg"];
        _downLoader.filePath = filePath;
        __weak typeof(self)vc = self;
        _downLoader.progressHandle = ^(double progress) {
            vc.preogressView.progress = progress;
        };
        _downLoader.completionHandle = ^{
            NSLog(@"下载完成");
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
            });
        };
        _downLoader.failureHandle = ^(NSError *error) {
            
        };
    }
    return _downLoader;
}
- (IBAction)start:(id)sender {
    if (!self.downLoader.isDownLoading) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.downLoader start];
    } else {
        [sender setTitle:@"开始" forState:UIControlStateNormal];
        [self.downLoader pause];
    }
}

- (IBAction)clear:(id)sender {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
    self.preogressView.progress = 0;
    [self.downLoader stop];
}


@end
