FROM nginx:latest

COPY nginx.conf /etc/nginx/nginx.conf
COPY scripts/entrypoint2.sh /etc/nginx/entrypoint.sh

ENTRYPOINT ["/etc/nginx/entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
