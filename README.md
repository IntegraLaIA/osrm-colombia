# osrm-colombia

OSRM self-host (map matching) para el TMS de Plexa. Sirve `osrm-routed` con el
mapa de Colombia (Geofabrik) preprocesado en MLD.

- Endpoint de matching: `GET /match/v1/driving/{lon,lat;...}?geometries=geojson&overview=full&tidy=true`
- Puerto: **5000**
- El front lo usa vía `VITE_OSRM_URL`.

## Deploy (Dokploy)
App "Dockerfile" desde este repo (rama `main`), puerto 5000, dominio propio.
Build pesado: descarga ~300MB y preprocesa (RAM/CPU). Para regiones más livianas,
cambiar el build-arg `PBF_URL`.

## Local
```bash
docker build -t osrm-co .
docker run -p 5000:5000 osrm-co
```
