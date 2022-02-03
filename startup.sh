#! /usr/bin/bash
#  Autorun stage on 8080 and production on 80
AppDir=$(dirname $0)
cd "${AppDir}"|| exit
source ./venv/bin/activate
export GPort=${PORT-8080}
export Gapp='fieldworker:create_app()'
w=4
app=$(which gunicorn)
$app --workers=${w} --bind '0.0.0.0':"${GPort}" ${Gapp} --timeout 200

