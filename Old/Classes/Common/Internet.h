/*****************************************************************************
 ** Copyright (c) 2010 Ushahidi Inc
 ** All rights reserved
 ** Contact: team@ushahidi.com
 ** Website: http://www.ushahidi.com
 **
 ** GNU Lesser General Public License Usage
 ** This file may be used under the terms of the GNU Lesser
 ** General Public License version 3 as published by the Free Software
 ** Foundation and appearing in the file LICENSE.LGPL included in the
 ** packaging of this file. Please review the following information to
 ** ensure the GNU Lesser General Public License version 3 requirements
 ** will be met: http://www.gnu.org/licenses/lgpl.html.
 **
 **
 ** If you have questions regarding the use of this file, please contact
 ** Ushahidi developers at team@ushahidi.com.
 **
 *****************************************************************************/

#import <Foundation/Foundation.h>

@interface Internet : NSObject {

}

@end

typedef enum {
	BrowserErrorHostNotFound = -1003,
    BrowserErrorOperationNotCompleted = -999,
    BrowserErrorNoInternetConnection = -1009,
	NoInternetConnection = 1,
	UnableToCreateRequest = 5,
	HttpStatusContinue = 100,
	HttpStatusOK = 200,
	HttpStatusCreate = 201,
	HttpStatusAccepted = 202,
	HttpStatusNoContent = 204,
	HttpStatusMovedPermanently = 301,
	HttpStatusNotModified = 304,
	HttpStatusBadRequest = 400,
	HttpStatusNoauthorized = 401,
	HttpStatusForbidden = 403,
	HttpStatusNotFound = 404,
	HttpStatusTimeout = 408,
	HttpStatusInternalServerError = 500,
	HttpStatusNotImplemented = 501,
	HttpStatusBadGateway = 502,
	HttpStatusServiceUnavailable = 503
} HttpStatus;
