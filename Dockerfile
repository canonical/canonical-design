FROM ubuntu:noble

# Install nginx
RUN sudo apt update && sudo apt install nginx

# Create healthcheck endpoint
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

# Copy static files to the Nginx html directory
COPY ./static /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
