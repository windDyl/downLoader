//
//  FileMultiDownLoader.m
//  FileMultiDownLoader
//
//  Created by Ethank on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "FileMultiDownLoader.h"
#import "FileSingleDownLoader.h"

@interface FileMultiDownLoader ()
@property (nonatomic, strong)NSMutableArray *fileSingleDownLoaders;
@property (nonatomic, assign)long long totalLength;
@end

@implementation FileMultiDownLoader
- (void)getFileSize {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.urlStr]];
    request.HTTPMethod = @"HEAD";
    NSURLResponse *response = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    self.totalLength = response.expectedContentLength;
}

- (NSMutableArray *)fileSingleDownLoaders {
    if (!_fileSingleDownLoaders) {
        _fileSingleDownLoaders = [NSMutableArray array];
        //获取下载文件的大小
        [self getFileSize];
        //每条路径的下载量
        long long size = 0;
        if (self.totalLength % self.downLoadCount == 0) {
            size = self.totalLength / self.downLoadCount;
        } else {
            size = self.totalLength / self.downLoadCount + 1;
        }
        //创建下载器
        __block double total_progress = 0;
        __block double pro0 = 0;
        __block double pro1 = 0;
        __block double pro2 = 0;
        __block double pro3 = 0;
        __block int count = 0;
        __weak typeof(self)vc = self;
        for (int i = 0; i < self.downLoadCount; i++) {
            FileSingleDownLoader *fileSingleDownLoader = [[FileSingleDownLoader alloc] init];
            fileSingleDownLoader.urlStr = self.urlStr;
            fileSingleDownLoader.filePath = self.filePath;
            fileSingleDownLoader.begin = i * size;
            fileSingleDownLoader.end = fileSingleDownLoader.begin + size - 1;
            fileSingleDownLoader.progressHandle = ^(double progress) {
                switch (i) {
                    case 0:{
                        total_progress += (progress - pro0);
                        pro0 = progress;
                        break;
                    }
                    case 1:{
                        total_progress += (progress - pro1);
                        pro1 = progress;
                        break;
                    }
                    case 2:{
                        total_progress += (progress - pro2);
                        pro2 = progress;
                        break;
                    }
                    case 3:{
                        total_progress += (progress - pro3);
                        pro3 = progress;
                        break;
                    }
                    default:
                        break;
                }
                count ++;
                if (count == 4) {
                    count = 0;
                    if (vc.progressHandle) {
                        vc.progressHandle(total_progress/vc.downLoadCount);
                        NSLog(@"================%f==============", total_progress/vc.downLoadCount);
                    }
                }
            };
            [_fileSingleDownLoaders addObject:fileSingleDownLoader];
            
            // 创建一个跟服务器文件等大小的临时文件
            [[NSFileManager defaultManager] createFileAtPath:self.filePath contents:nil attributes:nil];
            
            // 让self.destPath文件的长度是self.totalLengt
            NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
            [handle truncateFileAtOffset:self.totalLength];
        }
        
    }
    return _fileSingleDownLoaders;
}

/**
 * 开始(恢复)下载
 */
- (void)start {
    [self.fileSingleDownLoaders makeObjectsPerformSelector:@selector(start)];
     _downLoading = YES;
}

/**
 * 暂停下载
 */
- (void)pause {
    [self.fileSingleDownLoaders makeObjectsPerformSelector:@selector(pause)];
    _downLoading = NO;
}
/**
 * 停止并删除已下载
 */
- (void)stop {
    [self.fileSingleDownLoaders makeObjectsPerformSelector:@selector(stop)];
    _downLoading = NO;
}

@end
