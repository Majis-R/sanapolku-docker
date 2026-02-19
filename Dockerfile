# Multi-stage build: build React app, serve with nginx

# --- Build stage ---
FROM node:18-alpine AS builder
WORKDIR /app

# Install dependencies (use package-lock if present)
COPY package.json package-lock.json* ./
RUN npm ci --silent

# Copy source and build
COPY . ./
RUN npm run build

# --- Production stage ---
FROM nginx:stable-alpine

# Remove default nginx static assets
RUN rm -rf /usr/share/nginx/html/*

# Copy built app to nginx html folder under the homepage path
COPY --from=builder /app/build /usr/share/nginx/html/sanapolku

# Custom nginx config to support SPA routing and proper caching
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 3000

CMD ["nginx", "-g", "daemon off;"]
