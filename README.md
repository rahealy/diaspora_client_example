# diaspora_client_example
A basic example of a QML based client for connecting to the diaspora social network.

Thursday January 23, 2020 - With the release of the new HTTPS/JSON based diaspora API the author decided as a personal challenge to see how much of a simple client could be written using QTQuick and QML in the span of 1 day, 2 days, and so on.

**Goals:**

* Day 1: Client that authenticates and shows posts.
* Day 2: Filtering posts.

**Day One Design Goals:**

* Credentials / Login
  * Update 13:14 - Finding out that things work way differently than what I assumed from the pieces of documentation read thus far. Things of note:
    * Client will need to connect to the specific pod using the API
    * Client will use OpenID + oauth.
    * API is not web based yet. Not sure how this reconciles with the fact that the API docs use https/url conventions.
    * If a pod does not use HTTPS what port(s) are used for the protocol?
  
* Display first page of recent posts.
* Load additional pages of recent posts.

**Rectangles:**

Top Level Rectangle
 * Refresh Button

Setup Rectangle
 * username/password
 * Sign In button.
 * Log Out button.
 
VScroll Rectangle
 * Post Window
   * Name / Date
   * Post Contents
   
Day 2 Goals TBD
