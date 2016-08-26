## Notes for using rclone instead of encfs + acd_cli
### Sources
Most of this is sourced from the very complete rclone documentation.

### Why?
Simply put, with encryption built into rclone instead of layered between encfs and acd_cli some of the time consuming interactions like listing an encrypted ACD directory with many files should be eliminated.

### Installing rclone
On centos 7... as root:

    yum install go git -y
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
    [acd]
    client_id = 
    client_secret = 
    token = {"access_token":"xxxxxxxxxxxxxxxxxxxxxxx","token_type":"bearer","refresh_token":"xxxxxxxxxxxxxxxxxx","expiry":"2015-09-06T16:07:39.658438471+01:00"}
    --------------------
    y) Yes this is OK
    e) Edit this remote
    d) Delete this remote
    y/e/d> y

Hit my first hitch on the above. If you're on a machine with a desktop, the above works fine. If you're on a headless machine you'll need to follow the prompts to get an auth from a linux desktop. Don't worry, it's all in the workflow.

Make a directory for the encrypted files:

    rclone mkdir acd:rclone1

The crypt remote encrypts and decrypts another remote.

To use it first set up the underlying remote following the config instructions for that remote. You can also use a local pathname instead of a remote which will encrypt and decrypt from that directory which might be useful for encrypting onto a USB stick for example.

First check your chosen remote is working - we'll call it remote:path in these docs. Note that anything inside remote:path will be encrypted and anything outside won't. This means that if you are using a bucket based remote (eg S3, B2, swift) then you should probably put the bucket in the remote s3:bucket. If you just use s3: then rclone will make encrypted bucket names too (if using file name encryption) which may or may not be what you want.

Now configure crypt using rclone config. We will call this one secret to differentiate it from the remote.

    No remotes found - make a new one
    n) New remote
    s) Set configuration password
    q) Quit config
    n/s/q> n   
    name> acd-rclone1
    Type of storage to configure.
    Choose a number from below, or type in your own value
     1 / Amazon Drive
       \ "amazon cloud drive"
     2 / Amazon S3 (also Dreamhost, Ceph, Minio)
       \ "s3"
     3 / Backblaze B2
       \ "b2"
     4 / Dropbox
       \ "dropbox"
     5 / Encrypt/Decrypt a remote
       \ "crypt"
     6 / Google Cloud Storage (this is not Google Drive)
       \ "google cloud storage"
     7 / Google Drive
       \ "drive"
     8 / Hubic
       \ "hubic"
     9 / Local Disk
       \ "local"
    10 / Microsoft OneDrive
       \ "onedrive"
    11 / Openstack Swift (Rackspace Cloud Files, Memset Memstore, OVH)
       \ "swift"
    12 / Yandex Disk
       \ "yandex"
    Storage> 5
    Remote to encrypt/decrypt.
    remote> acd:rclone1
    How to encrypt the filenames.
    Choose a number from below, or type in your own value
     1 / Don't encrypt the file names.  Adds a ".bin" extension only.
       \ "off"
     2 / Encrypt the filenames see the docs for the details.
       \ "standard"
    filename_encryption> 2
    Password or pass phrase for encryption.
    y) Yes type in my own password
    g) Generate random password
    y/g> y
    Enter the password:
    password:
    Confirm the password:
    password:
    Password or pass phrase for salt. Optional but recommended.
    Should be different to the previous password.
    y) Yes type in my own password
    g) Generate random password
    n) No leave this optional password blank
    y/g/n> g
    Password strength in bits.
    64 is just about memorable
    128 is secure
    1024 is the maximum
    Bits> 128
    Your password is: JAsJvRcgR-_veXNfy_sGmQ
    Use this password?
    y) Yes
    n) No
    y/n> y
    Remote config
    --------------------
    [acd-rclone1]
    remote = acd:rclone1
    filename_encryption = standard
    password = CfDxopZIXFG0Oo-ac7dPLWWOHkNJbw
    password2 = HYUpfuzHJL8qnX9fOaIYijq0xnVLwyVzp3y4SF3TwYqAU6HLysk
    --------------------
    y) Yes this is OK
    e) Edit this remote
    d) Delete this remote
    y/e/d> y
    
Retain your passwords!



