//
//  StoreServices.h
//  anisette-test
//
//  Created by naturecodevoid on 2/22/23.
//

#ifndef StoreServices_h
#define StoreServices_h

#import <Foundation/Foundation.h>

int SSVAnisetteProvisioningStart(unsigned long long dsId, NSData *spim, NSData** outCPIM, unsigned int* outSession);

#endif /* StoreServices_h */
