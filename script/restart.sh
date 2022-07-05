echo "Start restart.sh"
systemctl restart isu-go.service
systemctl restart nginx.service
systemctl restart mysql.service
echo "Finish restart.sh"
