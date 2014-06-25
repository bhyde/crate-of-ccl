#!/bin/bash
set -o nounset -o errexit -o verbose
LOG(){ 
    echo "LOG: $*" 
}
LOG start build-setup for the openmcl container
trap 'LOG exiting build-setup for the openmcl container' EXIT

LOG Install OpenMCL
mkdir -p /usr/local/src
cd /usr/local/src
apt-get install --yes curl
curl ftp://ftp.clozure.com/pub/release/1.9/ccl-1.9-linuxx86.tar.gz | tar zx
chown -R root:root ccl
ln -s "$( pwd )/ccl/scripts/ccl64" /usr/local/bin/ccl


LOG Setup quicklisp in /
cat <<EOF > /tmp/setup-quicklisp
    $( curl http://beta.quicklisp.org/quicklisp.lisp )
    (quicklisp-quickstart:install)
    (let ((ql-util::*do-not-prompt* t))
      (ql:add-to-init-file "/.ccl-init.lisp"))
    (ql:quickload "quicklisp-slime-helper")
    (ccl:quit 0)
EOF

ccl < /tmp/setup-quicklisp

LOG Assure that when ccl starts it listens for swank connections.
(cat  /.ccl-init.lisp; cat <<EOF)  > /foo.ccl-init.lisp
(ql:quickload "swank")
(setf swank::*LOOPBACK-INTERFACE* "0.0.0.0")
(swank:create-server :port 4005 :dont-close t)
EOF
mv /foo.ccl-init.lisp /.ccl-init.lisp

# rm /tmp/setup-quicklisp
date > /root/docker_build_date
exit 0
