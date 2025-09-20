# Dockerizing Recetas-Del-Mundo (Frontend)

This repository includes a Dockerfile and docker-compose configuration to build and serve the React frontend using nginx.

Quick steps:

- Build and start with Docker Compose:

```powershell
docker-compose up --build -d
```

- Open http://localhost:3000 in your browser.

Notes:
- The `frontend/Dockerfile` builds the React app and serves it with `nginx` (listening on port 80 inside the container). The `docker-compose.yml` maps host port `3000` to container port `80`.
- The nginx config proxies `/api/` requests to the backend at `http://168.181.187.137:8081/` (change if your API is running elsewhere).
- If your project uses `yarn`, adapt the Dockerfile commands accordingly.
