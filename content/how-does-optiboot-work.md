Title: How does Optiboot work?
Date: 07.07.2020
Modified: 07.07.2020
Status: draft
Tags: pelican, publishing
Keywords: pelican, publishing
Slug: how-does-optiboot-works
Author: Andrey Albershtein
Summary: The working principle of the bootloader, in particular Optiboot
Image: images/zephyr-logo.jpg
Lang: en

Optiboot is a nice alternative for default Arduino bootloader. It has a few
benefits to use - a little bit of space saved, sketches could be bigger, faster
firmware uploading, many supported platforms. I thought it would be interesting
to tear down its code and how it works as optiboot is quite small but is
excellent example of principles of bootloader.

I'm not a developer of optiboot so I can miss something. Take this article and
everything on the internet with grain of salt.

[TOC]

# Intro

- how bootloader works
- DUT and userspace tool

# Github project review

Most intresting directories and files

# Overall architecture of Optiboot

- protocol
- state machine
- data flow

# Intresting features

???

# outro
