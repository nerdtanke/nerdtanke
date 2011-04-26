@echo off
cmd /c pscp -r public\* deploy-nerdtanke@nerdtanke.de:/opt/www/nerdtanke/public
cmd /c pscp pscp.exe die-nerdtanke.pdn *.cmd deploy-nerdtanke@nerdtanke.de:/opt/www/nerdtanke/
