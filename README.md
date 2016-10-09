# Eavesdrop

This is the reboot of Eavesdrop (described
[here](http://lifehacker.com/5964202/eavesdrop-for-rdio-lets-you-listen-in-on-your-friends-music-streams)). The
goal is to provide a generic backend which can function against ANY
music service. My idea is to build a simple prototype frontend in Elm
which will talk to a web module in this library. That web module may
start life as a [Plug](https://github.com/elixir-lang/plug) or it may
be a full Phoenix application; TBD.

In the mean time, feel free to play with this simple example

```
iex -S mix run

iex(1)> EavesdropOTP.user_signin "sean"
Hi sean, welcome back
:ok
iex(2)> EavesdropOTP.play_track "Memphis Bells"
You are now listening to Memphis Bells on Rdio
:ok
iex(3)> EavesdropOTP.user_stop
Idle
:ok
iex(4)> EavesdropOTP.play_track "Soul Meets Body"
You are now listening to Soul Meets Body on Rdio
:ok
iex(5)> EavesdropOTP.user_signout
See you next time
:ok
```


<?xml version="1.0" standalone="no"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">

<svg width="800" height="600" version="1.1" xmlns="http://www.w3.org/2000/svg">
    <ellipse stroke="black" stroke-width="1" fill="none" cx="145.5" cy="227.5" rx="30" ry="30"/>
    <text x="121.5" y="233.5" font-family="Times New Roman" font-size="20">signin</text>
    <ellipse stroke="black" stroke-width="1" fill="none" cx="306.5" cy="129.5" rx="30" ry="30"/>
    <text x="291.5" y="135.5" font-family="Times New Roman" font-size="20">idle</text>
    <ellipse stroke="black" stroke-width="1" fill="none" cx="416.5" cy="208.5" rx="30" ry="30"/>
    <text x="399.5" y="214.5" font-family="Times New Roman" font-size="20">play</text>
    <ellipse stroke="black" stroke-width="1" fill="none" cx="416.5" cy="208.5" rx="24" ry="24"/>
    <path stroke="black" stroke-width="1" fill="none" d="M 117.716,216.498 A 22.5,22.5 0 1 1 137.332,198.755"/>
    <polygon fill="black" stroke-width="1" points="137.332,198.755 141.449,190.267 131.506,191.335"/>
    <path stroke="black" stroke-width="1" fill="none" d="M 411.609,238.038 A 136.893,136.893 0 0 1 154.465,256.066"/>
    <polygon fill="black" stroke-width="1" points="411.609,238.038 404.633,244.389 414.261,247.091"/>
    <path stroke="black" stroke-width="1" fill="none" d="M 445.859,202.929 A 22.5,22.5 0 1 1 438.78,228.415"/>
    <polygon fill="black" stroke-width="1" points="438.78,228.415 439.843,237.789 447.672,231.567"/>
    <path stroke="black" stroke-width="1" fill="none" d="M 333.286,116.498 A 70.528,70.528 0 0 1 420.264,178.965"/>
    <polygon fill="black" stroke-width="1" points="333.286,116.498 342.242,119.46 339.873,109.745"/>
    <path stroke="black" stroke-width="1" fill="none" d="M 387.626,215.919 A 77.259,77.259 0 0 1 308.694,159.231"/>
    <polygon fill="black" stroke-width="1" points="387.626,215.919 379.353,211.385 379.926,221.369"/>
    <path stroke="black" stroke-width="1" fill="none" d="M 392.648,226.659 A 225.248,225.248 0 0 1 171.653,242.153"/>
    <polygon fill="black" stroke-width="1" points="171.653,242.153 176.728,250.105 181.025,241.075"/>
</svg>


## Installation

cd into the repo and run a `mix do deps.get, deps.compile`, then run the project with `iex -S mix`
