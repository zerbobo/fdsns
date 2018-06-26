# Introduction

A fast deploying and simple navigation site.

It's useful when there are various websites to manage and navigate inside of a corparation. This gives you a chance to navigate to all.

All you need to do is just writing a toml config file.

"快速搭建公司/组织内网导航站点"

Based on [Flask](http://flask.pocoo.org/).

# Build, Deploy & Run

## Build

Run `tools/build.sh` to build a development mode setup of normal python project.

Then in project root directory:

```
source build/py_env/bin/activate
python -m fdsns.server.web_site.py
```

To run a default site, default port is 5699. Visit http://localhost:5699

## Deploy

Run `tools/pack_deb.sh` to pack all necessary files into a deb file. And then you can `dpkg -i xxx.deb` in target machine to install it.

Then run the deployed fdsns:

```
sudo systemctl enable fdsns.service
sudo systemctl start fdsns.service
```

# Configuration

Default configuration file is located at /opt/fdsns/fdsns.toml , and default content is:

```
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
```

The key words are `title`, `port`, `table`, `list`, `name` and `url`.

Format is toml, and format error will result in the site running with a default config.
