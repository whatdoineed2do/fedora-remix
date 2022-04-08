# desktop.ks
#
# Common customizations for a desktop workstation.

%packages

# Unwanted stuff
-abrt*
-fedora-release-notes
-xreader
-rsyslog
-sendmail

# Multimedia
libva
libva-utils
intel-media-driver

# Fonts
google-noto-sans-fonts
google-noto-sans-mono-fonts
google-noto-serif-fonts
liberation-s*-fonts

# Tools
@networkmanager-submodules
vim-enhanced
unar
exfat-utils
ntpsec
inxi
jq

%end


%post

echo ""
echo "POST desktop-base ************************************"
echo ""

# Antialiasing by default.
# Set Noto fonts as preferred family.
cat > /etc/fonts/local.conf << EOF_FONTS
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>

<!-- Settins for better font rendering -->
<match target="font">
	<edit mode="assign" name="rgba"><const>rgb</const></edit>
	<edit mode="assign" name="hinting"><bool>true</bool></edit>
	<edit mode="assign" name="hintstyle"><const>hintfull</const></edit>
	<edit mode="assign" name="antialias"><bool>true</bool></edit>
	<edit mode="assign" name="lcdfilter"><const>lcddefault</const></edit>
</match>

<!-- Local default fonts -->
<!-- Serif faces -->
	<alias>
		<family>serif</family>
		<prefer>
			<family>Noto Serif</family>
			<family>DejaVu Serif</family>
			<family>Liberation Serif</family>
            <family>Times New Roman</family>
			<family>Nimbus Roman No9 L</family>
			<family>Times</family>
		</prefer>
	</alias>
<!-- Sans-serif faces -->
	<alias>
		<family>sans-serif</family>
		<prefer>
			<family>Noto Sans</family>
			<family>DejaVu Sans</family>
			<family>Liberation Sans</family>
            <family>Arial</family>
			<family>Nimbus Sans L</family>
			<family>Helvetica</family>
		</prefer>
	</alias>
<!-- Monospace faces -->
	<alias>
		<family>monospace</family>
		<prefer>
			<family>Noto Sans Mono Condensed</family>
			<family>DejaVu Sans Mono</family>
			<family>Liberation Mono</family>
            <family>Courier New</family>
			<family>Andale Mono</family>
			<family>Nimbus Mono L</family>
		</prefer>
	</alias>
</fontconfig>
EOF_FONTS

# Set a colored prompt
cat > /etc/profile.d/color-prompt.sh << EOF_PROMPT
## Colored prompt
if [ -n "\$PS1" ]; then
	if [[ "\$TERM" == *256color ]]; then
		if [ \${UID} -eq 0 ]; then
			PS1='\[\e[91m\]\u@\h \[\e[93m\]\W\[\e[0m\]\\$ '
		else
			PS1='\[\e[92m\]\u@\h \[\e[93m\]\W\[\e[0m\]\\$ '
		fi
	else
		if [ \${UID} -eq 0 ]; then
			PS1='\[\e[31m\]\u@\h \[\e[33m\]\W\[\e[0m\]\\$ '
		else
			PS1='\[\e[32m\]\u@\h \[\e[33m\]\W\[\e[0m\]\\$ '
		fi
	fi
fi
EOF_PROMPT

cat > /usr/sbin/backup_for_upgrade.sh << 'BACKUPSCRIPT_EOF'
#!/bin/bash

if [ "$(id -u)" != "0" ]; then
    echo "This script must be run as root" 1>&2
    exit 1
fi

USER="$(logname)"
MOUNTPOINT_DEST="/home"
DEST="/home/backup-$USER@$HOSTNAME-$(date '+%Y%m%d_%H%M%S')"
PATHS_TO_BACKUP=(
    usr/local
    etc
    root
)

mkdir -p "$DEST"
cd $DEST
umask 0066

echo "Saving lists of installed packages"
id > id.txt
dnf list installed > dnf_list_installed.txt
rpm -qa > rpm-qa.txt
flatpak list > flatpak_list.txt
snap list > snap_list.txt

# backup folders
for path in "${PATHS_TO_BACKUP[@]}"
do
    echo "Backing up $path"
    tar cjpf "backup-$(echo $path | tr / _).tar.bz2" -C / "$path"
done

echo "All done. Files are in $DEST"

BACKUPSCRIPT_EOF

chmod +x /usr/sbin/backup_for_upgrade.sh

semanage fcontext -a -t unconfined_exec_t '/usr/local/sbin/firstboot'

cat > /usr/local/sbin/firstboot << 'FIRSTBOOT_EOF'
#!/bin/bash

extcode=0

shopt -s nullglob
for src in /usr/local/sbin/firstboot_*.sh; do
    echo "firstboot: running $src"
    $src
    if [ $? -ne 0 ]; then
        mv $src $src.failed
        echo "Script failed! Saved as: $src.failed"
        extcode=1
    else
        echo "Script completed"
        rm $src
    fi
done

if [[ $exitcode == 0 ]]; then
    semanage fcontext -a -t unconfined_exec_t '/usr/local/sbin/firstboot'
    rm /usr/local/sbin/firstboot
fi

exit $extcode

FIRSTBOOT_EOF

chmod +x /usr/local/sbin/firstboot

cat > /usr/local/sbin/firstboot_anaconda.sh << 'ANACONDA_EOF'
#!/bin/bash
dnf remove -y anaconda
ANACONDA_EOF
chmod +x /usr/local/sbin/firstboot_anaconda.sh

cat > /usr/local/sbin/firstboot_noatime.sh << 'NOATIME_EOF'
#!/bin/bash
gawk -i inplace '/^[^#]/ {if (($3 == "ext4" || $3 == "btrfs") && !match($4, /noatime/)) { $4=$4",noatime" } } 1' /etc/fstab
NOATIME_EOF
chmod +x /usr/local/sbin/firstboot_noatime.sh

%end
