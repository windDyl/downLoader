//
//  DownLoadManager.m
//  DownLoadFile
//
//  Created by Ethank on 16/7/14.
//  Copyright © 2016年 DY. All rights reserved.
//

#import "DownLoadManager.h"

@implementation DownLoadManager
/**
 * 下载的文件所分的段数
 */
- (NSInteger)downLoadCount {
    if (_downLoadCount == 0) {
        _downLoadCount = 1;
    }
    return _downLoadCount;
}
@end
