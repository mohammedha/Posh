# 1. Create project directories
mkdir -p searxng-podman/searxng && cd searxng-podman

# 2. Generate a random secret key (save this for the next step)
SECRET_KEY=$(openssl rand -hex 32)
echo "Your secret key is: $SECRET_KEY"

# 3. Create the settings.yml file
cat <<EOF > searxng/settings.yml
use_default_settings: true
server:
  secret_key: "$SECRET_KEY"
  limiter: false  # Disable rate limiting for local use/AI testing
search:
  formats:
    - html
    - json        # Enable JSON for AI integration
redis:
  url: redis://redis:6379/0
EOF

# 4. Create the docker-compose.yaml file
cat <<EOF > docker-compose.yaml
services:
  redis:
    container_name: redis
    image: docker.io/library/redis:alpine
    networks:
      - searxng
    restart: always

  searxng:
    container_name: searxng
    image: docker.io/searxng/searxng:latest
    networks:
      - searxng
    ports:
      - "8080:8080"
    volumes:
      - ./searxng:/etc/searxng:Z
    environment:
      - SEARXNG_BASE_URL=http://localhost:8080/
    depends_on:
      - redis
    restart: always

networks:
  searxng:
    driver: bridge
EOF

# 5. Set permissions for Podman rootless volumes
chmod -R 777 searxng

# 6. Start the stack
podman-compose up -d

# 7. Check if it's running
podman ps
