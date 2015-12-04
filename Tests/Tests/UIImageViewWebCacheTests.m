//
//  UIImageViewWebCacheTests.m
//  SDWebImage Tests
//
//  Created by Mariano Heredia on 12/4/15.
//
//

#define EXP_SHORTHAND   // required by Expecta


#import <XCTest/XCTest.h>
#import <Expecta.h>

#import "SDWebImageManager.h"
#import "UIImageView+WebCache.h"

static int64_t kAsyncTestTimeout = 5;

@interface UIImageViewWebCacheTests : XCTestCase

@end


@implementation UIImageViewWebCacheTests


- (void)testThatDownloadWithProgress {
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"Progress block canceled"];
    
    NSURL *imageURL = [NSURL URLWithString:@"http://www.google.com/images/branding/googlelogo/2x/googlelogo_color_272x92dp.png"];
    __block BOOL progressBlock1ShouldBeIgnored = NO;
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:imageURL options:SDWebImageCacheMemoryOnly
                                                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                       expect(receivedSize).equal(receivedSize);
                                                       NSLog(@"receivedSize: %ld", expectedSize);
                                                       
                                                       
                                                   }
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      [expectation fulfill];
                                                      expectation = nil;
                                                      
                                                  }];
    UIImageView *imageView = [UIImageView new];
    
    SDWebImageDownloaderProgressBlock progressBlock1 = ^(NSInteger receivedSize, NSInteger expectedSize) {
        expect(progressBlock1ShouldBeIgnored).equal(NO);
    };
    

    [imageView sd_setImageWithURL:imageURL
            placeholderImage:nil
                     options:SDWebImageCacheMemoryOnly
                    progress:progressBlock1
                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}
     ];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [imageView sd_setImageWithURL:imageURL
                     placeholderImage:nil
                              options:SDWebImageCacheMemoryOnly
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {}
         ];
        
        progressBlock1ShouldBeIgnored = YES;        
    });   

    
    [self waitForExpectationsWithTimeout:kAsyncTestTimeout handler:nil];
}

@end
