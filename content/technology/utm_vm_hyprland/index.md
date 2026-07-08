---
title: Setting up a new Arch Linux VM on UTM on a Macbook M4
author: Pascal Brokmeier
layout: post
# cover: cover.jpg
date: 2025-06-04
# cover-credit: 
mathjax: false
categories:
 - technology
tags: 
 - linux
 - arch
 - vm
 - mac
 - m4
excerpt: 
---

## Notes

- Following this video guide: https://www.youtube.com/watch?v=cOobSmI-XgA
- as well as arch linux default installation guide https://wiki.archlinux.org/title/Installation_guide
- pacstrap command

    ```
    pacstrap -K /mnt base linux linux-firmware e2fsprogs dhcpcd networkmanager vim neovim git man-db man-pages tldr nnn stow
    ```
- after arch-chroot I also had to do [this reset](https://wiki.archlinux.org/title/Pacman/Package_signing#Resetting_all_the_keys) of the arch GPG keys for pacman to work
