FROM ubuntu:noble

# Install nginx
RUN apt update && apt install nginx -y

# Create healthcheck endpoint
COPY ./nginx.conf /etc/nginx/sites-available/default

# Copy static files to the Nginx html directory
COPY ./static /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
