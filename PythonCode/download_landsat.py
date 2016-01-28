from os.path import join, exists, getsize
from homura import download as fetch
import requests
from landsat.utils import check_create_folder, url_builder
from landsat.mixins import VerbosityMixin
import landsat.settings

class Downloader(VerbosityMixin):
    """ The downloader class """
    download_dir = '/home/user/landsat'
    print download_dir
    
    def download(self, scenes):
         self.google = landsat.settings.GOOGLE_STORAGE
         # Make sure download directory exist
         # check_create_folder(self.download_dir)
         for scene in scenes:
            scene_anatomy = {
                 'path': None,
                 'row': None,
                 'sat': None,
                 'scene': scene
                 }
            if isinstance(scene, str) and len(scene) == 21:
                     scene_anatomy['path'] = scene[3:6]
                     scene_anatomy['row'] = scene[6:9]
                     scene_anatomy['sat'] = 'L' + scene[2:3]
            else:
                raise IncorrectSceneId('Bad List')
        # Create a folder to download the specific bands into
            path = check_create_folder(self.download_dir)
            filename = scene + '.tar.bz'        
            print path
            print scene_anatomy
            url = url_builder([self.google,scene_anatomy['sat'], scene_anatomy['path'], scene_anatomy['row'],filename])
            print url
                 
            fetch(url,path)
#            self.output('stored at %s' path, normal=True, color='green', indent=1)             
            return path
            
if __name__ == '__main__':

    d = Downloader()
    print "-----"
