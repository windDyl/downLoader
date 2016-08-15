//
//  FileSessionDownLoader.h
//  FileMultiDownLoader
//
//  Created by Ethank on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^ProgressHandle)(double progress);
@interface FileSessionDownLoader : NSObject
/**
 * 所需要下载文件的远程URL(连接服务器的路径)
 */
@property (nonatomic, copy)NSString *urlStr;
/**
 * 文件的存储路径(文件下载到什么地方)
 */
@property (nonatomic, copy)NSString *filePath;
@property (nonatomic, readonly, getter=isDownLoading)BOOL downLoading;
/**
 * 用来监听下载进度
 */
@property (nonatomic, copy)ProgressHandle progressHandle;
/**
 * 暂停下载
 */
- (void)pause;
/**
 * 开始(恢复)下载
 */
- (void)start;
/**
 * 取消下载，并清除已下载的
 */
- (void)stop;
@end
