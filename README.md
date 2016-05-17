# media-file-asset-linux
Sample CONS3RT asset to copy files to a Linux machine.

Use this asset with no modifications to copy media files from your asset to /opt/install_media.  Otherwise, update the "installDir" variable in scripts/media-file-asset-linux.sh.  You will, however, want to update the asset.properties file with appropriate information before importing into CONS3RT.


### To Use this asset:

* git clone https://github.com/cons3rt/media-file-asset-linux.git
* Add your media files to the media directory
* Update the asset.properties file
* Update the doc/LICENSE.html with links to appropriate license info
* Update the doc/HELP.html as appropriate
* Create a zip file of this directory
* [Import this asset into CONS3RT](https://kb.cons3rt.com/kb/assets/importing-your-asset-zip-file)
