
![HackyHal](https://raw.github.com/nickewing/hacky_hal/master/support/hal-9000-small.png) HackyHAL
========

What is it?
-----------

HackyHAL (Hacky Home Automation Library) is in its current form is a small library meant to control devices
through the network or serial ports.  The supported number of devices is
currently very limited, however I hope the library will grow to support more devices over time.

Who is this for?
----------------
This project is for anyone wishing to write their own custom home automation
software/scripts.  It is not user friendly and does not have any form of
built-in UI.

What devices are supported?
---------------------------
Supported functionality varies greatly with each device.

* **Epson Projector** (via serial port.  Tested on HC8350, though likely also
  works with other models)
* **Yamaha AV Receiver** (via network.  Tested on RX-A1020.  Should work with
  RX-A2020 and RX-A3020 as well)
* **Roku** (via network)
* **Iogear AVIOR HDMI Switch** (via serial port. 8x1 GHSW8181 or 4x1 GHSW8141)
* **SSH accessible computer**

How can I use it?
-------------------
HackyHAL is simply a library to be used however you want.

You'll likely want to run a server utilizing HackyHAL on a networked computer (a
Raspberry Pi works great).
You'd then attach any serial port devices to that computer.  You could then
create a mobile app to control the server.  See the examples directory.

Can I contribue?
----------------
Please do!  It would be great to see this library grow to support many more
devices.  Just fork, make your changes, and send a pull request.  Please be sure
to write tests for contributions.

Contributors
------------
* Nick Ewing

Special thanks to [Mischa McLachlan](https://www.iconfinder.com/icons/27626/9000_hal_light_red_space_icon) for the HAL 9000 icon.

License and Copyright
---------------------

HackyHA is distributed under the MIT License.  See LICENSE.

Copyright © 2013 Nick Ewing

