# Butter

`Butter` is a [Fantom](http://fantom.org/) library that helps ease the sending of HTTP requests.

`Butter` is a replacement for `WebClient` and provides an extensible chain of middleware for making HTTP requests and processing the response.
The adoption of the Middleware pattern allows you to seamlessly enhance and modify the behaviour of your HTTP requests.

`Butter` was inspired by Ruby's [Faraday](https://github.com/lostisland/faraday) library.


## Install

Install `Butter` with the Fantom Respository Manager ( [fanr](http://fantom.org/doc/docFanr/Tool.html#install) ):

    $ fanr install -r http://repo.status302.com/fanr/ afButter

To use in a [Fantom](http://fantom.org/) project, add a dependency to `build.fan`:

    depends = ["sys 1.0", ..., "afButter 0+"]



## Documentation

Full API & fandocs are available on the [status302 repository](http://repo.status302.com/doc/afButter/#overview).



## Quick Start

1). Create a text file called 'Example.fan':

    using afButter

    class Example {
        Void main() {
            butter   := Butter.churnOut()
            response := butter.get(`http://www.fantomfactory.org/`)
            echo(response.asStr)
        }
    }

2). Run Example.fan as a Fantom script from the command line:

    C:\> fan Example.fan
    <!DOCTYPE html>
    <html>
        <head>
            <title>Home :: Fantom-Factory</title>
            ....
            ....

