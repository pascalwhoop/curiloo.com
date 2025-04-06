---
title: Debugging a slow SSD on my arch home server
author: Pascal Brokmeier
layout: post
date: 2025-04-06
mathjax: false
tags: 
 - technology
excerpt: How I discovered that a missing fstrim timer was the culprit of an ever more degrading SSD on my N100 home server
---

## TL;DR

If your Arch-based system with an SSD feels oddly slow—check if TRIM is enabled. Arch won't do it for you.

Quick test:

```
systemctl status fstrim.timer
```

Quick fix:

```
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer
```


I've been running a mini PC (an Intel N100-based NUC) as a home server—Docker containers, monitoring, file sharing, the usual suspects. But something had been off lately: the system felt weirdly slow. Not CPU-bottleneck slow. Not RAM-starved slow. Just… laggy.

We're talking:
	•	`ls` taking multiple seconds.
	•	Shell autocomplete freezing mid-thought.
	•	`duf` and `fdisk -l`? Crawling.

This kind of lag is usually a sign of disk I/O issues. So, naturally, I dove in.


## First Stop: iostat

Running `iostat -xz 1 10` confirmed what I feared: the internal SSD (/dev/sda) wasn't doing much—but still felt terrible. Zero read/write throughput, 0% utilization… and yet the system lagged like the disk was busy rewriting War and Peace.

Meanwhile, one of my USB drives (/dev/sdc) was pegged at 99% utilization doing a background batch upload—and that performed just fine. No slowdown.

So the bottleneck wasn't about being busy. Something was stuck.


## Then Came smartctl

I checked the drive's health:

```
sudo smartctl -a /dev/sda
```

SMART data looked okay. No failing sectors, no excessive wear.

## And the Ah-Ha Moment: fstrim

SSDs need periodic TRIM to keep their performance up. Without it, deleted files aren’t properly erased, leading to slower writes and general sluggishness.

I checked the status of the systemd trim timer:

```
systemctl status fstrim.timer
```

Boom. Inactive.

On Arch, nothing is enabled by default—not even something as crucial as fstrim.timer. So even though the system had been deleting and churning files for months (thanks Docker), the SSD never got a chance to clean itself up.

## The Fix

Enabling TRIM was easy:

```
sudo systemctl enable fstrim.timer
sudo systemctl start fstrim.timer
```

Then I ran it manually once to kick things off:

```
sudo fstrim -av
```

It took a while—the SSD lit up like a disco ball, toggling between 100% read and 100% write utilization as it cleaned house. But after 10–15 minutes, things got better. Noticeably better.

`ls` was instant. Shell autocomplete snapped back to life. Even `fdisk -l` no longer acted like it had stage fright.


## Learning for myself

TRIM is how the OS tells the SSD which blocks are no longer used, allowing it to clean them up in the background. Without it, SSDs:
	•	Slow down dramatically as they fill up
	•	Wear out faster
	•	Cause bizarre slowdowns even with minimal I/O
