Localisation Tools
==================

Here is a set of tools I've created to assist with generating and checking translations for [Alfresco](http://www.alfresco.com). These are slightly modified versions of ones we use internally.

They're designed to run in a Unix shell, so will run fine in Mac OS X's Terminal or under Cygwin. They should be run from the directory containing the Alfresco source code with the language bundle installed.

* **alfresco-translation-check.sh**
    
   **USAGE: alfresco-translation-check.sh path/to/write/reports.txt [additional_locales]**
   
    This tool generates a series of reports comparing the translated properties files with the English properties files to show you:
 
    * Strings missing form the translation
    * Strings in the translated language that match the English
    * Files containing missing strings.
    * Strings definitions that are duplicated.
    * Strings wich include variables and single quotes (quotes should be duplicated when the UI string contains a variable).
    * Strings which contain unicode that is incorrectly escaped.
