/*
  Minimal javascript implementation for diaspora API version 1.
*/
var V1 = function(args) {

/**********************************************************************
 * Private
 *********************************************************************/

    const insecure_warning = '' +
    'NOTICE: This client example is intended for use as a test of the ' +
    'Diaspora API. It does NOT implement certain OpenID security ' +
    'measures. It does not require encrypted (https) endpoints. DO NOT ' +
    'USE THIS CODE IN PRODUCTION.';

//Location of diaspora pod.
    var diaspora_pod_addr = '';

/**********************************************************************
 * HTTP Implementation
 *********************************************************************/

/*
 * http_encode_object_as_uri(obj)
 */
    function http_encode_object_as_uri(obj) {
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
    function http_get_json(url, onloadfn, auth) {
        var oReq = new XMLHttpRequest();

        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(JSON.parse(oReq.response));
            } else {
                onloadfn({api_error: 'HTTP GET ' + url + ' failed.'});
            }
        }

        console.log('http_get_json(): GET ' + url);

        oReq.open('GET', url);
        oReq.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
        if(auth) {
            console.log('http_get_json(): Authorization Header: ' + auth);
            oReq.setRequestHeader('Authorization', auth);
        }
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

        console.log('http_post_json(): POST ' +
                    url +
                    ' * oReq.send: ' +
                    JSON.stringify(obj));

        oReq.open('POST', url);
        oReq.setRequestHeader('Content-Type', 'application/json;charset=UTF-8');
        oReq.send(JSON.stringify(obj));
    }

/*
 * http_post_enc()
 *  POST a urlencoded object.
 */
    function http_post_enc(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();
        var data = http_encode_object_as_uri(obj)

        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(oReq.response);
            } else {
                onloadfn({api_error: 'HTTP POST ' + url + ' failed.'});
            }
        }

        console.log('http_post_enc(): POST ' +
                    url + ' oReq.send: ' + data);

        oReq.open('POST', url);
        oReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        oReq.send(data);
    }

/*
 * http_get_enc()
 *  Make a get request with an urlencoded object as its url.
 */
    function http_get_enc(url, obj, onloadfn) {
        var oReq = new XMLHttpRequest();
        var uri = url + '?' + http_encode_object_as_uri(obj);
        oReq.onload = function(e) {
            if (oReq.response) {
                onloadfn(oReq.response);
            } else {
                onloadfn({api_error: 'HTTP GET ' + uri + ' failed.'});
            }
        }

        console.log('http_get_enc(): GET ' + uri);

        oReq.open('GET', uri);
        oReq.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
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
            var href = '';

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

/**********************************************************************
 * OpenID + OAuth Implementation.
 *********************************************************************/

//Diaspora server's url for registering this application as a client.
//Obtained after querying openid-configuration from the wellknown services.
    var openid_registration_endpoint = '';

//Diaspora server's url for authorizing this application to read posts.
//Obtained after querying openid-configuration from the wellknown services.
    var openid_authorization_endpoint = '';

//Diaspora server's url for getting a token. Obtained after querying
//openid-configuration from the wellknown services.
    var openid_token_endpoint = '';

//JWKS endpoint stores the public key used to authenticate access tokens.
//Obtained after querying openid-configuration from the wellknown services.
    var openid_jwks_uri = ''; //FIXME: Unused.

//OpenID client id issued to the example client by the diaspora server.
//Obtained after registering client with the diaspora server.
    var openid_client_id = '';

//OpenID client secret issued to the example client by the diaspora server.
//Obtained after registering client with the diaspora server.
    var openid_client_secret = '';

//Client example opens the system default web browser so user can
//authorize access to their information on the diaspora server. After
//the user grants or denies access the web browser is redirected by the
//diaspora server to a listening port opened by the client example.
    var openid_redirect_uri = '';

//OpenID state item sent to browser as part of the user authorization.
//Set by init() function.
    var openid_client_state = '';

//OpenID code returned by browser to the listening port at the redirect
//uri. This is set after the listener receives the GET redirection and
//calls client_authorization_response(code,state).
    var openid_code = '';

//OpenID token permits client example to access user's account data.
    var openid_token = {
        access_token: '',
        token_type: '',
        refresh_token: '',
        expires_in: '',
        id_token: ''
    };

/*
 * openid_generate_state()
 *  Generate a random value to be used as a state argument.
 */
    function openid_generate_state(obj) {
        openid_client_state = Random.randomHexString();
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
                ('token_endpoint'         in obj) &&
                ('jwks_uri'               in obj))
            {
//Discovery response contains various endpoints.
                openid_registration_endpoint  = obj.registration_endpoint;
                openid_authorization_endpoint = obj.authorization_endpoint;
                openid_jwks_uri               = obj.jwks_uri;
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
            console.log('openid_register_client(): ' + JSON.stringify(obj));
            if (('client_id'     in obj) &&
                ('client_secret' in obj))
            {
                openid_client_id = obj.client_id;
                openid_client_secret = obj.client_secret;
            } else {
                obj.api_error = 'No client ID or client secret were provided. ' +
                                'Unable to register client.';
            }

            onload(obj);
        }

//There are many possible fields including encryption. Example limited
//to the basics. DO NOT USE THIS CODE FOR PRODUCTION.
        console.log(insecure_warning + ' ' +
                    'REASON: Example client does basic OAuth2 ' +
                    'registration and does not use security features.' );

        var registration = {
            application_type: 'native',
            client_name: 'diaspora_client_example',
            redirect_uris: [openid_redirect_uri]
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
 * application. The C++/QML module 'RedirectListener' must be open
 * and listening to the openid_redirect_uri so it can get the
 * authorization code and state from the redirected HTTP GET command.
 */
    function openid_authorize_client(onload) {
        var authorization_onload = function(obj) {
            console.log(obj);
            onload(obj);
        };

//There are many possible fields including cryptographic mitigations
//for forgery and man in the middle attacks. DO NOT USE THIS CODE FOR
//PRODUCTION.
        console.log(insecure_warning + ' ' +
                    'REASON: Example client authorization does not ' +
                    'use OAuth2 security features.');

        var authorization = {
//Using Authorization Code Flow
            response_type: 'code',
//ID retained from client request.
            client_id: openid_client_id,
//URI to return the user to after authorization is complete
            redirect_uri: openid_redirect_uri,
//This example is limited to reading private and public posts.
            scope: 'openid public:read contacts:read',
//FIXME:? Not sure yet but needs to be random.
            state: openid_client_state,
        };

//Open up system default web browser to service the request for example
//client access to the user at the pod. The C++/QML module 'redirectListener'
//must be open and listening to the redirect_uri at the specified port.
        var uri = openid_authorization_endpoint + '?' +
                  http_encode_object_as_uri(authorization);
        console.log('Attempting authorization at: ' + uri);
        Qt.openUrlExternally(uri);
    }

    function openid_grant_access_token_via_oauth_code(onload) {
        var grant_onload = function(json) {
            console.log(json);

            var obj = JSON.parse(json);
            if ('error' in obj) {
                obj.api_error = obj.error_description;
            }

            if (('access_token'  in obj) &&
                ('refresh_token' in obj) &&
                ('token_type'    in obj) &&
                ('expires_in'    in obj) &&
                ('id_token'      in obj))
            {
                openid_token.access_token  = obj.access_token;
                openid_token.refresh_token = obj.refresh_token;
                openid_token.token_type    = obj.token_type;
                openid_token.expires_in    = obj.expires_in;
                openid_token.id_token      = obj.id_token;
            } else {
                obj.api_error = 'ID token header does not contains expected fields.';
                onload(obj);
                return;
            }

//Validate ID token.
//ID token is a JSON Web Signature (JWS). JWS contains a dot '.'
//delimited list of individually Base64 encoded header, payload
//and signature. Why? Because webdev.
            var id_token_lst = obj.id_token.split('.');

//Parse JWS segments.
            var id_token = {
                header: JSON.parse(Qt.atob(id_token_lst[0])),
                payload: JSON.parse(Qt.atob(id_token_lst[1])),
                signature: Qt.atob(id_token_lst[2]),
            }

//Validate the ID Token Header.
            if (!((id_token.header.typ === 'JWT')    &&
                  (id_token.header.alg === 'RS256')  &&
                  (id_token.header.kid === 'default')))
            {
                obj.api_error = 'ID token header contains an unexpected value.';
                onload(obj);
                return;
            }

//Check ID Token Payload.
//Payload contains many optional fields. Check, log discrepancies but
//but do not return error.
            if ('aud' in id_token.payload) {
                //aud - Audience contains client id
                if (id_token.payload.aud !== openid_client_id) {
                    console.log('JWT Audience does not match client id');
                }
            }

            if ('exp' in id_token.payload) {
                //exp - Expiration date of the claim.
                var time = Math.round(new Date() / 1000);
                if (id_token.payload.exp <= time) {
                    console.log('JWT claim has expired. Got Time: ' +
                                id_token.payload.exp +
                                ' Current Time: ' + time);
                }
            }

//Validate the ID Token Signature.
            console.log(insecure_warning + ' ' +
                        'REASON: Example client does not perform JWS ' +
                        'signature verification.' );

            onload(obj);
        }

//Grant structure.
        var grant = {
            grant_type: 'authorization_code',
            code: openid_code,
            redirect_uri: openid_redirect_uri,
            client_id: openid_client_id,
            client_secret: openid_client_secret
        };

        http_post_enc (
            openid_token_endpoint,
            grant,
            grant_onload
        );
    }

    function diaspora_api_call(path, onload) {
        if (connection_state === 'connected') {
            http_get_json (
                diaspora_pod_addr + path,
                onload,
                'Bearer ' + openid_token.access_token
            );
        } else {
            return {api_error: 'Client example not connected.'};
        }
        return {};
    }

/**********************************************************************
 * Connection State Machine
 *********************************************************************/

//State machine.
    var connection_state = 'disconnected';

//Permitted states that any given state can transition to.
    var transitions = {
        'disconnected': {
            next: 'connecting',
            cancel: 'disconnecting'
        },
        'connecting': {
            next: 'diaspora_nodeinfo',
            cancel: 'disconnecting'
        },
        'diaspora_nodeinfo': {
            next: 'openid_discover',
            cancel: 'disconnecting'
        },
        'openid_discover': {
            next: 'openid_register_client',
            cancel: 'disconnecting'
        },
        'openid_register_client': {
            next: 'openid_authorize_client',
            cancel: 'disconnecting'
        },
        'openid_authorize_client': {
            next: 'openid_grant_access_token_via_oauth_code',
            cancel: 'disconnecting'
        },
        'openid_grant_access_token_via_oauth_code': {
            next: 'connected',
            cancel: 'disconnecting'
        },
        'connected': {
            next: 'disconnecting',
            cancel: 'disconnecting'
        },
        'disconnecting': {
            next: 'disconnected',
            cancel: 'disconnected'
        }
    };

//Functions are called when entering state matched to key.
    var functions = {
        //Disconnected. Place holder state.
        disconnected:
            function(onload) {
                onload({'connected': false});
            },
        //Connecting.
        connecting:
            function(onload) {
                openid_generate_state();
                onload({'connected': false});
            },
        //Get nodeinfo.
        diaspora_nodeinfo:
            diaspora_nodeinfo,

        //Have nodeinfo. Find openid endpoint.
        openid_discover:
            openid_discover,

        //Found openid endpoint. Register example client.
        openid_register_client:
            openid_register_client,

        //Client registered. Have user authorize.
        openid_authorize_client:
            openid_authorize_client,

        //User authorized. Get token for access.
        openid_grant_access_token_via_oauth_code:
            openid_grant_access_token_via_oauth_code,

        //Connected. Placeholder state.
        connected:
            function(onload) {
                onload({'connected': true});
            },

        disconnecting:
            function(onload) {
                //FIXME: Do some disconnecting.
                onload({'disconnecting': true});
            },
    };

/**********************************************************************
 * Public
 *********************************************************************/

 /*
  * get_message()
  */
    this.get_message = function() {
        return insecure_warning;
    }

 /*
  * transition()
  *  Transition to next state and call state function. On load is
  *  a function passed to the state function which will be called.
  */
    this.transition = function(to, onload) {
        console.log(connection_state);
        if (to in transitions[connection_state]) {
            connection_state = transitions[connection_state][to];
            console.log('Transitioning to state: ' + connection_state);
            console.log('Transition function: ' + functions[connection_state]);
            console.log('Onload function: ' + onload);
            functions[connection_state](onload);
        }
    }

/*
 * Initialize connection.
 */
    this.init = function(pod_addr, redir_uri) {
        if (connection_state === 'disconnected') {
            openid_redirect_uri = redir_uri;
            diaspora_pod_addr = pod_addr;
        } else {
            console.log("init(): Not disconnected! State: " + connection_state)
        }
    }

    this.disconnect = function(onload) {
        if (connection_state === 'connected') {
            this.transition('next', onload); //disconnecting.
        } else {
            console.log("init(): Not connected! State: " + connection_state)
        }
    }

/*
 * client_authorization_response()
 *  Set response from user after the diaspora server provides it to the
 *  port listening at openid_redirect_uri.
 */
    this.client_authorization_response = function(code, state) {
        console.log('Have ' + openid_client_state + ' Got: ' + state);
        if (state == openid_client_state) { //Without type cohersion this doesn't work.
            openid_code = code;
            return {};
        } else {
            return {
                api_error: 'State returned by user authentication did not ' +
                           'match state that was sent. Unable to authorize.'
            }
        }
    }

/*
 * api_get_main_stream()
 *  Get the first page of posts in the user's stream.
 */
    this.api_get_main_stream = function(onload) {
        return diaspora_api_call('/api/v1/streams/main', onload);
    }

/*
 * api_get_person()
 *  Get the first page of posts in the user's stream.
 */
    this.api_get_person = function(guid, onload) {
        return diaspora_api_call('/api/v1/users/:' + guid, onload);
    }
};
