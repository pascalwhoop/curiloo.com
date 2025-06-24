---
title: Spin down HDDs on Linux for extra quiet desktops at night
author: Pascal Brokmeier
layout: post
date: 2017-11-22
options: "1200x500 Bottom"
mathjax: false
tags:
 - technology
excerpt: "How to get your hard drives to shut up while you are trying to sleep at night"
---

{{< fimg cover.jpg Crop "1920x1080" />}}

I often up/download large amounts of files while sleeping. I am still in the process of uploading my 600GB essential personal data offsite backup to AWS Glacier. With an average upload speed of 50-150KB, that takes a loooong time. So here are some tips to get the PC to shut up while asleep. This assumes your main disk is an SSD.

## 1. Make sure no application is accessing your hard drives

I have my HDDs in a ZFS cluster and one extra HDD that backs up the data of that ZFS, just in case. I don't have much experience with ZFS and didn't want to trust the system my personal data without a simple backup that I can wrap my head around. 
The cluster is mounted on `~/tank`, hence I can watch all activity on the cluster with the following command

```
inotifywait -mr --format "%T: %e --- %f%w" ~/tank/
```

I leave this running for a day and find out that the only thing that is accessing my hard drives is Albert (a clone of the OSX Alfred) every 4 hours. Good enough, that's a decent quiet time.

## Put your hard drives to sleep

I have a simple script that stops the only processes that wake my HDDs up and puts them all to sleep. I call it 'silence'.

```shell
function silence(){
	echo "spinning down hard drives of zfs pool"
	sudo hdparm -Y /dev/sda
	sudo hdparm -Y /dev/sdb
	sudo hdparm -Y /dev/sdc
	sudo hdparm -Y /dev/sdd
	sudo hdparm -Y /dev/sde
	sudo hdparm -Y /dev/sdg
	docker container stop plex
	pkill albert
}
```

to check on them and to make sure they're actually all asleep (in case my ears don't work) I have the `issilence` check

```shell
function issilence(){
	sudo hdparm -C /dev/sda
	sudo hdparm -C /dev/sdb
	sudo hdparm -C /dev/sdc
	sudo hdparm -C /dev/sdd
	sudo hdparm -C /dev/sde
      }
```

ok. Now they are quiet. But what about once they spin up again when albert does it's thing?

## Making them quiet on a regular basis, i.e. automatically spin down

Lastly, I need to tell the drives to shut up after a defined amount of time. For me that's 10 minutes of inactivity. See
[here](https://askubuntu.com/questions/39760/how-can-i-control-hdd-spin-down-time) and [here](https://askubuntu.com/questions/252039/how-can-i-find-out-the-current-drive-spin-down-time) on askubuntu.com for a discussion what the difference is between `-B` and `-S`. 

```shell
function alwayssilence(){
	#setting their Advanced Power Management Features, see man hdparm for details
	sudo hdparm -B 40 /dev/sda
	sudo hdparm -B 40 /dev/sdb
	sudo hdparm -B 40 /dev/sdc
	sudo hdparm -B 40 /dev/sdd
	sudo hdparm -B 40 /dev/sde
	#setting their sleep timeout to 120 and put to sleep right away
	sudo hdparm -S 120 /dev/sda
	sudo hdparm -S 120 /dev/sdb
	sudo hdparm -S 120 /dev/sdc
	sudo hdparm -S 120 /dev/sdd
	sudo hdparm -S 120 /dev/sde
}
```
