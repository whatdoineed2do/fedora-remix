# development.ks
#
# Development support base.

%packages

@development-tools
# editors
vim-enhanced
vim-default-editor

# compiling
automake
pkgconfig
gcc
g++
gdb
valgrind
git
autoconf
gettext-devel
gperf
gawk
libtool
bison
flex
sqlite-devel
libconfuse-devel
libunistring-devel
mxml-devel
libevent-devel
avahi-devel
libgcrypt-devel
zlib-devel
alsa-lib-devel
ffmpeg-devel
libplist-devel
libsodium-devel
json-c-devel
libwebsockets-devel
libcurl-devel
protobuf-c-devel
sqlite
npm
nodejs

# tools
strace
telnet
nfs-utils
autofs
aircrack-ng

%end

%post

echo ""
echo "POST development-base ************************************"
echo ""

cat > /etc/sysctl.d/10-remix-inotify.conf << INOTIFY_EOF
# remix - increase max inotify watches
fs.inotify.max_user_watches=524288
INOTIFY_EOF

mkdir /net
mkdir -p /export/public
chmod 1775 /export/public

cat > /etc/exports << EOF
/export/public    *(ro,sync,root_squash)
EOF

cat >> /etc/vimrc << EOF
set ai sw=4
:nnoremap <CR> :nohlsearch<CR>/<BS>
EOF

cat >> /etc/inputrc << EOF
set show-all-if-ambiguous on
set editing-mode vi
EOF

cat >> /etc/profile.d/colorls.sh << EOF
alias ls='ls -F --color=auto' 2>/dev/null
EOF

%end
