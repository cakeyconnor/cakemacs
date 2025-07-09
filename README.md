[![CakeMacs Logo](https://github.com/connorakey/cakemacs/blob/main/resources/images/cakemacs.png?raw=true)](https://github.com/connorakey/cakemacs)

# CakeMacs
Welcome to CakeMacs, an Emacs distribution and a hobby project maintained by Connor Akey.
The goal is to provide a future-proof, minimal-setup Emacs distro that’s easy to customize and perfect for myself and others, combining new technologies and clean standards.

## Who Is This For?
CakeMacs targets intermediate to advanced users who want full control over their Emacs environment without the hassle of building one from scratch.
It strikes a balance between vanilla Emacs and large preconfigured distributions like Doom Emacs or Spacemacs.

## Why Choose CakeMacs?
Simple, single-file configuration: Everything is stored neatly and alphabetically in one file.

Flexible organization: You decide how to structure your config and the level of effort you put into it.

Powerful defaults: Comes preconfigured with solid setups for coding, text editing, and system navigation.

Slices: Define your own modular config files ("slices") that can be loaded as needed. For example, if your essentials list feels cluttered, just move it to a slice and require it when you want.

## What Are Slices?
A slice is a user-published CakeMacs configuration — usually a .org file tailored to your needs. Since CakeMacs is highly configurable, slices vary widely. There’s no shame in using someone else’s slice!
If CakeMacs grows, I plan to maintain a centralized repository of community slices.

# Prerequisites
Git

Emacs

ripgrep

GNU Core Utils

(Optional but recommended) fd (for improved file indexing performance)

# Installation

``git clone --depth 1 https://github.com/connorakey/cakemacs ~/.cakemacs.d
~/.cakemacs.d/bin/cakemacs install``

# Useful CakeMacs Commands
It’s a good idea to add ~/.cakemacs.d/bin to your $PATH.
Some handy commands:

``cakemacs sync`` — Synchronizes your config with the latest updates from GitHub (git pull).

``cakemacs install`` — Installs CakeMacs, so launching Emacs uses your CakeMacs config.

``cakemacs uninstall`` — Uninstalls CakeMacs without deleting config files, allowing safe recovery if needed.

``cakemacs purge`` — Completely removes all CakeMacs files unsafely (no recovery).

``cakemacs help`` — Displays available CakeMacs commands and usage info.

# Contributing

CakeMacs welcomes contributions! The easiest way to contribute is by creating your own slice (a personal CakeMacs configuration) and submitting it via a pull request for inclusion in the documentation.

Since CakeMacs is fully customizable and ships with all necessary packages, pull requests are reviewed and often accepted quickly.

Please feel free to report bugs or suggest improvements — I’m happy to help and fix issues!

# Featured Slices
None at the moment, feel free to submit your own!

---
Disclaimer! This README file was written by me, and touched up by AI (specifically ChatGPT 4o-mini), this is for **full** transparency.
