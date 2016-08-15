//
//  DownLoadManager.h
//  DownLoadFile
//
//  Created by Ethank on 16/7/14.
//  Copyright © 2016年 DY. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^ProgressHandle)(double progress);
typedef void(^FailureHandle)(NSError *error);
typedef void(^CompletionHandle)();

@interface DownLoadManager : NSObject {
    BOOL _downLoading;
}

/**
 * 所需要下载文件的远程URL(连接服务器的路径)
 */
@property (nonatomic, copy)NSString *urlStr;
/**
 * 文件的存储路径(文件下载到什么地方)
 */
@property (nonatomic, copy)NSString *filePath;
/**
 * 是否正在下载(有没有在下载, 只有下载器内部才知道)
 */
@property (nonatomic, readonly, getter=isDownLoading)BOOL downLoading;
/**
 * 下载的文件所分的段数
 */
@property (nonatomic, assign) NSInteger downLoadCount;
/**
 * 用来监听下载进度
 */
@property (nonatomic, copy)ProgressHandle progressHandle;
/**
 * 用来监听下载失败
 */
@property (nonatomic, copy)FailureHandle failureHandle;
/**
 * 用来监听下载完毕
 */
@property (nonatomic, copy)CompletionHandle completionHandle;
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
