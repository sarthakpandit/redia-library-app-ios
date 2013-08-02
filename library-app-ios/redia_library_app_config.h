/***********************************************
 This file is part of redia-library-app-ios.
 
 Copyright (c) 2012, 2013 Redia A/S
 
 Redia-library-app-ios is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Redia-library-app-ios is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with redia-library-app-ios.  If not, see <http://www.gnu.org/licenses/>.
 
 *********************************************** */


/** How to use this file:
 
 redia_library_app_config.h
 
 This file is meant to be included in the app's general prefix file,
 like myApp_Prefix.pch
 
 You must obtain all required API keys and URLs in order to
 access the different web services provides the back-end for
 this app. Please contact <support@redia.dk> for more
 information.
 
 The API keys and URLS are defined using the macros below.
 
 */


/**
 =====================================================
 APP MODULES SETUP
 
 Configurations for including or excluding
 different modules in the app.
 =====================================================
 */

/**
 This macro enables the use of remote error reporting
 through some bugtracking system. If enabled, the developer
 must provide a suitable class implementing the required methods.
 */
//#define REDIA_APP_USE_ERROR_REPORTER

/**
 This macro disables a check for whether an error
 reporting class is implemented. If you don't want to implement
 an error reporter that posts uncaught exceptions to
 some external bug tracking system, it's OK to define this symbol.
 */
#define REDIA_APP_DONT_WARN_ON_MISSING_ERROR_REPORTER

/**
 This macro enables a green button "Scan" in the search bar
 */
#define REDIA_APP_USE_SCANNER_OPTION


/**
 The following ensures that the 'More About' button is implemented
 if the scanner option is included.
 */
#ifdef REDIA_APP_USE_SCANNER_OPTION
#   ifndef REDIA_APP_USE_MORE_ABOUT_OPTION
//The more about button must be enabled together with the scanner option
#       define REDIA_APP_USE_MORE_ABOUT_OPTION
#   endif
#endif


/**
 =====================================================
 BACKEND URLS AND API KEYS SETUP
 
 Configurations for accessing backends
 =====================================================
 */

/**
 An NSString with a URL to a backend that will access the libraries
 holdings and user data.
 */
#define REDIA_APP_UNIFIED_LIBRARY_BACKEND_URL @""

/**
 An NSString with a valid API key for the backend access to
 library data.
 */
#define REDIA_APP_LIBRARY_XMLRPC_CLIENT_API_KEY @""

/**
 An NSString with a URL to Redia's 'Infogalleri' content management
 system for providing content in "News" and "Arrangements"
 tabs.
 */
#define REDIA_APP_INFOGALLERI_XMLRPC_URL @""

/**
 An NSString with a URL to an XMLRPC webservice providing book cover
 images based on a backend id.
 */
#define REDIA_APP_COVER_SERVICE_URL @""

/**
 An NSString with a URL to an HTTP image rescaling webservice
 */
#define REDIA_APP_IMAGE_RESCALING_SERVICE_URL @""

/**
 An NSString with a valid API key for the image rescaling webservice
 */
#define REDIA_APP_IMAGE_UTILS_API_KEY @""

/**
 An NSString with a URL to Redia's 'Publish' content management
 system for providing content in "News" and "Arrangements"
 tabs. (Currently unused, you can leave the empty string).
 */
#define REDIA_APP_PUBLISH_XMLRPC_URL @""

/**
 An NSString with a URL to Redia's 'Plist Package' content management
 system for providing content in "News" and "Arrangements"
 tabs. (Currently unused, you can leave the empty string).
 */
#define REDIA_APP_PLIST_PACKAGE_FETCH_URL @""

