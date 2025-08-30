# Unifi
Share my script for Ubiquiti Unifi

✅ How 

### 1 - connect via SSH to your Unifi gateway  
ssh ip_gateway -l root  

### 2 - go to a persistant folder /mnt/data and create a log folder  
cd /mnt/date  
mkdir log  

### 3 - create variables file, copy the example and change variables in your context. (vi, i to insert text and paste the code)
vi z_variables.conf  
i  
paste the code  

### 4 - create scripts (eg DDNS_CloudFlare.sh) and repeat for all scripts. (vi, i to insert text and paste the code)
vi DDNS_CloudFlare.sh  
i  
paste the code  

### 5 - create the script to rotate and purge the logs
vi log_rotate.sh  
i  
paste the code  

### 6 - Change crontab. In this example, every 5 minutes for 0crontab.sh and each 1 day of the month at 00:00 for log_rotate.sh.
crontab -e  
i  
#at the end of the file paste this:  
*/5 * * * * /mnt/data/0crontab.sh 2>&1  
0 0 1 * * /mnt/data/log_rotate.sh 2>&1  
