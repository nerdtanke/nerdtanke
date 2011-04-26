@echo off
echo Sass...
cd public\stylesheets
cmd /c sass screen.sass screen.css
cd ..\..
echo Haml...
cmd /c haml public\index.html.haml public\index.html
cmd /c haml public\imprint.html.haml public\imprint.html
echo done.
