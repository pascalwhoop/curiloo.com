---
title: Starting to screencast about my thesis and machine learning
author: Pascal Brokmeier
layout: post
cover: cover.jpg
date: 2018-03-21
cover-credit: 
mathjax: false
categories:
 - technology
tags: 
 - technology
 - blog
 - screencast
 - linux
excerpt: I am starting to upload screencasts about my developments of the agent for my thesis. This is the initial video
---

> An updated version of this post is available [here](/technology/2018/04/15/Turning_your_Linux_computer_into_a_screencast_station_for_pareto_principle_level_professionality.html)

I have posted my first video on YouTube about how to do screencasts on Linux with free tools and without having to
invest heavily into hardware. I only added a microphone to the mix but even that I had lying around already for
recording music. It's not ideal for screencasts because it is made to record stereo full room sound but it's a good
start. 

{{< youtube CQzPwWBdswI>}}

These are the basic things you need:

- Good mic
- Solid Wifi & Upload
- Smartphone
- Decent PC
- Clean background (unlike me)
- Jack Audio for Linux
- SimpleScreenRecorder for Linux


To use your phone as a webcam, get a tripod or some books and download 
[this app](https://play.google.com/store/apps/details?id=ronakpatel1311.camerastreamer) and connect to it via the
browser. Optionally install `node` and `npm` then run `npm install -g nativefier` to then run 

```
nativefier -i ~/Desktop/cam.png -n PhoneCam --inject /home/pascalwhoop/Desktop/custom_css_cam.css  --width 1280 --height
720 http://192.168.1.203:8080/
```

Let me know how the tools work out for you. 
