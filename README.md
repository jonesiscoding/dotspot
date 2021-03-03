# dotspot

Dotfiles and bootstrap for various systems, including macOS and ChromeOS.

## Prerequsites

The `bootstrap.sh` script in each of the platform specific folders handles almost everything in terms of dependencies,
however you may want to configure a few environment variables prior to running the bootstrap.

* **DEV_DIR** The directory where your projects go, used in a few convenience aliases.
* **LOCAL_BIN** The directory where your binary tools should go.  Defaults to `/usr/local/bin`.
* **LOCAL_SBIN** The directory where your script tools should go.  Defaults to `/usr/local/sbin`.

This may be done by placing a `.exports` file in your home folder with the following lines:

    export DEV_DIR="$HOME/Developer"
    export LOCAL_BIN="/usr/local/bin"
    export LOCAL_SBIN="/usr/local/sbin"

**IMPORTANT**: If you do not have write access to `/usr/local`, then the configuration of the `DEV_DIR` environment variable is required.  The `LOCAL_BIN` and `LOCAL_SBIN` variables will be derived from `DEV_DIR` if they are left undefined. If you do define `LOCAL_BIN` or `LOCAL_SBIN`, be sure that it is a directory to which you have write access.

## Working with YOUR dotfiles

If you have your own dotfiles that you'd like to still use, while benefiting from the conveniences in my dotfiles, that is pretty simple to do.

You can use the following files:

|File  | Purpose |  
|--|--|  
| .paths | Customizations to the PATH environment variable |
| .exports | Other environment variables to export when starting your shell |
| .bash_profile.local | Overrides or additional customizations |  
| .functions.local | Overrides or additional function definitions. |  
| .alias.local | Overrides or additional alias definitions. |

As part of the installation, any existing `.functions`, `.bash_profile`, or `.alias` files found in your home directory will be renamed with the `.local` extension so that they can be properly sourced.

## Installation

The bootstrap script is interactive, and will ask a series of yes/no questions regarding which tools you would like installed on the system.

For many of the more complicated installations, you'll see the process directly in the shell. To keep maintenance to a minimum, the bootstrap scripts do not watch for or handle errors in the invidual installations.

It is up to you to watch for errors and decide whether to break from the process or continue.

After configuring any needed environment variables, you can start the installation with the following:

### On MacOS

The following can be installed, based on your responses:

* Google Chrome
* Firefox
* Composer
* Box
* Pleasing
* DK
* PhpStorm
* Visual Studio Code
* Homebrew
* YQ
* JQ
* duti

### On ChromeOS

The following can be installed, based on your responses.

## Credits

Many of the concepts in these dotfiles came from others on the web, as is the nature of things.

* Mathias Bynens (https://mths.be/dotfiles)
