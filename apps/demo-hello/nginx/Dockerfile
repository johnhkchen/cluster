FROM nginx:alpine

# Copy configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Create directories and set permissions
RUN mkdir -p /var/cache/nginx /var/log/nginx /run/nginx && \
    chown -R nginx:nginx /var/cache/nginx /var/log/nginx /run/nginx /etc/nginx && \
    chmod -R 755 /var/cache/nginx /var/log/nginx /run/nginx

EXPOSE 80

USER nginx

CMD ["nginx", "-g", "daemon off;"]
