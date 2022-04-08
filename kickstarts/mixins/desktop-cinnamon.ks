# desktop-gnome.ks
#
# Customization for GNOME desktop.

%include desktop-base.ks

%packages

# desktop
-thunderbird
-hexchat
-pidgin

# networking

# multimedia
mpv

# productivity
file-roller-nautilus

# tools
gparted
seahorse
seahorse-nautilus

%end

%post

echo ""
echo "POST desktop-cinnamon ************************************"
echo ""

cat > /etc/mpv/mpv.conf << EOF
hwdec=vaapi
EOF

%end
