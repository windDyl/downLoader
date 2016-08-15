//
//  FileSessionDownLoader.m
//  FileMultiDownLoader
//
//  Created by Ethank on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "FileSessionDownLoader.h"

@interface FileSessionDownLoader()<NSURLSessionDelegate>
@property (nonatomic, strong)NSURLSession *session;
@property (nonatomic, strong)NSURLSessionDownloadTask *downLoadTask;
/**
 *  resumeData记录下载位置
 */
@property (nonatomic, strong) NSData* resumeData;
@end

@implementation FileSessionDownLoader

/**
 * 暂停下载
 */
- (void)pause {
    __weak typeof(self)vc = self;
    [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        vc.resumeData = resumeData;
        vc.downLoadTask = nil;
        _downLoading = NO;
    }];
}
/**
 * 开始(恢复)下载
 */
- (void)start {
    _downLoading = YES;
    if (!self.downLoadTask && !self.resumeData) {
        [self.downLoadTask resume];
    } else {
        self.downLoadTask = [self.session downloadTaskWithResumeData:self.resumeData];
        [self.downLoadTask resume];
        self.resumeData = nil;
    }
}
/**
 * 取消下载，并清除已下载的
 */
- (void)stop {
    __weak typeof(self)vc = self;
    [self.downLoadTask cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
        vc.resumeData = nil;
        vc.downLoadTask = nil;
        _downLoading = NO;
        vc.session = nil;
    }];
}

-(NSURLSession *)session {
    if (!_session) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _session;
}

-(NSURLSessionDownloadTask *)downLoadTask {
    if (!_downLoadTask) {
        NSURL *url = [NSURL URLWithString:self.urlStr];
        _downLoadTask = [self.session downloadTaskWithURL:url];
    }
    return _downLoadTask;
}

#pragma mark -NSURLSessionDownloadDelegate
/**
 *  下载完毕后会调用
 *  @param location     文件临时地址
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)location {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager moveItemAtPath:location.path toPath:self.filePath error:nil];
}
/**
 *  每次写入沙盒后调用
 *  在这里监听下载进度   totalBytesWritten/totalBytesExpectedToWrite
 *
 *  @param bytesWritten              本次写入的大小
 *  @param totalBytesWritten         已经写入沙盒的大小
 *  @param totalBytesExpectedToWrite 文件总大小
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    double progress = (double)totalBytesWritten /totalBytesExpectedToWrite;
    if (self.progressHandle) {
        self.progressHandle(progress);
        NSLog(@"=====%f======", progress);
    }
}
/**
 *  恢复下载调用
 */
- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes {
    
}
@end
