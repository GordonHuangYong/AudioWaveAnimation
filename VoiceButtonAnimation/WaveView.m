//
//  VoiceProgressView.m
//  VoiceButtonAnimation
//
//  Created by yunfei on 2017/9/26.
//  Copyright © 2017年 yunfei. All rights reserved.
//

#import "WaveView.h"
#import <QuartzCore/QuartzCore.h>

#define playBtnRect NSMakeRect(5, 5, 30, 30)

@interface WaveView () <CAAnimationDelegate>
@end

@implementation WaveView{
    CAShapeLayer *animationLayer;
    CABasicAnimation *animation;
}

#pragma mark - setters
- (void)setPointArray:(NSArray *)pointArray{
    _pointArray = pointArray;
    
    [self setNeedsDisplay:YES];
    [self drawWaveView];
}

#pragma mark - init
- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.wantsLayer = YES;
        self.layer.cornerRadius = NSHeight(frameRect) / 2.f;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [NSColor lightGrayColor].CGColor;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    if (self.isPlaying) {
        NSImage *stopImg = [NSImage imageNamed:@"audio_pause_h"];
        [stopImg drawInRect:playBtnRect];
    }else{
        NSImage *playImg = [NSImage imageNamed:@"audio_play_h"];
        [playImg drawInRect:playBtnRect];

    }
}

#pragma mark - mouse event
- (void)mouseUp:(NSEvent *)event{
    NSPoint windowP = event.locationInWindow;
    NSPoint localP = [self convertPoint:windowP fromView:nil];
    
    if (NSPointInRect(localP, playBtnRect)) {
        if (self.isPlaying) {
            [self pause];
        }else{
            [self play];
        }
    }
}

#pragma mark - wave view drawing methods
- (void)drawWaveView{
    //波形路径
    CGPathRef wavePath = [self pathWithPoints:self.pointArray];
    
    //添加完整波形图层
    [self addWaveLayerWithPath:wavePath];
    
    //添加播放动画图层
    [self addAnimationLayerWithPath:wavePath];
}

//波形路径
- (CGPathRef)pathWithPoints:(NSArray *)points{
    CGFloat midY = NSHeight(self.bounds) / 2.f;
    CGFloat leftX = NSMaxX(playBtnRect);
    
    CGMutablePathRef wavePath = CGPathCreateMutable();                 //绘制路径
    CGPathMoveToPoint(wavePath, nil, leftX, midY);
    for (NSInteger i = 0; i < _pointArray.count; i++) {
        NSValue *pointValue = _pointArray[i];
        NSPoint point = pointValue.pointValue;
        if (point.y == 0) {
            CGPathMoveToPoint(wavePath, nil, leftX + i - 1, midY);
            CGPathAddLineToPoint(wavePath, NULL, leftX + i, midY);
        }else{
            CGPathMoveToPoint(wavePath, nil, leftX + i, midY);
            CGPathAddLineToPoint(wavePath, NULL, leftX + i, midY + point.y);
            CGPathMoveToPoint(wavePath, nil, leftX + i, midY);
            CGPathAddLineToPoint(wavePath, NULL, leftX + i, midY - point.y);
        }
    }
    CGPathRef path = CGPathCreateCopy(wavePath);
    CGPathRelease(wavePath);
    return path;
}

//添加完整波形图层
- (void)addWaveLayerWithPath:(CGPathRef)wavePath{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth=1;
    shapeLayer.strokeColor=[NSColor lightGrayColor].CGColor;
    shapeLayer.lineCap = kCALineCapRound;
    shapeLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:shapeLayer];
    shapeLayer.path = wavePath;
}

//添加播放动画图层
- (void)addAnimationLayerWithPath:(CGPathRef)path{
    animationLayer = [CAShapeLayer layer];
    animationLayer.path = path;
    animationLayer.lineWidth = 1;
    animationLayer.strokeColor=[NSColor whiteColor].CGColor;
    animationLayer.lineCap = kCALineCapRound;
    animationLayer.lineJoin = kCALineJoinRound;
    [self.layer addSublayer:animationLayer];
    
    animationLayer.speed = 0;   //禁止动画执行
    animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.duration = _playDuration;
    animation.fromValue = @(0.0f);
    animation.toValue = @(1.0f);
    animation.delegate = self;
    [animationLayer addAnimation:animation forKey:@""];
}

#pragma mark - audio playing relative methods
- (void)play{
    [self resume];
}

- (void)pause{
    _playing = NO;
    [self setNeedsDisplay:YES];
    
    CFTimeInterval pausedTime = [animationLayer convertTime:CACurrentMediaTime() fromLayer:nil];
    animationLayer.speed = 0;
    animationLayer.timeOffset = pausedTime;
}

- (void)resume{
    _playing = YES;
    [self setNeedsDisplay:YES];
    
    CFTimeInterval pausedTime = [animationLayer timeOffset];
    animationLayer.speed = 1.0;
    animationLayer.timeOffset = 0.0;
    animationLayer.beginTime = 0;
    CFTimeInterval timeSincePause = [animationLayer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    animationLayer.beginTime = timeSincePause;
}

- (void)stop{
    _playing = NO;
    [self setNeedsDisplay:YES];

    animationLayer.timeOffset = 0;
    animationLayer.speed = 0;
    
    //动画播放完成后，默认自动removed
    [animationLayer addAnimation:animation forKey:@""];
}

#pragma mark - CAAnimationDelegate
- (void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"animation has began");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        NSLog(@"yes, animation has finished");
        [self stop];
        if ([self.delegate respondsToSelector:@selector(waveAnimationDidFinished)]) {
            [self.delegate waveAnimationDidFinished];
        }
        
    }
}
@end
