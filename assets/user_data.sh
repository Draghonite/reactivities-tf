apt-get update
apt-get install -y nginx

snap install dotnet-sdk --classic --channel=6.0
snap alias dotnet-sdk.dotnet dotnet
snap install dotnet-runtime-60 --classic
snap alias dotnet-runtime-60.dotnet dotnet
export DOTNET_ROOT=/snap/dotnet-sdk/current

mkdir -p /var/www/html/api
mkdir -p /var/www/html/app

cat << EOF > /etc/nginx/sites-available/default
server {
    listen        80;
    location / {
        proxy_pass         http://127.0.0.1:5000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade $http_upgrade;
        proxy_set_header   Connection keep-alive;
        proxy_set_header   Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header   X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
    }
}
EOF

service nginx start
nginx -s reload
