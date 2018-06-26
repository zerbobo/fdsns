# -*- coding: utf-8 -*-
from flask import Flask
from flask import request
from flask import json
from flask import send_file
from flask import render_template
from flask_cors import CORS
import threading
import logging
import logging.config
import StringIO
import os
import sys
import traceback
import toml


log_config_file = "./fdsns_log.conf"
if os.path.exists(log_config_file):
    logging.config.fileConfig(log_config_file)
else:
    logging.basicConfig(stream=sys.stdout,
                        format='[%(asctime)s - %(name)s - %(levelname)s]: %(message)s',
                        level=logging.INFO)


logger = logging.getLogger(__name__)
logger.setLevel(logging.INFO)

app = Flask(__name__)
CORS(app)
app_thr = None

toml_config_file = '/opt/fdsns/fdsns.toml'
toml_config_demo = '''
title = "Demo"
port = 5699
[[table]]
    name = "Demo table1"
    [[table.list]]
        name = "Google"
        url = "http://www.google.com"
    [[table.list]]
        name = "Baidu"
        url = "http://www.baidu.com"
[[table]]
    name = "Demo table2"
    [[table.list]]
        name = "GitHub"
        url = "http://www.github.com"
'''
g_toml_config = None


def run_app(main_thr=False):
    def _body():
        global g_toml_config
        try:
            g_toml_config = toml.load(toml_config_file)
        except:
            err = traceback.format_exc()
            logger.error("--- web_site --- toml file load traceback: %s" % err)
            logger.warning("--- web_site --- parse toml file error, just demo it")
            g_toml_config = toml.loads(toml_config_demo)

        app.run(host="0.0.0.0", port=g_toml_config.get("port", 5699), threaded=True)

    logger.info("--- web_site --- start web server")
    if main_thr:
        _body()
    else:
        global app_thr
        app_thr = threading.Thread(target=_body)
        app_thr.daemon = True
        app_thr.start()


@app.route('/hello/')
@app.route('/hello/<name>')
def hello_world(name=None):
    return 'Hello World! Welcome ' + str(name)


@app.route('/')
def main_web_serv():
    global g_toml_config
    if g_toml_config:
        return render_template('main_web_serv.html',
                               title=g_toml_config.get("title", "Empty title"),
                               table=g_toml_config.get("table", {}))
    else:
        return 400


if __name__ == "__main__":
    run_app(True)
