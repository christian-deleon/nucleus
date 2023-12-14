# Packer

## Building Image

If running on a RHEL OS, make sure to allow port `8080` on the firewall for Kickstart file to be hosted.

```bash
sudo firewall-cmd --permanent --add-port=8080/tcp
sudo firewall-cmd --reload
```
