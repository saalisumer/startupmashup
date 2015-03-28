//
//  SignInViewController.h
//  Mashup
//
//  Created by Saalis Umer on 28/03/15.
//  Copyright (c) 2015 Saalis Umer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignInViewController : UIViewController
@property (nonatomic, weak) IBOutlet UITextField * txtFieldName;
@property (nonatomic, weak) IBOutlet UITextField * txtFieldPhone;
@property (nonatomic, weak) IBOutlet UITextField * txtFieldEmail;

- (IBAction)didTapSignIn:(id)sender;
@end
