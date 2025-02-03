# Install the chart
helm install my-app helm-shared/web-application --upgrade

# Add the local domain to /etc/hosts
echo "127.0.0.1 web-application.local" | sudo tee -a /etc/hosts

# Access your application at
http://web-application.local