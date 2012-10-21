PinkCake
========

This is a build setup (and a few JS utils) to build static web pages using Stylus, Jade and Coffescript (also HTML, PHP and CSS).
Currently you need to work in the Build setup,
later PinkCake is planned to be *includable*.

Dependencies
============

You will need:

* *Something Posix*
* NPM
* Jade
* Coffescript
* Stylus
* GNUMake
* A shell
* Juicer


TODO
====

* Use external column Library
* Load Bootstrap CSS?
* TMP
    * Split tmp for each purpose (js/css/..?)
    * Use /tmp/..? for tmpfiles in non-debug mode
    * Delete tmpfiles in nondebug
* Export buildscript to its own repo and load conf from other file
* Add support for multiple js/css outputr
* Update nomenclature to be generic (not css, js, html)
* Use imports instadt of concat for css compilation
* Dep-install scripts and doc
* Use blocks to share one layout among all sites
