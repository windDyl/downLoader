//
//  FileSingleDownLoader.h
//  FileMultiDownLoader
//
//  Created by Ethank on 16/7/18.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "DownLoadManager.h"

@interface FileSingleDownLoader : DownLoadManager
/**
 *  开始的位置
 */
@property (nonatomic, assign) long long begin;
/**
 *  结束的位置
 */
@property (nonatomic, assign) long long end;
@end
