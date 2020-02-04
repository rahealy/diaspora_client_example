/*
  Minimal javascript implementation for diaspora API version 1.
*/
var V1 = function(args) {

/**********************************************************************
 * Private
 *********************************************************************/

    var mArgs = args || {};
    var mPodURL = '';

//No redirect uri on account of this being a 'native' application_type.
//Use a dummy uri using localhost per section 2 in the OpenID Connect
//1.0 specification. FIXME: This isn't an html server so not sure how
//to redirect.
    const redirect_uri = 'http://127.0.0.1:65080';

//Location of diaspora pod.
    var diaspora_pod_addr = '';

//Diaspora server's url for registering this application as a client.
//Obtained after querying openid-configuration from the wellknown services.
    var openid_registration_endpoint = '';

//Diaspora server's url for authorizing this application to read posts.
//Obtained after querying openid-configuration from the wellknown services.
    var openid_authorization_endpoint = '';

//Diaspora server's url for getting a token. Obtained after querying
//openid-configuration from the wellknown services.
    var openid_token_endpoint = '';

//OpenID client id issued to the example client by the diaspora server.
    var openid_client_id = '';

//OpenID client secret issued to the example client by the diaspora server.
    var openid_client_secret = '';

//OpenID code returned after user authenticates client.
    var openid_code = '';

//OpenID state item sent as part of user authentication.
    var openid_state = '';

//OpenID version of cryptographic salt.
    var openid_code_verifier = '';

/*
 * openid_generate_state()
 *  Generate a random value to be used as a state argument.
 */
    function openid_generate_state(obj) {
        openid_state = Random.randomHexString();
    }

/*
 * openid_generate_code_verifier()
 *  Generate a random value to be used as a code verifier.
 */
    function openid_generate_code_verifier() {
        var i;
        openid_code_verifier = '';
        for (i = 0; i < 128 / 4; ++i) {
            openid_code_verifier += Random.randomHexString();
        }
    }

/*
 * openid_generate_code_challenge()
 *  A code challenge is a code verifier that has been SHA256 hashed and
 *  base64 encoded.
 */
    function openid_generate_code_challenge() {
        return Sha256.hash(openid_code_verifier).toString('base64');
    }

/*
 * encode_object_as_uri(obj)
 */
    function encode_object_as_uri(obj) {
        return Object.keys(obj).map (
            function(key) {
                return encodeURIComponent(key) + '=' +
                       encodeURIComponent(obj[key]);
            }
        ).join('&');
    }

/*
 * http_get_json(url, onloadfn)
 *  Get a json object from url then call onload(obj)
 */
    function http_get_json(url, onloadfn) {
        var oReq = new XMLHttpRequest();

        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(JSON.parse(oReq.response));
            } else {
                onloadfn({api_error: 'HTTP GET ' + url + ' failed.'});
            }
        }

        console.log("http_get_json(): GET " + url);

        oReq.open("GET", url);
        oReq.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        oReq.send();
    }

/*
 * http_post_json(url, onloadfn)
 *  Post a json object to the url then call onload(obj)
 */
    function http_post_json(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();

        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(JSON.parse(oReq.response));
            } else {
                onloadfn({api_error: 'HTTP POST ' + url + ' failed.'});
            }
        }

        console.log('http_post_json(): POST ' + url + ' * oReq.send: ' + JSON.stringify(obj));

        oReq.open("POST", url);
        oReq.setRequestHeader("Content-Type", "application/json;charset=UTF-8");
        oReq.send(JSON.stringify(obj));
    }

/*
 * http_post_enc()
 *  POST a urlencoded object.
 */
    function http_post_enc(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();

        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(oReq.response);
            } else {
                onloadfn({api_error: 'HTTP POST ' + url + ' failed.'});
            }
        }

        console.log('http_post_enc(): POST ' + url + ' oReq.send: ' + encode_object_as_uri(obj));

        oReq.open("POST", url);
        oReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        oReq.send(encode_object_as_uri(obj));
    }

/*
 * http_get_enc()
 *  Make a get request with an urlencoded object as its url.
 */
    function http_get_enc(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();
        var uri = url + '?' + encode_object_as_uri(obj);
        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(oReq.response);
            } else {
                onloadfn({api_error: 'HTTP GET ' + uri + ' failed.'});
            }
        }

        console.log('http_get_enc(): GET ' + uri);

        oReq.open("GET", uri);
        oReq.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        oReq.send();
    }

/*
 * wellknown()
 *  retrieve wellknown services from pod at url then call onload(jsonObj)
 */
    function wellknown(url, name, onload) {
        http_get_json (
            url + '/.well-known/' + name,
            function(obj) { onload(obj); }
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

            if ('api_error' in obj) {
                onload(obj);
                return;
            }

            if (!('links' in obj)) {
                obj.api_error = 'No links to well known services found.'
                onload(obj);
                return;
            }

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
                }
            }

            if (ver > 0) {
                http_get_json(href, onload);
            } else {
                obj.api_error = 'No supported nodeinfo version found.';
                onload(obj);
            }

        }

        wellknown(url, 'nodeinfo', wellknown_onload);
    }

/*
 * diaspora_nodeinfo()
 *  Determine if pod hosts a diaspora instance. Call onload(jsonObj)
 *  or onload(undefined) if not a diaspora instance.
 */
    function diaspora_nodeinfo(onload) {
        var nodeinfo_onload = function(obj) {
            if ('protocols' in obj) {
                var proto;
                for(proto of obj.protocols) {
                    if (proto === 'diaspora') {
                        onload(obj);
                        return;
                    }
                }
                obj.api_error = 'Server does not support diaspora protocol.';
            }
            onload(obj);
        }
        nodeinfo(diaspora_pod_addr, nodeinfo_onload);
    }

/*
 * openid_discover()
 *  Determine if there is an openid service available and if so retrieve
 *  discovery information from pod at url then call onload(jsonObj)
 */
    function openid_discover(onload) {
        var wellknown_onload = function(obj) {
            console.log('openid_discover(): ' + JSON.stringify(obj));
            if (('registration_endpoint'  in obj) &&
                ('authorization_endpoint' in obj) &&
                ('token_endpoint'         in obj))
            {
//Discovery response contains various endpoints.
                openid_registration_endpoint  = obj.registration_endpoint;
                openid_authorization_endpoint = obj.authorization_endpoint;
                openid_token_endpoint         = obj.token_endpoint;
                onload(obj);
            } else {
                onload({});
            }
        }

        wellknown(
            diaspora_pod_addr,
            'openid-configuration',
            wellknown_onload
        );
    }

/*
 * openid_register_client()
 *  Register the example client with the diaspora server then call
 *  onload.
 */
    function openid_register_client(onload) {
        var registration_onload = function(obj) {
            console.log('openid_register_client(): ' + obj);
            openid_client_id = obj.client_id;
            console.log('openid_client_id: ', openid_client_id);
            onload(obj);
        }

//There are many possible fields including encryption. Example limited
//to the basics. DO NOT USE THIS CODE FOR PRODUCTION. IT IS NOT SECURE.
        var registration = {
            application_type: 'native',
            client_name: 'diaspora_client_example',
            redirect_uris: [redirect_uri]
        };

//Register client with diaspora server.
        http_post_json (
            openid_registration_endpoint,
            registration,
            registration_onload
        );
    }

/*
 * openid_authorize_client()
 * Creates an authorization request then opens up system default web
 * browser to allow the user to grant or deny access to the example
 * application. The C++/QML module 'redirectListener' must be open
 * and listening to the redirect_uri so it can get the authorization
 * code and state from the redirected HTTP GET command.
 */
    function openid_authorize_client(onload) {
        var authorization_onload = function(obj) {
            console.log(obj);
            onload(obj);
        };

//There are many possible fields including cryptographic mitigations
//for forgery and man in the middle attacks. DO NOT USE THIS CODE FOR
//PRODUCTION. IT IS NOT SECURE.
        var authorization = {
//This example is limited to reading private and public posts.
            scope: 'openid public:read',
//Using Authorization Code Flow
            response_type: 'code',
//ID retained from client request.
            client_id: openid_client_id,
//URI to return the user to after authorization is complete
            redirect_uri: redirect_uri,
//Code challenge based on generated code verifier used in token request.
//            code_challenge: openid_generate_code_challenge(),
//Code challenge method is a SHA256 base64-encoded string.
//            code_challenge_method: 'S256',
//FIXME:? Not sure yet but needs to be random.
            state: openid_state,
            nonce: Random.randomHexString(),
        }

//Open up system default web browser to service the request for example
//client access to the user at the pod. The C++/QML module 'redirectListener'
//must be open and listening to the redirect_uri at the specified port.
        console.log('Attempting authorization at:' +
                    openid_authorization_endpoint +
                    '?' +
                    encode_object_as_uri(authorization));
        Qt.openUrlExternally (
            openid_authorization_endpoint + '?' + encode_object_as_uri(authorization)
        );
    }

/*
 * openid_grant_access_token_via_pw()
 *  Once client has been registered and authorized by the user with
 *  the pluspora server use uname + password for further token
 *  requests.
 */
    function openid_grant_access_token_via_pw(uname, passwd, onload) {
        var grant_onload = function(obj) {
            console.log(obj);
            onload(obj);
        }

        var grant = {
            grant_type: 'password',
            username: uname,
            password: passwd,
            client_id: openid_client_id,
            client_secret: openid_client_secret,
        };

        http_post_enc (
            openid_token_endpoint,
            grant,
            grant_onload
        )
    }

    function openid_grant_access_token_via_oauth_code(onload) {
        var grant_onload = function(obj) {
            console.log(obj);
            var jsonobj = JSON.parse(obj);
            if ('error' in jsonobj) {
                jsonobj.api_error = jsonobj.error_description;
            }
            onload(jsonobj);
        }

        var grant = {
            grant_type: 'authorization_code',
            code: openid_code,
            redirect_uri: redirect_uri,
            client_id: openid_client_id,
//            code_verifier: openid_code_verifier,
        };

        http_post_enc (
            openid_token_endpoint,
            grant,
            grant_onload
        )
    }

//State machine.
    var connection_state = 'disconnected';

//Permitted states that any given state can transition to.
    var transitions = {
        'disconnected': { next: 'connecting' },
        'connecting': { next: 'diaspora_nodeinfo' },
        'diaspora_nodeinfo': { next: 'openid_discover'},
        'openid_discover': { next: 'openid_register_client' },
        'openid_register_client': { next: 'openid_authorize_client' },
        'openid_authorize_client': {next: 'openid_grant_access_token_via_oauth_code' },
        'openid_grant_access_token_via_oauth_code': { next: 'connected' },
        'connected': { next: 'disconnecting' },
        'disconnecting': { next: 'disconnected' }
    };

//Functions called when entering state matched to key.
    var functions = {
        disconnected: function(a) {},
        connecting: diaspora_nodeinfo,
        diaspora_nodeinfo: openid_discover,
        openid_discover: openid_register_client,
        openid_register_client: openid_authorize_client,
        openid_authorize_client: openid_grant_access_token_via_oauth_code,
        openid_grant_access_token_via_oauth_code: function(a) {},
        connected: function(a) {},
        disconnecting: function(a) {},
    };

/**********************************************************************
 * Public
 *********************************************************************/
 /*
  * transition()
  *  Transition to next state and call state function. On load is
  *  called after function is called.
  */
    this.transition = function(to, onload) {
        console.log(connection_state);
        if (to in transitions[connection_state]) {
            connection_state = transitions[connection_state][to];
            console.log('Transitioning to state: ' + connection_state);
            console.log(functions[connection_state]);
            functions[connection_state](onload);
        }
    }

/*
 * initialize()
 */
    this.init = function(addr) {
        diaspora_pod_addr = addr;
        openid_generate_state();
        openid_generate_code_verifier();
    }

/*
 * client_authorization_response()
 *
 */
    this.client_authorization_response = function(code, state) {
        console.log('Have ' + openid_state + ' Got: ' + state);
        if (state == openid_state) {
            openid_code = code;
            return {};
        } else {
            return {
                api_error: 'State returned by user authentication did not ' +
                           'match state that was sent. Unable to authorize.'
            }
        }
    }
};
