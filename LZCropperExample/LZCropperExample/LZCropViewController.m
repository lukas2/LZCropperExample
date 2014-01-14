//
//  LZCropViewController.m
//  LZCropperExample
//
//  Created by Lukas Zielinski on 14/01/14.
//  Copyright (c) 2014 Lukas Zielinski. All rights reserved.
//

#import "LZCropViewController.h"
#import "UIImage+Resize.h"

@interface LZCropViewController ()
{
  UIButton *_acceptButton;
  UIScrollView *_scrollView;
  UIView *_baseView;
  UIImageView *_stencilView;
  UIImageView *_imageView;
  UIView *_specialEffectsView;
  UILabel *_infoLabel;
}
@end

@implementation LZCropViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
      CGRect screenBounds = [UIScreen mainScreen].bounds;
      self.view.backgroundColor = [UIColor blackColor];
      
      UIFont *font = [UIFont fontWithName:@"Helvetica" size:20.0f];
      
      // ACCEPT BUTTON
      
      CGRect acceptMenuButtonFrame =
      CGRectMake(screenBounds.size.width - 60.0f, 32.0f, 36.0f, 37.0f);
      
      _acceptButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
      _acceptButton.frame = acceptMenuButtonFrame;
      [_acceptButton setTitle:@"OK" forState:UIControlStateNormal];
      _acceptButton.titleLabel.font = font;
      
      [_acceptButton addTarget:self
                        action:@selector(pickResult:)
              forControlEvents:UIControlEventTouchUpInside];
      
      // IMAGE
      
      UIImage *ferrariImage = [UIImage imageNamed:@"ferrari-gto.jpg"];
      
      // STENCIL VIEW

      CGRect stencilViewFrame = CGRectMake(0, 0, 320.0f, 568.0f);
      _stencilView = [[UIImageView alloc] initWithFrame:stencilViewFrame];
      _stencilView.image = [UIImage imageNamed:@"stencil.png"];
      
      // SCROLL VIEW
      
      _scrollView = [[UIScrollView alloc] initWithFrame:screenBounds];
      _scrollView.contentSize = _baseView.frame.size;;
      _scrollView.minimumZoomScale = 0.5f;
      _scrollView.maximumZoomScale = 2.0f;
      _scrollView.delegate = self;
      _scrollView.pagingEnabled = NO;
      
      _scrollView.contentOffset =
        CGPointMake(ferrariImage.size.width / 2.0f,ferrariImage.size.height / 2.0f);
      
      // BASE VIEW
      
      _baseView = [[UIView alloc] initWithFrame:
                   CGRectMake(screenBounds.size.width * 0.4f, screenBounds.size.width * 0.4f,
                              ferrariImage.size.width + screenBounds.size.width * 0.8f,
                              ferrariImage.size.height + screenBounds.size.height *  0.8f)];
      _baseView.backgroundColor = [UIColor blackColor];
      
      // IMAGE VIEW
      
      _imageView = [[UIImageView alloc] initWithImage:ferrariImage];
      
      [self.view addSubview:_scrollView];
      [_scrollView addSubview:_baseView];
      [_baseView addSubview:_imageView];
      [self.view addSubview:_stencilView];
      [self.view addSubview:_acceptButton];
      
      _scrollView.zoomScale = 1.0f; // for some reason this should be set last?
      
      // SPECIAL EFFECTS VIEW
      
      _specialEffectsView = [[UIView alloc] initWithFrame:screenBounds];
      _specialEffectsView.backgroundColor = [UIColor whiteColor];
      _specialEffectsView.alpha = 0;
      [self.view addSubview:_specialEffectsView];
      
      // INFO LABEL
      
      CGRect infoRect = CGRectMake(0, screenBounds.size.height - 100.0f, screenBounds.size.width, 30);
      _infoLabel = [[UILabel alloc] initWithFrame:infoRect];
      _infoLabel.textAlignment = NSTextAlignmentCenter;
      _infoLabel.text = @"Image saved";
      _infoLabel.alpha = 0;
      _infoLabel.font = font;
      _infoLabel.textColor = [UIColor whiteColor];
      [self.view addSubview:_infoLabel];
      
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
  return _baseView;
}

- (void)pickResult:(id)sender
{
  // some visual feedback a.k.a. special effects:
  
  _acceptButton.enabled = NO;
  
  _specialEffectsView.alpha = 1.0f;
  [UIView animateWithDuration:1.0f animations:^{
    _specialEffectsView.alpha = 0;
  } completion:^(BOOL finished) {
    _infoLabel.alpha = 1.0f;
    [UIView animateWithDuration:1.0f animations:^{
      _infoLabel.alpha = 0;
      _acceptButton.enabled = YES;
    }];
  }];

  // 1. hide stencil overlay
  
  _stencilView.hidden = YES;
  
  // 2. take a screenshot of the whole screen
  
  UIGraphicsBeginImageContext(self.view.frame.size);
  [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
  UIImage *screenshot = UIGraphicsGetImageFromCurrentImageContext();
  UIGraphicsEndImageContext();
  
  // 3. pick interesting area and crop
  
  CGImageRef imageRef = CGImageCreateWithImageInRect([screenshot CGImage],
                                                     CGRectMake(35.0f, 159.0f, 248.0f, 248.0f));
  UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
  CGImageRelease(imageRef);
  
  // 4. just for fun, resize image by factor 2
  
  UIImage *resizedImage = [croppedImage resizedImageToSize:
                           CGSizeMake(croppedImage.size.width * 2, croppedImage.size.height * 2)];

  // 5. save result to photo gallery
  
  UIImageWriteToSavedPhotosAlbum(resizedImage, NULL, NULL, NULL);
  
  // 6. show stencil view again
  
  _stencilView.hidden = NO;
}

- (BOOL)prefersStatusBarHidden
{
  return YES;
}

@end
