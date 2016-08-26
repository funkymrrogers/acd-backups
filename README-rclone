## Notes for using rclone instead of encfs + acd_cli
### Why?
Simply put, with encryption built into rclone instead of layered between encfs and acd_cli some of the time consuming interactions like listing an encrypted ACD directory with many files should be eliminated.

### Installing rclone
On centos 7... as root:

    yum install go -y
    mkdir ~/go
    echo "export GOPATH=$HOME/go" > /etc/profile.d/go.sh
    echo "export PATH=$PATH:$HOME/go/bin" >> /etc/profile.d/go.sh
    /bin/bash
    go get github.com/ncw/rclone
    rclone config
    
Drops you into the config dialog. You're going to set up a "remote" which is simply an authenticated session with a supported rclone cloud provider. The local name for the "remote" can be anything, but we're just going to call it "acd".

    n) New remote
    d) Delete remote
    q) Quit config
    e/n/d/q> n
    name> acd
    Type of storage to configure.
    Choose a number from below, or type in your own value
     1 / Amazon Drive
       \ "amazon cloud drive"
     2 / Amazon S3 (also Dreamhost, Ceph)
       \ "s3"
     3 / Backblaze B2
       \ "b2"
     4 / Dropbox
       \ "dropbox"
     5 / Google Cloud Storage (this is not Google Drive)
       \ "google cloud storage"
     6 / Google Drive
       \ "drive"
     7 / Hubic
       \ "hubic"
     8 / Local Disk
       \ "local"
     9 / Microsoft OneDrive
       \ "onedrive"
    10 / Openstack Swift (Rackspace Cloud Files, Memset Memstore, OVH)
       \ "swift"
    11 / Yandex Disk
       \ "yandex"
    Storage> 1
    Amazon Application Client Id - leave blank normally.
    client_id> 
    Amazon Application Client Secret - leave blank normally.
    client_secret> 
    Remote config
    If your browser doesn't open automatically go to the following link: http://127.0.0.1:53682/auth
    Log in and authorize rclone for access
    Waiting for code...
    Got code
    --------------------
    [remote]
    client_id = 
    client_secret = 
    token = {"access_token":"xxxxxxxxxxxxxxxxxxxxxxx","token_type":"bearer","refresh_token":"xxxxxxxxxxxxxxxxxx","expiry":"2015-09-06T16:07:39.658438471+01:00"}
    --------------------
    y) Yes this is OK
    e) Edit this remote
    d) Delete this remote
    y/e/d> y
