# Adam

* http://github.com/jgorset/adam

## Description

Adam is a library for all things [EVE](http://www.eveonline.com/).

## Features

* Parses killmails
* Parses kill logs
* Imports killmails from EDK-compatible feeds

## Synopsis

### Parse a killmail

    kill = Adam::Killmail.parse(killmail)
  
    kill.time                     # => 2010-09-23 15:43:04 +0200
    kill.solar_system.name        # => Murethand
    kill.victim.pilot             # => Caelum Dominus
    kill.victim.corporation       # => Invicta.
    kill.loot[0].name             # => Warp Disruptor II
    kill.loot[0].quantity         # => 1
  
### Parse a kill log

    kill = Adam::KillLog.parse(kill_log)
  
    kill.time                     # => 2010-09-23 15:43:04 +0200
    kill.solar_system.name        # => Murethand
    kill.victim.pilot             # => Caelum Dominus
    kill.victim.corporation       # => Invicta.
    kill.loot[0].name             # => Warp Disruptor II
    kill.loot[0].quantity         # => 1
  
    kill.to_s                     # => Kill log's killmail equivalent.
  
### Import killmails
  
    killboard = Adam::Killboard.new :uri => 'http://invicta.eve-kill.net/', :feed_uri =>  'http://feed.evsco.net/?a=feed&corp=Invicta.&combined=true'
    killboard.killmails :week => 1, :year => 2010
  

## Requirements

* Ruby 1.9
* Hpricot
* ActiveRecord (see note)
* MySQL (see note)

Note: ActiveRecord and MySQL are only required if you don't want to roll your own implementation for the "SolarSystem", "Item" and "Faction" classes.

## Install

    gem install adam

## License

(The MIT License)

Copyright (c) 2010 Johannes Gorset

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
