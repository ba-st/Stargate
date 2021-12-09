# How to generate the operation tokens manually

When using JWT as the authentication scheme for the operational plugins, the
incoming API calls need to provide a Bearer token with the required permissions encoded.

> In production, these tokens are usually coming from an Auth provider (like
> [Auth0](https://auth0.com)).

For testing, you can generate the tokens manually:

1. Get a Pharo image with Stargate loaded
2. Print the result of evaluating:

    ```smalltalk
    | jws |

    jws := JsonWebSignature new.
    jws algorithmName: JWAHMACSHA256 parameterValue.
    jws
      payload:
        ( JWTClaimsSet new
          permissions:
            #('read:operations'
              'read:metrics'
              'execute:health-check'
              'read:application-info'
              'execute:application-control'
              'read:application-configuration');
          yourself ).
    jws key: 'SECRET'.
    jws compactSerialized
    ```

    replacing `SECRET` by the actual secret key and tunning the permissions if required
