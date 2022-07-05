echo "Start restart.sh"
sudo systemctl restart isucondition.go.service
sudo nginx -t && sudo systemctl restart nginx.service
sudo systemctl restart mysql.service
echo "Finish restart.sh"
