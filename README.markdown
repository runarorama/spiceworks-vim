Spiceworks-Vim
--------------------

Develop Spiceworks Plugins with Vim.

To learn more about Spiceworks and Spiceworks Plugins:

* [Spiceworks Home](http://spiceworks.com)
* Spiceworks Plugins
  * [Help Page](http://community.spiceworks.com/help/Plugins)
  * [API](http://community.spiceworks.com/help/Spiceworks_Plugin_API)
  * [Tutorials](http://community.spiceworks.com/help/Plugin_Tutorials)
  * [Plugins available for Install](http://community.spiceworks.com/plugin)

Installation
============

To install:

Put the file swjs.vim in your ftdetect directory. (usually ~/.vim/ftdetect). Vim will now recognize files with the extension .swjs as Javascript.
Edit swjs.vim and change the "environments" hash to match your Spiceworks setup.

Source can be viewed or forked via GitHub: [http://github.com/shad/spiceworks-vim/tree/master](http://github.com/runarorama/spiceworks-vim/tree/master)


Usage
==========================

Create a new plugin in Spiceworks, view source on the plugin and grab the GUID by inspecting the &lt;tr&gt; element of `settings/plugins`.  Insert the `@guid` attribute into the `SPICEWORKS-PLUGIN` comment block like this:


    // ==SPICEWORKS-PLUGIN==
    // @name          My Plugin
    // @description   My Plugin Description
    // @version       0.1
    // @guid          p-597aa800-9708-012b-81c0-0016353cc494-1233697019
    // @env           Production
    // ==/SPICEWORKS-PLUGIN==

Change the `@env` attribute to match the `title` of the environment you set up in swjs.vim.

Create a file in your project directory for your new plugin.  Name it 'whatever-your-plugin-name-is.swjs'.  Make sure that Vim recognizes it as a spiceworks plugin file.  When you save this plugin, the plugin will also be published out to the server specified in the environment selected by `@env`.


Authors
=======
* Shad Reynolds [twitter/shadr](http://twitter.com/shadr), [Shad (Spiceworks)](http://community.spiceworks.com/profile/show/Shad%20(Spiceworks))
* Justin Perkins
* Runar Bjarnason
