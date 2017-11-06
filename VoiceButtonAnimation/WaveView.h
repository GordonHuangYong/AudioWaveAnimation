//
//  VoiceProgressView.h
//  VoiceButtonAnimation
//
//  Created by yunfei on 2017/9/26.
//  Copyright © 2017年 yunfei. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@protocol WaveViewDelegate <NSObject>
- (void)waveAnimationDidFinished;

@end

@interface WaveView : NSView
@property (nonatomic, weak) id<WaveViewDelegate> delegate;
@property (nonatomic, strong) NSArray *pointArray;                  //point 数组，[NSValue valueWithPoint:point]，按时间正序排序
@property (nonatomic, getter=isPlaying) BOOL playing;               //是否正在播放
@property (nonatomic) NSTimeInterval playDuration;                  //播放时长
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
@end
