/*
  Minimal javascript implementation for diaspora API version 1.
*/
var V1 = function(args) {

/* Private */
    var mArgs = args || {};
    var mPodURL = '';

/*
 * http_get_json(url, onloadfn)
 *  Get a json object from url then call onload(obj)
 */
    function http_get_json(url, onloadfn) {
        var oReq = new XMLHttpRequest();

//        oReq.addEventListener("progress", progfn);
//        oReq.addEventListener("load", loadfn);
//        oReq.addEventListener("error", errorfn);
//        oReq.addEventListener("abort", abortfn);

        oReq.onload = function(e) {
            onloadfn(oReq.response);
        }

        oReq.open("GET", url);
        oReq.responseType = "json";
        oReq.send();
    }

    /*
     * http_post_json(url, onloadfn)
     *  Post a json object to the url then call onload(obj)
     */
    function http_post_json(url, json_obj, onloadfn) {
        var oReq = new XMLHttpRequest();

//        oReq.addEventListener("progress", progfn);
//        oReq.addEventListener("load", loadfn);
//        oReq.addEventListener("error", errorfn);
//        oReq.addEventListener("abort", abortfn);

        oReq.onload = function(e) {
            onloadfn(oReq.response);
        }

        oReq.open("POST", url);
        oReq.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        oReq.responseType = "json";
        oReq.send(JSON.stringify(json_obj));
    }
/*
 * http_send_form_get_json(url, onloadfn)
 *  Send a form encoded object to the url, get a json reply then
 *  call onload(json_obj)
 */
    function http_send_form_get_json(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();
        var data = '?' + Object.keys(obj).map (
            function(key) {
                return encodeURIComponent(key) +
                       '=' +
                       encodeURIComponent(obj[key]);
            }
        ).join('&');

//        oReq.addEventListener("progress", progfn);
//        oReq.addEventListener("load", loadfn);
//        oReq.addEventListener("error", errorfn);
//        oReq.addEventListener("abort", abortfn);

        oReq.onload = function(e) {
            onloadfn(oReq.response);
        }

        oReq.open("GET", url);
        oReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//        oReq.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
//        oReq.responseType = "json";
        oReq.send(data);
    }

/*
 * http_post_form_get_json(url, onloadfn)
 *  Send a form encoded object to the url, get a json reply then
 *  call onload(json_obj)
 */
    function http_post_form_get_json(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();
        var data = Object.keys(obj).map (
            function(key) {
                return encodeURIComponent(key) +
                       '=' +
                       encodeURIComponent(obj[key]);
            }
        ).join('&');

        console.log('POSTING: ' + data);
//        oReq.addEventListener("progress", progfn);
//        oReq.addEventListener("load", loadfn);
//        oReq.addEventListener("error", errorfn);
//        oReq.addEventListener("abort", abortfn);

        oReq.onload = function(e) {
            onloadfn(oReq.response);
        }

        oReq.open("POST", url);
        oReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
//        oReq.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
//        oReq.responseType = "json";
        oReq.send(data);
    }
/*
 * wellknown()
 *  retrieve wellknown services from pod at url then call onload(jsonObj)
 */
    function wellknown(url, name, onload) {
        http_get_json (
            url + '/.well-known/' + name,
            function(json_obj) {
                if (json_obj) onload(json_obj);
            }
        );
    }

/*
 * nodeinfo()
 *  Determine if nodeinfo is in wellknown and if so retrieve most recent
 *  supported nodeinfo version from pod at url then call onload(jsonObj)
 */
    function nodeinfo(url, onload) {
        const nodeinfo_rels = [
            'http://nodeinfo.diaspora.software/ns/schema/1.0',
            'http://nodeinfo.diaspora.software/ns/schema/2.0'
        ];

        var wellknown_onload = function(obj) {
            console.log(JSON.stringify(obj));
            if (!('links' in obj)) return;

//Find the highest supported nodeinfo version and load.
            var lnk;
            var ver = 0;
            var href = "";

            for (lnk of obj.links) {
                if (('rel' in lnk) && ('href' in lnk)) {
                    var i;
                    for (i = 0; i < nodeinfo_rels.length; ++i) {
                        if (lnk.rel === nodeinfo_rels[i]) {
                            if (ver < i) {
                                ver = i;
                                href = lnk.href;
                            }
                        }
                    }
                    http_get_json(href, onload);
                }
            }
        }
        wellknown(url, 'nodeinfo', wellknown_onload);
    }

/*
 * openid_discovery()
 *  Determine if there is an openid service available and if so retrieve
 *  discovery information from pod at url then call onload(jsonObj)
 */
    function openid_discovery(url, onload) {
        var wellknown_onload = function(json_obj) {
            console.log(JSON.stringify(json_obj));
            if('registration_endpoint' in json_obj) {
                onload(json_obj);
            }
        }
        wellknown(url, 'openid-configuration', wellknown_onload);
    }

    function openid_register(url, onload) {
//No redirect uri on account of this being a 'native' application_type.
//Use a dummy uri using localhost per section 2 in the OpenID Connect
//1.0 specification.
        const redirect_uri = 'http://localhost/diaspora_client_example/1.0';

//Diaspora server's url for registering this application as a client.
//Obtained after querying openid-configuration from the wellknown services.
        var registration_endpoint = '';

//Diaspora server's url for authorizing this application to read posts.
//Obtained after querying openid-configuration from the wellknown services.
        var authorization_endpoint = '';

//Diaspora server's url for getting a token. Obtained after querying
//openid-configuration from the wellknown services.
        var token_endpoint = '';

        var authorization_onload = function(json_obj) {
            console.log(JSON.stringify(json_obj));
        }

        var request_onload = function(json_obj) {
            console.log(JSON.stringify(json_obj));

//There are many possible fields including cryptographic mitigations
//for forgery and man in the middle attacks. DO NOT USE THIS CODE FOR
//PRODUCTION. IT IS NOT SECURE.
            var authorization = {
//This example is limited to reading private and public posts.
                scope: 'openid private:read public:read',
//Using Authorization Code Flow
                response_type: 'code',
//ID retained from client request.
                client_id: json_obj.client_id,
//URI to return the user to after authorization is complete
                redirect_uri: redirect_uri
            }

            var token_login = {
                grant_type: 'password',
                client_id: json_obj.client_id,
                username: 'foo',
                password: 'bar',
            }

            console.log('Attempting authorization at:' + token_endpoint);

            http_post_form_get_json (
                authorization_endpoint,
                token_login,
                authorization_onload
            );
        }

        var discovery_onload = function(json_obj) {
            console.log(JSON.stringify(json_obj));
//There are many possible fields including encryption. Example limited
//to the basics. DO NOT USE THIS CODE FOR PRODUCTION. IT IS NOT SECURE.
            var request = {
                application_type: 'native',
                client_name: 'diaspora_client_example',
                redirect_uris: [redirect_uri]
            };

            registration_endpoint = json_obj.registration_endpoint;
            authorization_endpoint = json_obj.authorization_endpoint;
            token_endpoint = json_obj.token_endpoint;

            http_post_json (
                registration_endpoint,
                request,
                request_onload
            );
        }

        openid_discovery(url, discovery_onload);
    }

/*
 * Connect to a pod at given url then call onload().
 */
    function connect_pod(url, onload) {
        var openid_onload = function(json_obj) {
            console.log(JSON.stringify(json_obj));
        }

        var nodeinfo_onload = function(json_obj) {
            console.log(JSON.stringify(json_obj));
            if ('protocols' in json_obj) {
                var proto;
                for(proto of json_obj.protocols) {
                    if (proto === 'diaspora') {
                        openid_register(url, openid_onload)
                    }
                }
            }
        }
        nodeinfo(url, nodeinfo_onload);
    }

/* Public */
    this.set_pod = function(url) {
        nodeinfo(url);
    }

    this.test = function() {
        var ni = connect_pod('http://example.com');
    };
};
