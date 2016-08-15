//
//  FileSingleDownLoader.m
//  FileMultiDownLoader
//
//  Created by Ethank on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "FileSingleDownLoader.h"

@interface FileSingleDownLoader ()
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

@end

@implementation FileSingleDownLoader

/**
 * 开始(恢复)下载
 */
- (void)start {
    NSURL *url = [NSURL URLWithString:self.urlStr];
    // 默认就是GET请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    // 设置请求头信息
    [request setValue:[NSString stringWithFormat:@"bytes=%lld-%lld",self.begin + self.currentLength, self.end] forHTTPHeaderField:@"Range"];//设置断点续传的起点及范围
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
}
/**
 * 取消下载，并清除已下载的
 */
- (void)stop {
    [self pause];
    self.currentLength = 0;
    [self.writeHandle closeFile];
    self.writeHandle = nil;
}

- (NSFileHandle *)writeHandle {
    if (!_writeHandle) {
        // 创建写数据的文件句柄
        self.writeHandle = [NSFileHandle fileHandleForWritingAtPath:self.filePath];
    }
    return _writeHandle;
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

}
//当接受到服务器数据，调用（可多次调用）
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 移动到文件的尾部
    [self.writeHandle seekToFileOffset:self.begin + self.currentLength];
    // 从当前移动的位置(文件尾部)开始写入数据
    [self.writeHandle writeData:data];
    
    // 累加长度
    self.currentLength += data.length;
    // 显示进度
    double progress = (double)self.currentLength / (self.end - self.begin);
//    NSLog(@"----------%f-----------", progress);
    if (self.progressHandle) {
        self.progressHandle(progress);
    }
}
//当服务器数据接收完毕，调用
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // 清空属性值
    self.currentLength = 0;
    // 关闭连接(不再输入数据到文件中)
    [self.writeHandle closeFile];
    self.writeHandle = nil;
//    if (self.completionHandle) {
//        self.completionHandle();
//    }
}
@end
