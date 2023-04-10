apt-get update
apt-get install -y nginx

snap install dotnet-sdk --classic --channel=6.0
snap alias dotnet-sdk.dotnet dotnet
snap install dotnet-runtime-60 --classic
snap alias dotnet-runtime-60.dotnet dotnet
export DOTNET_ROOT=/snap/dotnet-sdk/current

mkdir -p /var/www/reactivities.com/html/client
mkdir -p /var/www/reactivities.com/html/api
echo "<h1>Client></h1>" > /var/www/reactivities.com/html/client/test.html
echo "<h1>API</h1>" > /var/www/reactivities.com/html/api/test.html

cat << EOF > /etc/nginx/sites-available/default
server {
    listen        80 default_server;
    server_name reactivities.com www.reactivities.com;
    root /var/www/reactivities.com/html;

    location / {
        root /var/www/reactivities.com/html/client;
    }

    location /api {
        proxy_pass         http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }

    error_page 404 /404.html;
    error_page 500 501 502 503 504 50x.html;
}
EOF

cat << EOF > /etc/systemd/system/kestrel-reactivities.service
[Unit]
Description=Reactivities React and DotNet Application and API

[Service]
WorkingDirectory=/var/www/reactivities.com/html/api
ExecStart=/snap/bin/dotnet /var/www/reactivities.com/html/api/API.dll
Restart=always
# Restart service after 10 seconds if the dotnet service crashes:
RestartSec=10
KillSignal=SIGINT
SyslogIdentifier=reactivities
User=www-data
Environment=ASPNETCORE_ENVIRONMENT=Production
Environment=DOTNET_PRINT_TELEMETRY_MESSAGE=false
Environment=Cloudinary__ApiKey=NONE
Environment=Cloudinary__ApiSecret=NONE
Environment=Cloudinary__CloudName=NONE
Environment=DATABASE_URL=NONE

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable kestrel-reactivities.service
sudo systemctl start kestrel-reactivities.service
sudo systemctl status kestrel-reactivities.service
