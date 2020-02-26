# diaspora_client_example

**Thursday January 23, 2020** - With the release of the new HTTPS/JSON based diaspora API as a personal challenge I decided to see how much of a simple client could be written using QTQuick and QML in the span of 1 day, 2 days, and so on. 

### What This Is:

A Qt multi platform example written in C++/QML/JavaScript that hopefully will be useful for those trying to make sense of the OpenID + OAuth specifications, accessing a diaspora pod using the diaspora API, and as code demo.

IMPORTANT: This client example is intended for use as a test of the Diaspora API. It does NOT implement certain OpenID security measures. It does not require encrypted (https) endpoints. DO NOT USE THIS CODE IN PRODUCTION.


### What This Isn't:

A full fledged library and/or application and/or secure. While it definitely has potential, unless people show interest I'm probably going to turn to other projects.


### Current

**Wednesday February 26, 2020 (Current)**<b>&ast;</b> Now that there's a public server running the development version of the API with a valid SSL cert I intend to revisit this project in the next few days with the goal of updating the code to use HTTPS.

<b>(&ast;)</b> Just a reminder that I'm actively looking for paid work either locally (Twin Cities, Minnesota, USA) or remotely. If you believe I could be of service to your organization or know of an organization that is looking for a dedicated employee comitted to a lifetime of learning and serving others please feel free to contact me through [LinkedIn](https://www.linkedin.com/in/richardarthurhealy/). Thank you so much.

### Older

**Thursday February 7, 2020** - A few days turned into many days but here's a reasonably working example that meets most of my original goals. I'll call it an alpha release.


### References

* **Diaspora**
  * API: https://diaspora.github.io/api-documentation/index.html
  * Communications: https://discourse.diasporafoundation.org/
  * Installation Guide: https://wiki.diasporafoundation.org/Installation

* **OAuth Tutorials**
  * https://aaronparecki.com/oauth-2-simplified/
  * http://tutorials.jenkov.com/oauth2/index.html

* **Other**
  * JWT: https://tools.ietf.org/html/rfc7519
  * NodeInfo: https://nodeinfo.diaspora.software/protocol.html
  * Webfinger: https://tools.ietf.org/html/rfc7033
  * /.well-known/: https://tools.ietf.org/html/rfc5785
  * Qt Download: https://www.qt.io/download-open-source


### Build Notes

**Diaspora Server**

I installed Ubuntu Server on a VirtualBox virtual machine then followed the official instructions. Don't forget to enable port forwarding in the Network section of the VM Settings.

The diaspora installation instructions are straightforward and everything went off without a hitch.


**Qt**

Rather than fuss around with a bunch of system dependencies I installed Qt from the online installer. I used Qt Creator to write and design most of the code.


### Requisite Screenshot

<img src="diapsora_client_example.jpg" alt="image of diaspora client example ui." height="521" width="369"/>


### Older Still

**Day Three Design Goals**

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

