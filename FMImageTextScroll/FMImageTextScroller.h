//
//  FMImageTextScroller.h
//  04-图片轮播器
//
//  Created by zhufaming on 16/9/15.
//  Copyright © 2016年 CenYaLei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SourceModel;


/**
 点击 banner 图片的回调处理方法

 @param soureM  SourceModel
 */
typedef void(^TouchBannerBlock)(SourceModel *soureM);

@interface FMImageTextScroller : UIView

/**
 *  广告轮播的对外接口
 *
 *  @param frame      轮播视图的frame
 *  @param imageNames 所需轮播的图片名或者地址
 *  @param flag       标签说明：imageNames中存储的是地址（YES）还是图片名(NO)
 *
 *  @return 返回一个UIView CYLImageScroll
 *
 *  @exception
 */
+(id)imageScrollWithframe:(CGRect)frame withSoureceArray:(NSArray *)sourceArr withFlag:(BOOL)flag;

-(id)initWithframe:(CGRect)frame withSoureceArray:(NSArray *)sourceArr withFlag:(BOOL)flag;

@property (nonatomic,copy)  TouchBannerBlock touchBlock ;


@end
