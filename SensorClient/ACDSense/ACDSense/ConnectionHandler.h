//
//  ConnectionHandler.h
//  ACDSense
//
//  Created by Martin Weißbach on 8/24/13.
//  Copyright (c) 2013 Technische Universität Dresden. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ConnectionHandlerDelegate.h"

#import <MXi/MXi.h>

/**
 *  This block will be called when the authentication of the user finished. If the authentication was successfull
 *  the block will be called with 'YES' as parameter and 'NO' otherwise.
 *
 *  @param AuthenticationBlock The Block that will be executed after the authentication.
 */
typedef void (^ AuthenticationBlock)(BOOL);

/**
 *  The ConnectionHandler class provides global-level information of the XMPP connection to an XMPP server.
 */
@interface ConnectionHandler : NSObject <MXiBeanDelegate, MXiPresenceDelegate, MXiStanzaDelegate>

/**
 *  Returns a ConnectionHandler object that manages all relevant information on the connection and incoming and
 *  outgoing stanzas.
 *
 *  Because there is only one active connection supposed to exist at a time, always the same instance of the object
 *  will be returned.
 *
 *  @see ConnectionHandlerDelegate protocol
 *
 *  @return The ConnectionHandler object.
 */
+ (instancetype)sharedInstance;

+ (instancetype) alloc __attribute__((unavailable("alloc not available, call sharedInstance instead")));
- (instancetype) init __attribute__((unavailable("init not available, call sharedInstance instead")));
+ (instancetype) new __attribute__((unavailable("new not available, call sharedInstance instead")));

/**
 *  Set up a new Connection to a XMPP server. Credentials stored in the Keychain will be used.
 *
 *  @param authentication Callback block to inform the application on the success of the authentication.
 */
- (void)launchConnectionWithBlock:(AuthenticationBlock)authentication;
/**
 *  Set up a new Connection to a XMPP server. The credentials used in this method will automatically be
 *  stored in the Keychains which means old account information will be overridden.
 *
 *  @param jabberID        The full or bare JID of the user who's registered at the XMPP server.
 *  @param password        The user's password associated with the JID and XMPP server.
 *  @param hostName        The host name of XMPP server, e.g. 'jabber.org'.
 *  @param serviceJabberID The service JID of the Mobilis service.
 *  @param authentication  Callback block to infrom the application on the success of the authentication.
 */
- (void)launchConnectionWithJID:(NSString *)jabberID
                       password:(NSString *)password
                       hostName:(NSString *)hostName
                     serviceJID:(NSString *)serviceJabberID
            authenticationBlock:(AuthenticationBlock)authentication;

/**
 *  This method realizes client-server communication and sends outgoing beans to the service.
 *
 *  @param outgoingBean Bean object that should be send to the service.
 *
 *  @see MXiOutgoingBean protocol
 */
- (void)sendBean:(MXiBean<MXiOutgoingBean> *)outgoingBean;

/**
 *  Various objects might be interested in incoming beans, but not all of them are interested in all incoming beans.
 *  This method allows objects to register as a delegate for only a specific bean class.
 *
 *  @param delegate  Object that wants to act as a delegate for certain bean classes.
 *  @param beanClass The class of the bean for which the delegate registers.
 *
 *  @see ConnectionHandlerDelegate protocol
 */
- (void)addDelegate:(id<ConnectionHandlerDelegate>)delegate forBeanClass:(Class)beanClass;

@end
