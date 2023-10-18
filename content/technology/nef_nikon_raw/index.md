---
title: Getting the capture date in a .NEF Nikon raw file with python
author: Pascal Brokmeier
layout: post
date: 2018-01-24
cover: cover.jpg
mathjax: false
tags:
 - technology
excerpt:
---

While importing all of my Google Photos into my local library in the process of deleting everything, I needed to get the capture times of about 20k `.NEF` files from my library. I used those to compare files with the same name (`DSC_1000.jpg` `DSC_1000.NEF`) to verify if these are in-fact the same files or just have the same serial number.

Because I am also learning python (great language btw), I am processing everything in python.

So assuming you have a list of `.NEF` files, this is how you can get the capture date out of the files

```
def NEF_date_of_cap(path):
    """very hacky, but I am just interested in the capture date, don't care about the rest. This is JUST grabbing that, being very efficient but only works for NEF"""
    raw_chunk = open(path, 'rb')
    raw_chunk.seek(2964)
    capture_date_bin = raw_chunk.read(19)
    return str(capture_date_bin)[2:-1]


def make_nef_meta(path):
    img_meta = [path,None,filename_from_path(path)]
    #and add the capture date with the hacky binary trick
    img_meta[1] = NEF_date_of_cap(path)
    return img_meta

nef_meta = [make_nef_meta(img) for img in nef_files]
```

How fast was this? Unbelievably fast compared to reading the whole file into memory and then slicing. The `seek()` really did it's job.

If you have a Canon instead, it is easy to adapt this. Simply check the file with

```
xxd raw_file.crw | grep 2017
```

## Update

I found out that this offset depends on the camera model that you are using. I was using a D5300 but later used a D7100 and the offset was different. So I think it is best if you check with your `xxd` tool and get the timestamp location right. Otherwise though, it's working just as before, once you have the *exact* location of the timestamp, just steal it straight from the binary instead of loading the whole file into memory first.

if you took it in 2017 for example. Then find the exact byte location of the capture date and adapt the `seek()` and `read()` statements above.
