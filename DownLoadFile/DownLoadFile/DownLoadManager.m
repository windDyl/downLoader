//
//  DownLoadManager.m
//  DownLoadFile
//
//  Created by Ethank on 16/7/14.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "DownLoadManager.h"

@interface DownLoadManager ()<NSURLConnectionDataDelegate>
/**
 * 连接对象
 */
@property (nonatomic, strong)NSURLConnection *connect;
/**
 *  写数据的文件句柄
 */
@property (nonatomic, strong)NSFileHandle *writeHandle;
/**
 *  当前已下载的长度
 */
@property (nonatomic, assign) long long currentLength;
/**
 *  完整文件的总长度
 */
@property (nonatomic, assign) long long totalLength;
@end

@implementation DownLoadManager
/**
 * 开始(恢复)下载
 */
- (void)start {
    NSURL *url = [NSURL URLWithString:self.urlStr];
    // 默认就是GET请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求头信息
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-",self.currentLength] forHTTPHeaderField:@"Range"];//设置断点续传的起点及范围
    self.connect = [NSURLConnection connectionWithRequest:request delegate:self];
    _downLoading = YES;
}
/**
 * 暂停下载
 */
- (void)pause {
    [self.connect cancel];
    self.connect = nil;
    _downLoading = NO;
    [self.writeHandle closeFile];
    self.writeHandle = nil;
}
/**
 * 取消下载，并清除已下载的
 */
- (void)stop {
    [self pause];
    self.currentLength = 0;
    self.totalLength = 0;
}

#pragma mark -NSURLConnectionDataDelegate
//当请求出错，调用
- (void)connection:(NSURLConnection *)connection didFailWithError:(nonnull NSError *)error {
    if (self.failureHandle) {
        self.failureHandle(error);
    }
}
//当接收服务器响应，调用
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (self.totalLength) return;
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // 1.创建一个空的文件到沙盒中   刚创建完毕的大小是0字节
    [manager createFileAtPath:self.filePath contents:nil attributes:nil];
    // 2.创建写数据的文件句柄
    self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    // 3.获得完整文件的长度
    self.totalLength = response.expectedContentLength;
}
//当接受到服务器数据，调用（可多次调用）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 累加长度
    self.currentLength += data.length;
    // 显示进度
    double progress = (double)self.currentLength / self.totalLength;
    if (self.progressHandle) {
        self.progressHandle(progress);
    }
    NSLog(@"===%lld===%lld===%f===", self.currentLength, self.totalLength,progress);
    // 移动到文件的尾部
    [self.writeHandle seekToEndOfFile];
    // 从当前移动的位置(文件尾部)开始写入数据
    [self.writeHandle writeData:data];
}
//当服务器数据接收完毕，调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // 清空属性值
    self.currentLength = 0;
    self.totalLength = 0;
    if (self.currentLength == self.totalLength) {
        // 关闭连接(不再输入数据到文件中)
        [self.writeHandle closeFile];
        self.writeHandle = nil;
    }
    if (self.completionHandle) {
        self.completionHandle();
    }
}

@end
