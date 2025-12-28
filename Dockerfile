FROM node:18-alpine
RUN npm ci && npm run build
