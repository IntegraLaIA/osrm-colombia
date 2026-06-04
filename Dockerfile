# OSRM self-host para Colombia (map matching del rastro GPS del TMS Plexa).
# Descarga el extracto OSM y lo preprocesa (MLD) en build; runtime sólo sirve
# osrm-routed. No usamos apt sobre la imagen OSRM (base vieja, repos EOL): la
# descarga del PBF se hace con una imagen curl aparte.

# 1) Descarga del extracto OSM (imagen liviana con curl).
FROM curlimages/curl:8.10.1 AS download
ARG PBF_URL=https://download.geofabrik.de/south-america/colombia-latest.osm.pbf
WORKDIR /data
RUN curl -fsSL -o colombia.osm.pbf "$PBF_URL"

# 2) Preprocesamiento OSRM (MLD).
FROM osrm/osrm-backend:v5.25.0 AS build
WORKDIR /data
COPY --from=download /data/colombia.osm.pbf .
RUN osrm-extract -p /opt/car.lua colombia.osm.pbf \
 && osrm-partition colombia.osrm \
 && osrm-customize colombia.osrm \
 && rm -f colombia.osm.pbf

# 3) Runtime.
FROM osrm/osrm-backend:v5.25.0
WORKDIR /data
COPY --from=build /data/ /data/
EXPOSE 5000
CMD ["osrm-routed","--algorithm","mld","--max-matching-size","1000","/data/colombia.osrm"]
