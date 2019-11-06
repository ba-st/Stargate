# Health Check

One of the operational plugins. It's usually exercised by monitoring software to alert if a running instance gets unhealthy for some reason.

In the future this plugin will allow additional checks to be run. The infrastructure is almost ready just new checks needs to be implemented.

In case there are multiple checks, the general status will be the worst status of the checks run. Every check status can be accessed asking for the details media type and looking at the details object.

Supported Statuses:
- `PASS` represents a healthy condition for the check run
- `WARN` represents a sick condition, the check has measured a property and detected that it's approaching the failure threshold (for example low disk space)
- `FAIL` represents a critical condition, the application cannot work reliably until the situation is fixed

## API

### Running a health check

- Endpoint: `/health-check`
- Allowed HTTP methods: `POST`
- Supported media types:
  - `application/vnd.stargate.health-check.details+json`
  - `application/vnd.stargate.health-check.summary+json`
- Authentication: Required
- Authorization: Requires `execute:health-check` permission if the requested media type is detailed. The summary media type can be obtained without permissions but still requires authentication.
- Expected Responses:
  - `200 OK` if the overall health condition is not critical
  - `503 Service Unavailable` if the overall health condition is critical

Example responses:

```
HTTP/1.1 503 Service Unavailable
...
Content-Type: application/vnd.stargate.health-check.details+json;version=1.0.0

{
   "status":"FAIL",
   "details":{
      "warning-check":{
         "status":"WARN",
         "details":{ }
      },
      "success-check":{
         "status":"PASS",
         "details":{ }
      },
      "failed-check":{
         "status":"FAIL",
         "details":{ }
      }
   }
```

```
HTTP/1.1 200 OK
...
Content-Type: application/vnd.stargate.health-check.summary+json;version=1.0.0

{"status":"PASS"}
```

```
HTTP/1.1 503 Service Unavailable
...
Content-Type: application/vnd.stargate.health-check.details+json;version=1.0.0

{
   "status":"FAIL",
   "details":{
      "low-disk-space":{
         "status":"FAIL",
         "details":{
            "total":60000,
            "free-space":50000
         }
      }
   }
}
```
