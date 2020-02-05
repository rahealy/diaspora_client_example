# diaspora_client_example
A basic example of a QML based client for connecting to the diaspora social network.

Thursday January 23, 2020 - With the release of the new HTTPS/JSON based diaspora API the author decided as a personal challenge to see how much of a simple client could be written using QTQuick and QML in the span of 1 day, 2 days, and so on.


Tuesday February 4, 2020 (Current) - Some job applications, a few responses and one rejection have come and gone. My *diaspora client example is still stalled on getting OAuth to grant me an access token. If you’re interested you can find the gory details here.

[](https://discourse.diasporafoundation.org/t/oauth-getting-access-token/3003)

Help is definitely appreciated!

Various screenshots:

<img src="diaspora_client_example_posts.jpg" alt="image of diaspora client example ui." height="553" width="385"/>
<img src="diaspora_client_example_settings.jpg" alt="image of diaspora client example ui." height="553" width="385"/>
<img src="diaspora_client_example_connect.jpg" alt="image of diaspora client example ui." height="553" width="385"/>


Older:

Day 2.5 Screenshot:

<img src="diapsora_client_example.jpg" alt="image of diaspora client example ui." height="521" width="369"/>


**Day Three Design Goals:**
 * Install and configure diaspora development server
   * Update - 09:30-ish Installed VirtualBox. Seems to work.
   * Update - 10:27 Ubuntu Server 18.04.3 LTS installed and updated. Beginning diaspora + dependencies install and configuration.
   * Update - 12:32 No diaspora yet. Learning how to use netplan (why ipfup/down wasn't good enough, no idea) and configure an interface for ssh-ing to server.
 * Implement client credentials / login in javascript.


**Day Two Design Goals:**
 * UI - work on modules related to displaying posts.
 * Update day 2.5 - basic posts UI written. Things of note:
   * Posts are limited to author, avatar, post title, date and topic, and body.
   * Had difficulties getting desired margins. Resorted to using transparent rectangles.
   * 

**Day One Design Goals:**

* Credentials / Login
  * Update 13:14 - Finding out that things work way differently than what I assumed from the pieces of documentation read thus far. Things of note:
    * Client will need to connect to the specific pod using the API
    * Client will use OpenID + oauth.
    * API is not web based yet. Not sure how this reconciles with the fact that the API docs use https/url conventions.
    * If a pod does not use HTTPS what port(s) are used for the protocol?
  * Update 13:41 - NodeInfo is a protocol that servers can use to broadcast JSON formatted info about themselves.
    * https://example.com/.well-known/nodeinfo
      * Provides general information + urls for specifcs.
      * Example - https://example.com/nodeinfo/2.0
  * Update 14:02 - OpenID uses NodeInfo-like scheme to get information about the OpenID implementation
    * https://example.com/.well-known/openid-configuration
  * Update 14:22 - Client requests a connection using OpenID "Client Registration Request":
    * POST http://example.com/api/openid_connect/clients
  * Update 18:04 - Stalled on OpenID dev pending access to a *diaspora test environment.
* UI
  * QtQuick + QML
    * Update 18:04 - Done installing and configuring QtCreator, Android SDK, Android NDK and hopefully all the dependencies. Whew. Beginning UI dev via QtQuick mobile scrolling application.
  * Display first page of recent posts.
  * Load additional pages of recent posts.


**Prior Errata**

**Goals:**

* Day 1: Client that authenticates and shows posts.
* Day 2: Filtering posts.

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
   
