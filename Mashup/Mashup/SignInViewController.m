//
//  SignInViewController.m
//  Mashup
//
//  Created by Saalis Umer on 28/03/15.
//  Copyright (c) 2015 Saalis Umer. All rights reserved.
//

#import "SignInViewController.h"
#import "Validation.h"
#import "User.h"
#import "ApplicationModel.h"
#import "ItemListViewController.h"

@interface SignInViewController ()

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)didTapSignIn:(id)sender
{
    NSString * message;
    if ([Validation validateMinimumLength:self.txtFieldName.text parameter:4] == NO)
    {
        message = @"Name should have atleast 4 characters";
    }
    else if ([Validation validateEmail:self.txtFieldEmail.text ] == NO) {
        message = @"Invalid Email";
    }
    else if ([Validation validatePhone:self.txtFieldPhone.text] == NO)
    {
        message = @"Phone Number Invalid";
    }
    else if ([Validation validateMinimumLength:self.txtFieldPhone.text parameter:8] == NO)
    {
        message = @"Phone should have atleast 8 characters";
    }
    
    
    if (message.length>0){
        UIAlertView * alert = [[UIAlertView alloc]initWithTitle:@"Can't Proceed" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil ];
        [alert show];
    }
    else
    {
        User * user = [[User alloc]init];
        user.userName = self.txtFieldName.text;
        user.emailAddress = self.txtFieldEmail.text;
        user.phoneNumber = self.txtFieldPhone.text;
        ApplicationModel * applicationModel = [ApplicationModel instance];
        applicationModel.user = user;
        
        UIStoryboard * mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        UITabBarController * listVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"TAB_BAR"];
        [self presentViewController:listVC animated:YES completion:^{
            
        }];
    }
    
}

@end
