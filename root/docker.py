from resources.lib import epg, web

bundle_dir = os.path.join(os.path.abspath(getattr(sys, "_MEIPASS", os.path.abspath(os.path.dirname(__file__)))), "")
file_paths = {"included": bundle_dir, "storage": "/storage/"}

my_server = web.WebServer(epg.Grabber(file_paths), file_paths)
my_server.start()