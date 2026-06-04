# OSRM self-host para Colombia (map matching del rastro GPS del TMS Plexa).
# Descarga el extracto OSM de Colombia y lo preprocesa (MLD) en build time;
# en runtime sólo sirve osrm-routed. Pesado en build (RAM/CPU/disco ~1-2GB).
#
# Build arg PBF_URL permite cambiar el extracto (p.ej. una sub-región más liviana).

FROM osrm/osrm-backend:v5.25.0 AS build
ARG PBF_URL=https://download.geofabrik.de/south-america/colombia-latest.osm.pbf
WORKDIR /data
RUN apt-get update && apt-get install -y --no-install-recommends wget ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN wget -q -O colombia.osm.pbf "$PBF_URL" \
 && osrm-extract -p /opt/car.lua colombia.osm.pbf \
 && osrm-partition colombia.osrm \
 && osrm-customize colombia.osrm \
 && rm -f colombia.osm.pbf

FROM osrm/osrm-backend:v5.25.0
WORKDIR /data
COPY --from=build /data/ /data/
EXPOSE 5000
# --max-matching-size sube el límite de coords del endpoint /match (el demo
# público lo tenía muy bajo, "TooBig"). En self-host podemos permitir trazas largas.
CMD ["osrm-routed","--algorithm","mld","--max-matching-size","1000","/data/colombia.osrm"]
