#!/bin/bash

# https://github.com/prmsrswt/arch-install.sh

function ascii {

echo “Installazione di Arch Linux”
loadkeys it
echo “[FATTO] Layout italiano impostato.

}

function br {
	# Just output a bunch of crap, but it looks cool so..
	for ((i=1; i<=`tput cols`; i++)); do echo -n -; done
}

function cont {
	read -r -p "[FATTO] Andare avanti? [S/n] " contin
	case $continue in
		[Nn][oO]|[nN] )
			exit
			;;
		*)
			;;
	esac
}

function settime {
	echo "Fixo l’orologio...."
	# This command fixes different time reporting when dual booting with windows.
	timedatectl set-local-rtc 1 –adjust-system-clock
	echo "[FATTO] Fixo l’orologio"
}

function partion {
	br
	read -r -p "Partizionare? [s/N] " resp
	case "$resp" in
		[sS][iI]|[sS])
			echo "..."
			read -r -p "Quale disco utilizzare [dev/sda]? " drive
			# Using gdisk for GPT, if you want to use MBR replace it with fdisk
			gdisk $drive
			;;
		*)
			;;
	esac
	cont
}

function mounting {
	br
	read -r -p "Qual’è la partizione root [dev/sda2]? " rootp
	mkfs.ext4 $rootp
	mount $rootp /mnt
	mkdir /mnt/boot
	read -r -p "Qual’è la partizione di avvio efi [dev/sda1]? " bootp
	read -r -p "Vuoi formattare la partizione di avvio? Fare no se si vuole dualbootare [s/N] " response
	case "$response" in
		[sS][iS]|[sS])
			mkfs.fat -F32 $bootp
			;;
		*)
			;;
	esac
	mount $bootp /mnt/boot
read -r -p "Usare la swap? [S/n] " responsep
	case "$responsep" in
		[sS][iS]|[sS])
			read -r -p "Qual’è la partizione swap? [/dev/sda4]" swapp
			swapon $swapp
			;;
		*)
			;;
	esac
	read -r -p "Si vuole usare una partizione home, Se no verrà usata quella root? [s/N] " responsehome
	case "$responsehome" in
		[sS][iI]|[sS])
			read -r -p "Qual’è la partizione home? [/dev/sda3]" homep
			read -r -p "Si vuole formattare la partizione home? [s/N] " rhome
			case "$rhome" in
				[sS][iI]|[sS])
					mkfs.ext4 $homep
					;;
				*)
					;;
			esac
			mount $homep /mnt/home
			;;
		*)
			;;
	esac
	cont
}

function base {
	br
            echo -e "Che d.e. vuoi? : \n"
	echo -e "1. GNOME \n2. KDE Plasma \n3. Xfce4 \n4. Btw i use shell"
	read -r -p "DE: " desktope
	echo "Installazione dei pacchetti..."
	sleep 1
	pacstrap /mnt \
				base \
				diffutils \
				e2fsprogs \
				inetutils \
				less \
				linux \
				linux-firmware \
				logrotate \
				man-db \
				man-pages \
				nano \
				texinfo \
				usbutils \
				which \
				base-devel \
				networkmanager \
				sudo \
				bash-completion \
				git \
				exfat-utils \
				ntfs-3g \
				grub \
				os-prober \
				efibootmgr \
				htop \
				firefox \
				pacman-contrib \
				ttf-hack
	echo “[FATTO] Installati”
	genfstab -U /mnt >> /mnt/etc/fstab
	echo “[FATTO] Fstab creata con successo”
      echo “Installazione di ”, $desktope
case "$desktope" in
		1)
			installgnome
			;;
		2)
			installkde
			;;
		3)
			installxfce4
			;;
		*)
			;;
	esac
	cont
}

function installgnome {
	pacstrap /mnt xorg gnome gnome-tweaks papirus-icon-theme
	arch-chroot /mnt bash -c "systemctl enable gdm && exit"
	# Editing gdm's config for disabling Wayland as it does not play nicely with Nvidia
	arch-chroot /mnt bash -c "sed -i 's/#W/W/' /etc/gdm/custom.conf && exit"
}

function installxfce4 {
	pacstrap /mnt xorg xfce4 sddm papirus-icon-theme
	arch-chroot /mnt bash -c "systemctl enable sddm && exit"
}

function installkde {
	pacstrap /mnt xorg plasma sddm papirus-icon-theme
	arch-chroot /mnt bash -c "systemctl enable sddm && exit"
	pacstrap /mnt ark dolphin ffmpegthumbs gwenview kaccounts-integration kate kdialog kio-extras konsole ksystemlog okular print-manager
}

function de {
	br
	  echo -e "Che d.e. vuoi? : \n"
	echo -e "1. GNOME \n2. KDE Plasma \n3. Xfce4 \n4. Btw i use shell"
	read -r -p "DE: " desktope
case "$desktope" in
		1)
			installgnome
			;;
		2)
			installkde
			;;
		3)
			installxfce4
			;;
		*)
			;;
	esac
	cont
}

function installgrub {
	read -r -p "Installare il bootloader GRUB? [S/n] " igrub
	case "$igrub" in
		[sS][iI]|[sS])
			;;
		*)
echo -e "Installing GRUB.."
			arch-chroot /mnt bash -c "grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=Arch && grub-mkconfig -o /boot/grub/grub.cfg && exit"
			;;
	esac
	cont
}

function archroot {
	br
	read -r -p "Inserisci il nomeutente: " uname
	read -r -p "Inserisci il nome del pc, hostname : " hname

	echo -e "Imposto località [Rome] \n"
	arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/Europe/Rome /etc/localtime && hwclock --systohc && sed -i 's/#it_IT.UTF-8/it_IT.UTF-8/' /etc/locale.gen && locale-gen && echo 'LANG=it_IT.UTF-8' > /etc/locale.conf && exit"

	echo -e "Imposto hostname\n"
	arch-chroot /mnt bash -c "echo $hname > /etc/hostname && echo 127.0.0.1	$hname > /etc/hosts && echo ::1	$hname >> /etc/hosts && echo 127.0.1.1	$hname.localdomain	$hname >> /etc/hosts && exit"

	echo "Imposto password di root:"
	arch-chroot /mnt bash -c passwd
	arch-chroot /mnt bash -c useradd --create-home $uname && echo "Imposto la password dell'utente:"
	arch-chroot /mnt bash -c passwd $uname
	arch-chroot /mnt bash -c groupadd sudo
	arch-chroot /mnt bash -c gpasswd -a $uname sudo
	arch-chroot /mnt bash -c EDITOR=vim visudo && exit

	echo -e "Abilito i serivizi systemctl\n"
	arch-chroot /mnt bash -c "systemctl enable bluetooth && exit"
	arch-chroot /mnt bash -c "systemctl enable NetworkManager && exit"

	echo -e "Abilito paccache.timer\n"
	arch-chroot /mnt bash -c "systemctl enable paccache.timer && exit"

	echo -e "Imposto pacman...\n"
	# Enabling multilib in pacman
	arch-chroot /mnt bash -c sed -i '93s/#\[/\[/' /etc/pacman.conf
	arch-chroot /mnt bash -c sed -i '94s/#I/I/' /etc/pacman.conf
	arch-chroot /mnt bash -c pacman -Syu && sleep 1 && exit
	# Tweaking pacman, uncomment options Color, TotalDownload and VerbosePkgList
	arch-chroot /mnt bash -c sed -i '34s/#C/C/' /etc/pacman.conf
	arch-chroot /mnt bash -c sed -i '35s/#T/T/' /etc/pacman.conf
	arch-chroot /mnt bash -c sed -i '37s/#V/V/' /etc/pacman.conf
	arch-chroot /mnt bash -c sleep 1
	arch-chroot /mnt bash -c exit

	cont
}

function installamd {
	pacstrap /mnt mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon
	pacstrap /mnt libva-mesa-driver lib32-libva-mesa-driver mesa-vdpau lib32-mesa-vdpau
}

function installintel {
	pacstrap /mnt lib32-mesa vulkan-intel lib32-vulkan-intel vulkan-icd-loader lib32-vulkan-icd-loader

}

function installvmware {
	pacstrap /mnt open-vm-tools

}

function installnvidia {
	br
	read -r -p "Installo i drv proprietari nvidia? [s/N] " graphic
	case "$graphic" in
		[sS][iI]|[sS])
			pacstrap /mnt nvidia nvidia-settings nvidia-utils lib32-nvidia-utils
			;;
		*)
			;;
	esac
	cont
}

function graphics {
	br
	echo -e "Che scheda video hai? \n"
	echo -e "1 AMD \n2 Nvidia \n3 Intel \n4 Vmware\n 5 Salta"
	read -r -p "Drivers [1/2/3]: " drivere
	case "$drivere" in
		1)
			installamd
			;;
		2)
			installnvidia
			;;

 		3)
			installintel
			;;

		4)
			installvmware
			;;
		*)
			;;
	esac
	cont
}


function fullinstallation {
	settime
	partion
	mounting
	base
	archroot
	de
	installgrub
	graphics
	echo "Installazione completata."
}

function stepinstallation {
	echo "Che punto andare?"
	echo "1. Imposto orario"
	echo "2. Partizionamento"
	echo "3. Montaggio"
	echo "4. Installazione"
	echo "5. Configurazione"
	echo "6. Installa un Desktop Environment"
	echo "7. Installa grub"
	echo "8. Driver video"
	read -r -p "Quindi: " stepno

	array=(settime partion mounting base archroot de installgrub graphics)
	#array=(ascii ascii ascii)
	stepno=$[$stepno-1]
	while [ $stepno -lt ${#array[*]} ]
	do
		${array[$stepno]}
		stepno=$[$stepno+1]
	done
}

function main {
	echo "1. Installa"
	echo "2. Parti da un punto specifico"
	read -r -p "Cosa fare? [1/2] " what
	case "$what" in
		2)
			stepinstallation
			;;
		*)
			fullinstallation
			;;
	esac
}

ascii
read -r -p "Inizia installazione? [S/n] " starti
case "$starti" in
	[nN][oO]|[nN])
		;;
	*)
		main
		;;
esac

read -r -p "Installazione finita. riavviare? [S/n] " starti
case "$starti" in
	[nN][oO]|[nN])
		;;
	*)
		reboot
		;;
esac
