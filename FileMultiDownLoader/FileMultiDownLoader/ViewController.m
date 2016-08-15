//
//  ViewController.m
//  FileMultiDownLoader
//
//  Created by Ethank on 16/7/15.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "ViewController.h"
#import "FileMultiDownLoader.h"

#import "FileSessionDownLoader.h"

@interface ViewController ()
@property (nonatomic, strong)FileMultiDownLoader *fileMultiDownLoader;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
- (IBAction)start:(id)sender;
- (IBAction)clear:(id)sender;



@property (nonatomic, assign)BOOL isDownLoading;
@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSURLSessionDownloadTask *downLoadTask;
/**
 *  resumeData记录下载位置
 */
@property (nonatomic, strong) NSData* resumeData;

@property (nonatomic, strong)FileSessionDownLoader *fileSessionDownLoader;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg";
}

- (FileMultiDownLoader *)fileMultiDownLoader {
    if (!_fileMultiDownLoader) {
        _fileMultiDownLoader = [[FileMultiDownLoader alloc] init];
        _fileMultiDownLoader.urlStr = @"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg";
        NSString *caches = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [caches stringByAppendingPathComponent:@"sogou_mac_32c_V3.2.0.1437101586.dmg"];
        _fileMultiDownLoader.filePath = filePath;
        _fileMultiDownLoader.downLoadCount = 4;
        __weak typeof(self)vc = self;
        _fileMultiDownLoader.progressHandle = ^(double progress) {
            vc.progressView.progress = progress;
        };
    }
    return _fileMultiDownLoader;
}

- (IBAction)start:(id)sender {
//    if (!self.fileMultiDownLoader.isDownLoading) {
//        [sender setTitle:@"暂停" forState:UIControlStateNormal];
//        [self.fileMultiDownLoader start];
//    } else {
//        [sender setTitle:@"开始" forState:UIControlStateNormal];
//        [self.fileMultiDownLoader pause];
//    }
    
    //===============fileSessionDownLoader=================
    if (!self.fileSessionDownLoader.isDownLoading) {
        [sender setTitle:@"暂停" forState:UIControlStateNormal];
        [self.fileSessionDownLoader start];
    } else {
        [sender setTitle:@"开始" forState:UIControlStateNormal];
        [self.fileSessionDownLoader pause];
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
    self.progressView.progress = 0;
    //法1
//    [self.fileMultiDownLoader stop];
    //法2
    [self.fileSessionDownLoader stop];
}

////下载文件，但是无法获取下载进度
//- (void)createDownLoader {
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURL *url = [NSURL URLWithString:@"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg"];
//    NSURLSessionDownloadTask *downLoadTask = [session downloadTaskWithURL:url completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
//        NSString *filePath = [path stringByAppendingPathComponent:response.suggestedFilename];
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        [fileManager moveItemAtPath:location.path toPath:filePath error:nil];
//    }];
//    [downLoadTask resume];
//}

- (FileSessionDownLoader *)fileSessionDownLoader {
    if (!_fileSessionDownLoader) {
        _fileSessionDownLoader = [[FileSessionDownLoader alloc] init];
        _fileSessionDownLoader.urlStr = @"http://dlsw.baidu.com/sw-search-sp/soft/9d/25765/sogou_mac_32c_V3.2.0.1437101586.dmg";
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *filePath = [path stringByAppendingPathComponent:@"file"];
        _fileSessionDownLoader.filePath = filePath;
        __weak typeof(self)vc = self;
        _fileSessionDownLoader.progressHandle = ^(double progress) {
            vc.progressView.progress = progress;
        };
    }
    return _fileSessionDownLoader;
}





@end
