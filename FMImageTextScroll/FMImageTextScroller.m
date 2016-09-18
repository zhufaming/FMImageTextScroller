//
//  FMImageTextScroller.m
//  04-图片轮播器
//
//  Created by zhufaming on 16/9/15.
//  Copyright © 2016年 CenYaLei. All rights reserved.
//

#import "FMImageTextScroller.h"
#import "UIImageView+WebCache.h"

#import "SourceModel.h"

#define ImageCount self.sourceArray.count

#define Offset0 0
#define Offset2 self.scrollView.frame.size.width*2


@interface FMImageTextScroller()<UIScrollViewDelegate>
{
    //当前显示图片的下标
    NSInteger currentImgIndex;
}


@property (weak, nonatomic)  UIScrollView *scrollView;
@property (weak, nonatomic)  UIPageControl *pageControl;
@property (strong,nonatomic) NSTimer *timer;

@property (strong,nonatomic) UIImageView *imageView1;
@property (strong,nonatomic) UIImageView *imageView2;
@property (strong,nonatomic) UIImageView *imageView3;

@property (strong,nonatomic) NSMutableArray *imageViewArray;
//图片名或地址
@property (strong,nonatomic) NSArray *sourceArray;
//图片名或者地址的标识
@property (assign,nonatomic) BOOL flag;
//文字背景View
@property (strong,nonatomic) UIView *textBgView;
//文字lab
@property (strong,nonatomic) UILabel *textLab;

@end


@implementation FMImageTextScroller


-(UILabel *)textLab
{
    if (_textLab==nil) {
        
        _textLab=[[UILabel alloc] initWithFrame:CGRectMake(10, 10, self.bounds.size.width-100, 20)];
        _textLab.textColor=[UIColor whiteColor];
        _textLab.font=[UIFont systemFontOfSize:14.0f];
        
    }
    return _textLab;
}

+(id)imageScrollWithframe:(CGRect)frame withSoureceArray:(NSArray *)sourceArr withFlag:(BOOL)flag
{
    return [[self alloc] initWithframe:frame withSoureceArray:sourceArr withFlag:flag];
}

-(id)initWithframe:(CGRect)frame withSoureceArray:(NSArray *)sourceArr withFlag:(BOOL)flag
{
    if (self=[super initWithFrame:frame]) {
        
        CGFloat imgvW = frame.size.width;
        CGFloat imgvH = frame.size.height;
        
        _imageViewArray = [NSMutableArray array];
        _sourceArray = [NSArray array];
        _sourceArray = sourceArr;
        
        _flag = flag;
        
        //初始化滚动视图
        UIScrollView *sc = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView = sc;
        [self addSubview:_scrollView];
        
        
        //添加手势
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(goTouchBannerAction) ]];

        //初始化页码显示器
        UIPageControl *pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(imgvW - 100, imgvH - 40, 100, 40)];
        _pageControl = pageControl;
        [self addSubview:_pageControl];
        
        _imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, imgvW, imgvH)];
        _imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(imgvW, 0, imgvW, imgvH)];
        _imageView3 = [[UIImageView alloc]initWithFrame:CGRectMake(2*imgvW, 0, imgvW, imgvH)];
        
//        _imageView1.contentMode=UIViewContentModeScaleAspectFill;
//        _imageView1.clipsToBounds=YES;
//        _imageView2.contentMode=UIViewContentModeScaleAspectFill;
//        _imageView2.clipsToBounds=YES;
//        _imageView3.contentMode=UIViewContentModeScaleAspectFill;
//        _imageView3.clipsToBounds=YES;
        
        
        [_imageViewArray addObjectsFromArray:@[_imageView1,_imageView2,_imageView3]];
        
        [self.scrollView addSubview:_imageView1];
        [self.scrollView addSubview:_imageView2];
        [self.scrollView addSubview:_imageView3];
        //取数据
        SourceModel *model1=sourceArr[sourceArr.count-1];
        SourceModel *model2=sourceArr[0];
        //text
        
        SourceModel *model3=sourceArr[1];
        if (flag) {
            
            [_imageView1 sd_setImageWithURL:[NSURL URLWithString:model1.imgUrl] placeholderImage:nil];
            [_imageView2 sd_setImageWithURL:[NSURL URLWithString:model2.imgUrl] placeholderImage:nil];
            [_imageView3 sd_setImageWithURL:[NSURL URLWithString:model3.imgUrl] placeholderImage:nil];
            
        }
        else
        {
            _imageView1.image = [UIImage imageNamed:model1.imgUrl];
            _imageView2.image = [UIImage imageNamed:model2.imgUrl];
            _imageView3.image = [UIImage imageNamed:model3.imgUrl];
            
        }
        
        //设置代理
        self.scrollView.delegate = self;
        currentImgIndex = 0;
        
        //开始偏移量为1
        [self.scrollView setContentOffset:CGPointMake(imgvW, 0)];
        currentImgIndex = 0;
        
        //2、设置滚动范围
        CGFloat contentW = 3*imgvW;
        self.scrollView.contentSize = CGSizeMake(contentW, 0);
        self.scrollView.bounces = NO;
        
        //3、取消滚动条
        self.scrollView.showsHorizontalScrollIndicator = NO;
        //4、设置分页
        self.scrollView.pagingEnabled = YES;
        
        //5、设置页码
        self.pageControl.numberOfPages = sourceArr.count;
        //6、设置定时器（每隔2秒钟调用一次nextPage方法）
        [self addTimer];
        
        //添加
        _textBgView=[[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-40, self.bounds.size.width, 40)];
        _textBgView.backgroundColor=[UIColor colorWithRed:40/255.0 green:40/255.0 blue:40/255.0 alpha:0.5];
        
        [self insertSubview:_textBgView belowSubview:self.pageControl];
        
        //text label 初始值
       self.textLab.text=model2.imgText;
        [self.textBgView addSubview:self.textLab];

        
    }
    return self;
}

/**
 *  添加定时器
 */
-(void)addTimer
{
    //创建定时器
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(autoScroll) userInfo:nil repeats:YES];
    //给定时器分流主线程时间（提高定时器的优先级）
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
/**
 *  移除定时器
 */
-(void)removeTimer
{
    //停止定时器(一旦停止，就不能再使用，再用的时候需要重新创建)
    [self.timer invalidate];
    self.timer = nil;
    
}

-(void)autoScroll
{
    //计算scrollView的滚动位置
    CGFloat offsetX = self.scrollView.frame.size.width + self.scrollView.contentOffset.x;
    CGPoint offSet = CGPointMake(offsetX, 0);
    
    [self.scrollView setContentOffset:offSet animated:YES];
}

#pragma mark -滚动视图的代理
/**
 *  当正在滚动的时候调用，不根据手势来判断
 *
 */
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = currentImgIndex;
    
    CGFloat contentW = scrollView.frame.size.width;
    
    //NSLog(@"contentW = %g",contentW);
    
    //拖拽结束以后的页码
    int currentPage = (scrollView.contentOffset.x) / contentW;
    //下一张
    CGFloat nextOffsetX = (currentPage + 1)* contentW;
    
    if (scrollView.contentOffset.x == Offset2) {
    
        //方向不为零，说明滑动了一页,当前页下标加1
        currentImgIndex ++;
        if (currentImgIndex == ImageCount) {
            currentImgIndex = 0;
        }
        
        UIImageView *imageView = [self minImageView];
        imageView.frame = CGRectMake(nextOffsetX, 0, contentW, imageView.frame.size.height);
        
        NSInteger nextImgIndex = 0;
        
        //如果下一页的图片下标为5则为0
        if (currentImgIndex + 1 == ImageCount) {
            nextImgIndex = 0;
        }else
        {
            nextImgIndex = currentImgIndex + 1;
        }
        
        //下一张图片资源
        SourceModel *nextSource=_sourceArray[nextImgIndex];
        
        
        if (_flag) {
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:nextSource.imgUrl] placeholderImage:nil];
            
        }
        else
        {

            imageView.image=[UIImage imageNamed:nextSource.imgUrl];
        }
        
        
        
        //整体左移一个宽度
        [self allImageViewMoveAWidth:-contentW];
        //同时偏移量也左移
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - contentW, 0);
        
          NSLog(@"currentIndex;%ld",currentImgIndex);
        
        //设置 text 的值
          SourceModel *textSoureM=_sourceArray[currentImgIndex];
        self.textLab.text=textSoureM.imgText;
        
    }
    
    CGFloat preOffsetX = (currentPage - 1)* contentW;
    if (scrollView.contentOffset.x == Offset0) {
        
        //方向不为零，说明滑动了一页,当前页下标加1
        currentImgIndex --;
        if (currentImgIndex == -1) {
            currentImgIndex = ImageCount - 1;
        }
        
        UIImageView *imageView = [self maxImageView];
        //4、修改范围之外的frame补充到即将显示的位置
        imageView.frame = CGRectMake(preOffsetX, 0, contentW, imageView.frame.size.height);
        
        
        NSInteger preImgIndex = 0;
        
        
        //如果下一页的图片下标为5则为0
        if (currentImgIndex - 1 == -1) {
            preImgIndex = ImageCount - 1;
        }else
        {
            preImgIndex = currentImgIndex - 1;
        }
        
        
        //下一张图片资源
        SourceModel *preSourceM=_sourceArray[preImgIndex];
        
        if (_flag) {
            
            [imageView sd_setImageWithURL:[NSURL URLWithString:preSourceM.imgUrl]  placeholderImage:nil];
            
        }
        else
        {
            imageView.image = [UIImage imageNamed:preSourceM.imgUrl];
        }
        
        //整体右移动一个宽度
        [self allImageViewMoveAWidth:contentW];
        //同时偏移量也右移
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + contentW, 0);
        
        
    }
}


-(UIImageView *)maxImageView
{
    CGFloat originX1 = _imageView1.frame.origin.x;
    CGFloat originX2 = _imageView2.frame.origin.x;
    CGFloat originX3 = _imageView3.frame.origin.x;
    
    if (originX1 >= originX2 && originX1 >= originX3) {
        return _imageView1;
    }
    if (originX2 >= originX1 && originX2 >= originX3) {
        return _imageView2;
    }
    if (originX3 >= originX2 && originX3 >= originX1) {
        return _imageView3;
    }
    return nil;
}

-(UIImageView *)minImageView
{
    CGFloat originX1 = _imageView1.frame.origin.x;
    CGFloat originX2 = _imageView2.frame.origin.x;
    CGFloat originX3 = _imageView3.frame.origin.x;
    
    if (originX1 <= originX2 && originX1 <= originX3) {
        return _imageView1;
    }
    if (originX2 <= originX1 && originX2 <= originX3) {
        return _imageView2;
    }
    if (originX3 <= originX2 && originX3 <= originX1) {
        return _imageView3;
    }
    return nil;
    
}

-(void)allImageViewMoveAWidth:(CGFloat)width
{
    [_imageViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIImageView *imgView = obj;
        imgView.frame = CGRectMake(imgView.frame.origin.x + width, 0, imgView.frame.size.width, imgView.frame.size.height);
        
    }];
}


-(void)goTouchBannerAction
{
    
    SourceModel *sourceM=self.sourceArray[currentImgIndex];
    self.touchBlock(sourceM);
    
}



@end
