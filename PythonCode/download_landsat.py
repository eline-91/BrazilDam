import requests
import landsat.settings
from landsat.utils import check_create_folder, url_builder
from landsat.mixins import VerbosityMixin
from os.path import join, exists, getsize
from homura import download as fetch


class Downloader(VerbosityMixin):
    """ The downloader class """
    download_dir = '/home/user/landsat'
    print download_dir
    
    def download(self, scenes):
        """Download Function from Google Storage 
        Args:
          SceneID {data_tye: List}
        Retruns:
          Tarred landsat data files
        """
        self.google = landsat.settings.GOOGLE_STORAGE
         
         # Check for the validity of SceneID
        for scene in scenes:
            # An empty list in accordance to landsat unique ID
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
            # Create a folder to download tarred landsat Scenes
            path = check_create_folder(self.download_dir)
            filename = scene + '.tar.bz'        
            print path
            print scene_anatomy
            # Builds the URL to a google storage file
            url = url_builder([self.google,scene_anatomy['sat'], scene_anatomy['path'], scene_anatomy['row'],filename])
            print url
            # Downloads and save at the location defined under path    
            fetch(url,path)
     
            return path
            
if __name__ == '__main__':

    d = Downloader()
    print "--Download Done!---"
