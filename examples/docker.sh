#!/bin/bash

LOCAL_VOLUME="/main/storage/sicar/2025"

echo "Download data into: ${LOCAL_VOLUME}"
echo

docker run -i -v ${LOCAL_VOLUME}:/sicar urbanogilson/sicar:latest -<<EOF
from SICAR import Sicar, State, Polygon
from SICAR.drivers import Tesseract
from datetime import date
import os

car = Sicar(driver=Tesseract)
state_dates = car.get_release_dates()
start_date = (date.today()).strftime("%Y-%m-%d")

log_file='/sicar/download_information.txt'
with open(log_file, 'w') as logf:
    print(f'Starting download in {start_date}', file=logf)

for uf in State:

    for theme in Polygon:
        if theme in [Polygon.AREA_PROPERTY, Polygon.APPS, Polygon.LEGAL_RESERVE] and not os.path.isfile(f"/sicar/{uf.value}/{uf.value}_{theme}.zip"):
            with open(log_file, 'a') as logf:
                print("#######################################", file=logf)
                print(f"Download {theme} of {uf.value}", file=logf)
                print("#######################################", file=logf)
            try:
                car.download_state(state=f'{uf.value}', polygon=theme, folder=f'{uf.value}')
            except Exception as exc:
                with open(log_file, 'a') as logf:
                    print('Download error', file=logf)
                    print(f'{exc}', file=logf)
                    print("#######################################", file=logf)

        elif os.path.isfile(f"/sicar/{uf.value}/{uf.value}_{theme}.zip"):
            with open(log_file, 'a') as logf:
                print("#######################################", file=logf)
                print(f"About {theme} of {uf.value}", file=logf)
                print("skipping the download, the file is in the local directory.", file=logf)
                print("#######################################", file=logf)

    down_date = (date.today()).strftime("%Y-%m-%d")
    with open(f'/sicar/{uf.value}/metadata.txt', 'a') as mf:
        print(f'download date:{down_date}', file=mf)
        print(f'sicar release date:{state_dates[uf.value]}', file=mf)
        print("#######################################", file=mf)
EOF