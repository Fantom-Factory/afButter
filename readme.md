#Butter v1.1.2
---
[![Written in: Fantom](http://img.shields.io/badge/written%20in-Fantom-lightgray.svg)](http://fantom.org/)
[![pod: v1.1.2](http://img.shields.io/badge/pod-v1.1.2-yellow.svg)](http://www.fantomfactory.org/pods/afButter)
![Licence: MIT](http://img.shields.io/badge/licence-MIT-blue.svg)

## Overview

`Butter` is a library that helps ease HTTP requests through a stack of middleware.

`Butter` is a replacement for [web::WebClient](http://fantom.org/doc/web/WebClient.html) providing an extensible chain of middleware for making repeated HTTP requests and processing the responses. The adoption of the Middleware pattern allows you to seamlessly enhance and modify the behaviour of your HTTP requests.

`Butter` was inspired by Ruby's [Faraday](https://github.com/lostisland/faraday) library.

## Install

Install `Butter` with the Fantom Repository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    C:\> fanr install -r http://repo.status302.com/fanr/ afButter

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afButter 1.1"]

## Documentation

Full API & fandocs are available on the [Status302 repository](http://repo.status302.com/doc/afButter/).

## Quick Start

1). Create a text file called `Example.fan`:

```
using afButter

class Example {
    Void main() {
        butter   := Butter.churnOut()
        response := butter.get(`http://www.fantomfactory.org/`)
        echo(response.body.str)
    }
}
```

2). Run Example.fan as a Fantom script from the command line:

```
C:\> fan Example.fan
<!DOCTYPE html>
<html>
    <head>
        <title>Home :: Fantom-Factory</title>
        ....
        ....
```

## Usage

An instance of [Butter](http://repo.status302.com/doc/afButter/Butter.html) wraps a stack of [Middleware](http://repo.status302.com/doc/afButter/ButterMiddleware.html) classes. When a HTTP request is made through `Butter`, each piece of middleware is called in turn. Middleware classes may either pass the request on to the next piece of middleware, or return a response. At each step, the middleware classes have the option of modifying the request and / or response objects.

The ordering of the middleware stack *is* important.

The last piece of middleware *MUST* return a response. These middleware classes are called *Terminators*. The default terminator is the [HttpTerminator](http://repo.status302.com/doc/afButter/HttpTerminator.html) which makes an actual HTTP request to the interweb. (When testing this could be substituted with a mock terminator that returns mocked / canned responses.)

To create a `Butter` instance, call the static [Butter.churnOut()](http://repo.status302.com/doc/afButter/Butter#churnOut.html) method, optionally passing in a custom list of middleware:

```
middlewareStack := [
    StickyHeadersMiddleware(),
    GzipMiddleware(),
    FollowRedirectsMiddleware(),
    StickyCookiesMiddleware(),
    ErrOn4xxMiddleware(),
    ErrOn5xxMiddleware(),
    ProxyMiddleware(),
    HttpTerminator()
]

butter := Butter.churnOut(middlewareStack)
```

Or to use the default stack of middleware bundled with `Butter`, just *churn and go*:

```
html := Butter.churnOut.get(`http://www.fantomfactory.org/`).body.str
```

## Butter Dishes

Because functionality is encapsulated in the middleware, you need to access these classes to configure them. Use the [Butter.findMiddleware()](http://repo.status302.com/doc/afButter/Butter#findMiddleware.html) method to do this:

```
butter := Butter.churnOut()
((FollowRedriectsMiddleware) butter.findMiddleware(FollowRedriectsMiddleware#)).enabled = false
((ErrOn5xxMiddleware) butter.findMiddleware(ErrOn5xxMiddleware#)).enabled = false
```

As you can see, this code is quite verbose. To combat this, there are two alternative means of getting hold of middleware:

### Dynamic Stylie

If you make dynamic invocation method calls on the `Butter` class, you can retrieve instances of middleware. The dynamic methods have the same simple name as the middleware type. If the type name ends with `Middleware`, it may be omitted. Example:

```
butter := Butter.churnOut()
butter->followRedriects->enabled = true
butter->errOn5xx->enabled = true
```

Should instances of the same middleware class be in the stack more than once (or should it contain 2 middleware classes with the same name from different pods) then the just first one is returned.

Obviously, dynamic invocation should be used with caution.

### Static Stylie

To call the middleware in a statically typed fashion, use a `ButterDish` class that holds your `Butter` instance and contains helper methods. There is a default [ButterDish](http://repo.status302.com/doc/afButter/ButterDish.html) class with methods to access middleware in the default stack. Example:

```
butter := ButterDish(Butter.churnOut())
butter.followRedirects.enabled = true
butter.errOn5xx.enabled = true
```

When using other middleware, you are encouraged to create your own `ButterDish` that extends the default one.

## Handling 404 and other Status Codes

If a 404, or a 4xx, status code is returned from a request then, by default, a [BadStatusErr](http://repo.status302.com/doc/afButter/BadStatusErr.html) is thrown. The same goes for 500 and 5xx status codes. In general this is what you want, a fail fast approach to erroneous status codes. But during testing it is often desirable to disable the errors and check / verify the status codes yourself. To do so, just disable the required middleware:

```
using afButter

class TestStatusCodes {
    Void test404() {
        butter := ButterDish(Butter.churnOut())
        butter.errOn4xx.enabled = false
        res := butter.get(`http://www.google.com/404`)
        verifyEq(res.statusCode, 404)
    }

    Void test500() {
        butter := ButterDish(Butter.churnOut())
        butter.errOn5xx.enabled = false
        res := butter.get(`http://www.example.com/500`)  // insert failing URL here
        verifyEq(res.statusCode, 500)
    }
}
```

## Calling RESTful Services

`Butter` has some convenience methods for calling RESTful services.

### GET

For a simple GET request:

```
butter   := ButterDish(Butter.churnOut())
response := butter.get(`http://example.org/`)
```

### POST

To send a POST request:

```
butter   := ButterDish(Butter.churnOut())
jsonObj  := ["wot" : "ever"]
response := butter.postJsonObj(`http://example.org/`, jsonObj)
```

### PUT

To send a PUT request:

```
butter   := ButterDish(Butter.churnOut())
jsonObj  := ["wot" : "ever"]
response := butter.putJsonObj(`http://example.org/`, jsonObj)
```

### DELETE

To send a DELETE request:

```
butter   := ButterDish(Butter.churnOut())
response := butter.delete(`http://example.org/`)
```

### Misc

For complete control over the HTTP requests, create a [ButterRequest](http://repo.status302.com/doc/afButter/ButterRequest.html) and set the headers and the body yourself:

```
butter   := ButterDish(Butter.churnOut())
request  := ButterRequest(`http://example.org/`) {
    it.method = "POST"
    it.headers.contentType = MimeType("application/json")
    it.body.str = """ {"wot" : "ever"} """
}
response := butter.sendRequest(req)
```

