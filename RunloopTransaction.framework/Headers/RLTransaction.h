//
//  RLTransaction.h
//  RunloopTransaction
//
//  Created by 张尉 on 2018/7/23.
//  Copyright © 2018年 Wayne. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef __RLTransaction_h
#define __RLTransaction_h

OBJC_EXTERN
void RLTransactionCommit(void (^action)(void));


#endif
