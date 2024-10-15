FROM elixir:1.17.3-alpine

# Installer les dépendances système
RUN apk update && \
    apk add --no-cache build-base git postgresql-client postgresql-dev nodejs npm

WORKDIR /app

# Copier le répertoire des assets
COPY assets/ ./assets/

# Copier les fichiers mix.exs et mix.lock
COPY mix.exs mix.lock ./

# Installer Hex et Rebar
RUN mix local.hex --force && \
    mix local.rebar --force

# Installer les dépendances Elixir
RUN mix deps.get

# Copier le reste de l'application
COPY . /app

# Installer les dépendances JS
RUN npm install --prefix ./assets
# ou npm ci --prefix ./assets si tu as un package-lock.json

# Compiler les assets
RUN npm run deploy --prefix ./assets

# Vérifier les versions de mix, Node et npm
RUN mix --version && node --version && npm --version

EXPOSE 4000

ENTRYPOINT ["entrypoint.sh"]
