# Metrics

One of the operational plugins. It's usually exercised by monitoring software.

This plugin is disabled by default and allows configuring the metrics to gather.
This configuration is made via the `#operations` config.

For example:

```smalltalk
Dictionary new
  at: #operations put: (
    Dictionary new
      at: #metrics put: {#enabled -> true. #metrics -> #('memory' 'http')} asDictionary;
      at: 'http' put: {#breakdownCategories -> #(http_method)}
      yourself
    );
  yourself
```

To get a list of supported metric providers print the result of `MetricProvider allProviderNames`.

Available metric providers:

- `memory` gathers metrics over the allocated memory (total, old space, free
  old space, eden space, young space)
- `garbage collection` gathers metrics over the garbage collector (time spent
  on garbage collection, invocation count and tenure count)
- `running system` gathers information over the running system (uptime,
  process count by status and priority, external semaphore table data)
- `http` (optional group) gathers information over the incoming HTTP requests
  (request count, request duration, response size by HTTP method, response code,
  URL and URL template). The categories used for the breakdown can be filtered
  by using the operations configuration, valid options are `#response_code`,
  `#http_method`, `#url` and `#url_template`. By default all categories are
  used for the breakdown.

## API

### Getting metrics

- Endpoint: `/metrics`
- Allowed HTTP methods: `GET`
- Supported media types:
  - `text/plain`: In prometheus client data exposition format
  - `text/vnd.stargate.prometheus.client-data-exposition;version=0.0.4`: The
    same as plain text but more explicit on the format
  - `application/vnd.stargate.operational-metrics+json`
- Authentication: Required
- Authorization: Requires `read:metrics`
- Expected Responses:
  - `200 OK`

Example responses:

```http
HTTP/1.1 200 OK
...
Content-Type: text/plain;version=0.0.4

# HELP smalltalk_memory_in_bytes Number of bytes of memory allocated in each category
# TYPE smalltalk_memory_in_bytes gauge
smalltalk_memory_in_bytes{category="total allocated"} 132259840 1573497970975
smalltalk_memory_in_bytes{category="old space"} 123307808 1573497970976
smalltalk_memory_in_bytes{category="free old space"} 26455232 1573497970976
smalltalk_memory_in_bytes{category="eden space"} 6854880 1573497970976
smalltalk_memory_in_bytes{category="young space"} 5384936 1573497970976
# HELP garbage_collection_time_in_milliseconds Cumulative number of milliseconds
# spent on Garbage Collection
# TYPE garbage_collection_time_in_milliseconds counter
garbage_collection_time_in_milliseconds{type="full"} 10119 1573497970976
garbage_collection_time_in_milliseconds{type="incremental"} 35656 1573497970976
# HELP garbage_collector_invocations Number of times the garbage collector was invocated
# TYPE garbage_collector_invocations counter
garbage_collector_invocations{type="full"} 84 1573497970976
garbage_collector_invocations{type="incremental"} 42741 1573497970976
# HELP tenured_objects_count Cumulative number of objects tenured by the
# Garbage Collector
# TYPE tenured_objects_count counter
tenured_objects_count 16250055
# HELP uptime_in_seconds Number of seconds since the system is started.
# TYPE uptime_in_seconds counter
uptime_in_seconds 18868.736
# HELP process_count Number of process scheduled in the running image
# TYPE process_count gauge
process_count{status="BLOCKED",priority="80"} 1 1573497970991
process_count{status="BLOCKED",priority="31"} 1 1573497970991
process_count{status="BLOCKED",priority="50"} 1 1573497970991
process_count{status="BLOCKED",priority="30"} 1 1573497970991
process_count{status="BLOCKED",priority="60"} 2 1573497970991
process_count{status="READY",priority="10"} 1 1573497970991
process_count{status="TERMINATED",priority="38"} 19 1573497970991
process_count{status="TERMINATED",priority="40"} 14 1573497970991
process_count{status="TERMINATED",priority="30"} 13 1573497970991
process_count{status="TERMINATED",priority="31"} 4 1573497970991
process_count{status="BLOCKED",priority="79"} 1 1573497970991
process_count{status="ACTIVE",priority="40"} 1 1573497970991
# HELP external_semaphore_count External semaphore table related data
# TYPE external_semaphore_count counter
external_semaphore_count{category="Max External Semaphores in VM"} 256 1573497970991
external_semaphore_count{category="Free external semaphore table slots"} 23 1573497970991
external_semaphore_count{category="Used external semaphore table slots"} 17 1573497970991
```

```json
HTTP/1.1 200 OK
...
Content-Type: application/vnd.stargate.operational-metrics+json

[
   {
      "name":"Smalltalk Memory in Bytes",
      "description":"Number of bytes of memory allocated in each category",
      "type":"Gauge",
      "value":287781912,
      "metrics":[
         {
            "timestamp":"2019-11-11T15:49:33.099401-03:00",
            "value":132259840,
            "category":"total allocated"
         },
         {
            "timestamp":"2019-11-11T15:49:33.099627-03:00",
            "value":123307808,
            "category":"old space"
         },
         {
            "timestamp":"2019-11-11T15:49:33.099831-03:00",
            "value":21855688,
            "category":"free old space"
         },
         {
            "timestamp":"2019-11-11T15:49:33.099846-03:00",
            "value":6854880,
            "category":"eden space"
         },
         {
            "timestamp":"2019-11-11T15:49:33.099854-03:00",
            "value":3503696,
            "category":"young space"
         }
      ]
   },
   {
      "name":"Garbage Collection Time in Milliseconds",
      "description":"Cumulative number of milliseconds spent on Garbage Collection",
      "type":"Counter",
      "value":46016,
      "metrics":[
         {
            "timestamp":"2019-11-11T15:49:33.099908-03:00",
            "value":10119,
            "type":"full"
         },
         {
            "timestamp":"2019-11-11T15:49:33.099945-03:00",
            "value":35897,
            "type":"incremental"
         }
      ]
   },
   {
      "name":"Garbage Collector invocations",
      "description":"Number of times the garbage collector was invocated",
      "type":"Counter",
      "value":43368,
      "metrics":[
         {
            "timestamp":"2019-11-11T15:49:33.099987-03:00",
            "value":84,
            "type":"full"
         },
         {
            "timestamp":"2019-11-11T15:49:33.099997-03:00",
            "value":43284,
            "type":"incremental"
         }
      ]
   },
   {
      "name":"Tenured objects count",
      "description":"Cumulative number of objects tenured by the Garbage Collector",
      "type":"Counter",
      "value":16299111
   },
   {
      "name":"Uptime in seconds",
      "description":"Number of seconds since the system is started.",
      "type":"Counter",
      "value":19070.857
   },
   {
      "name":"Process count",
      "description":"Number of process scheduled in the running image",
      "type":"Gauge",
      "value":75,
      "metrics":[
         {
            "timestamp":"2019-11-11T15:49:33.113007-03:00",
            "status":"BLOCKED",
            "value":1,
            "priority":80
         },
         {
            "timestamp":"2019-11-11T15:49:33.113049-03:00",
            "status":"BLOCKED",
            "value":1,
            "priority":31
         },
         {
            "timestamp":"2019-11-11T15:49:33.113058-03:00",
            "status":"BLOCKED",
            "value":1,
            "priority":50
         },
         {
            "timestamp":"2019-11-11T15:49:33.113066-03:00",
            "status":"TERMINATED",
            "value":19,
            "priority":40
         },
         {
            "timestamp":"2019-11-11T15:49:33.113072-03:00",
            "status":"BLOCKED",
            "value":1,
            "priority":30
         },
         {
            "timestamp":"2019-11-11T15:49:33.113079-03:00",
            "status":"TERMINATED",
            "value":1,
            "priority":60
         },
         {
            "timestamp":"2019-11-11T15:49:33.113086-03:00",
            "status":"READY",
            "value":1,
            "priority":10
         },
         {
            "timestamp":"2019-11-11T15:49:33.113093-03:00",
            "status":"BLOCKED",
            "value":2,
            "priority":60
         },
         {
            "timestamp":"2019-11-11T15:49:33.1131-03:00",
            "status":"TERMINATED",
            "value":20,
            "priority":38
         },
         {
            "timestamp":"2019-11-11T15:49:33.113107-03:00",
            "status":"TERMINATED",
            "value":18,
            "priority":30
         },
         {
            "timestamp":"2019-11-11T15:49:33.113113-03:00",
            "status":"TERMINATED",
            "value":6,
            "priority":31
         },
         {
            "timestamp":"2019-11-11T15:49:33.11312-03:00",
            "status":"TERMINATED",
            "value":2,
            "priority":79
         },
         {
            "timestamp":"2019-11-11T15:49:33.113126-03:00",
            "status":"BLOCKED",
            "value":1,
            "priority":79
         },
         {
            "timestamp":"2019-11-11T15:49:33.113133-03:00",
            "status":"ACTIVE",
            "value":1,
            "priority":40
         }
      ]
   },
   {
      "name":"External semaphore count",
      "description":"External semaphore table related data",
      "type":"Counter",
      "value":296,
      "metrics":[
         {
            "timestamp":"2019-11-11T15:49:33.113156-03:00",
            "value":256,
            "category":"Max External Semaphores in VM"
         },
         {
            "timestamp":"2019-11-11T15:49:33.113192-03:00",
            "value":23,
            "category":"Free external semaphore table slots"
         },
         {
            "timestamp":"2019-11-11T15:49:33.113212-03:00",
            "value":17,
            "category":"Used external semaphore table slots"
         }
      ]
   },
   {
     "name": "HTTP request count",
     "description": "Number of HTTP requests received",
     "type": "Counter",
     "value": 1,
     "metrics": [
       {
         "value": 1,
         "http_method": "GET",
         "url": "http://localhost:9999/operations/metrics",
         "timestamp": "2019-11-14T12:24:21.084248-03:00",
         "response_code": 200
       }
     ]
   },
   {
     "name": "HTTP response size in bytes",
     "description": "Size in bytes of content in the HTTP responses",
     "type": "Counter",
     "value": 2844,
     "metrics": [
       {
         "value": 2844,
         "http_method": "GET",
         "url": "http://localhost:9999/operations/metrics",
         "timestamp": "2019-11-14T12:24:21.084273-03:00",
         "response_code": 200
       }
     ]
   },
   {
     "name": "HTTP request/response duration in ms",
     "description": "Milliseconds to process a request and produce a response",
     "type": "Counter",
     "value": 15,
     "metrics": [
       {
         "value": 15,
         "http_method": "GET",
         "url": "http://localhost:9999/operations/metrics",
         "timestamp": "2019-11-14T12:24:21.08429-03:00",
         "response_code": 200
       }
     ]
   }   
]
```
