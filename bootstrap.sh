#!/bin/bash
# bootstrap.sh
# @author Zahari Kassabov
#
# This script installs Miniconda and sets it up so that it can
# download the NNPDF binaries. This involves setting custom channels
# in the ~/.condarc file and adding the password for the private
# channel to a ~/.netrc file.
#
# The script tries to do things automatically, but doesn't try to be
# too smart, and asks the user to perform certain tasks manually if it
# doesn't know how to. The precise actions it takes can be seen by
# invoking it with the -h option.

#Don't use colors if we are redirecting.
if [ -t 1 ]; then
	NO='\x1b[31m\x1b[1mNO\x1b(B\x1b[m'
	YES='\x1b[32m\x1b[1mYES\x1b(B\x1b[m'

	BLUE=$(echo -e "\x1b[34m")
	BOLD=$(echo -e "\x1b[1m")
	RESET=$(echo -e "\x1b(B\x1b[m")
else
	NO='NO'
	YES='YES'

	BLUE=''
	BOLD=''
	RESET=''
fi

INSTALLED_CONDA=$NO
SET_CONDARC=$NO
SET_NETRC=$NO

CONDARC="$HOME"/.condarc
NETRC="$HOME"/.netrc

if [ "$(uname)" == "Darwin" ]; then
	CONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-latest-MacOSX-x86_64.sh
else
	CONDA_URL=https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh
fi

read -d '' CONDARCCONTENT << EOF
channels:
  - https://zigzah.com/static/conda-pkgs-private
  - https://zigzah.com/static/conda-pkgs
  - defaults
  - conda-forge

EOF


function get_netrc() {
cat << EOF
machine zigzah.com
    login nnpdf
    password $1

EOF
}

PRIVATE_URL='https://zigzah.com/static/conda-pkgs-private/linux-64/repodata.json'

read  -d '' DOC << EOF
This script does three things:

 - Download and install conda.

 - Set the appropiriate conda channels to install the NNPDF
 dependencies. This is done by writting a ~/.condarc file with the
 following content:
$BLUE
$CONDARCCONTENT
$RESET
 In case the file exists, the srcipt doesn't touch it (as not even
 with conda config is it easy to set the channels in order).

 - Ask for the password for the private repositories and set it on
 a ~/.netrc file. The content that needs to be added is:
$BLUE
$(get_netrc '<password>')
$RESET
EOF


while getopts "bfhp:" x; do
    case "$x" in
        h)
			echo -e "$DOC"
			exit 2
			;;
	esac
done

HAVE_WGET=$(which wget)
if ! [ $HAVE_WGET  ]; then
	echo "Error. This script requires wget. Please install it."
	exit 1
fi

echo "Setting up componentes for the NNPDF binaries..."

HAVE_CONDA=$(which conda)

SKIP_DOWNLOAD=false

if [ $HAVE_CONDA ]; then
	echo "It appears that conda is installed at $HAVE_CONDA. Skip Download (y/n)?"
	#while [ "$SKIP_DOWNLOAD" != "y"] && [ "$SKIP_DOWNLOAD" != "n" ]
	while [ true ]
	do
		read -n 1 USER_SKIP
		echo
		if [ "$USER_SKIP" == 'y' ]; then
			SKIP_DOWNLOAD=true
			break
		elif [ "$USER_SKIP" == 'n' ]; then
			SKIP_DOWNLOAD=false
			break
		else
			echo "Please enter 'y' or 'n'."
		fi

	done
fi

if [ "$SKIP_DOWNLOAD" = false  ]; then
	echo "Downloading conda"
	TEMP_PATH=`mktemp -d -t conda_downloadXXXXXXXXX`
    wget $CONDA_URL -P $TEMP_PATH
	#TEMP_PATH='/tmp/conda_downloadRyt1MU2sR'
	echo "Entering conda installer."
	CONDA_FILE="$TEMP_PATH/*.sh"
	chmod +x $CONDA_FILE
	bash $CONDA_FILE
	if [ $? == 0 ]; then
		INSTALLED_CONDA=$YES
	fi
fi

HAVE_CONDA=$(which conda)
read -d '' CONDA_READY <<EOF
Could not find the conda binary. You need to locate it and add it
manually to the PATH.
EOF

if [ $HAVE_CONDA ]; then
	CONDA_READY=''
else
	source $HOME/.bashrc
	HAVE_CONDA=$(which conda)
	if [ $HAVE_CONDA ]; then
		read -d '' CONDA_READY << EOF
You need to run
$BLUE
source ~/.bashrc
$RESET
or exit the terminal.
EOF

	fi
fi


if [ -s "$CONDARC" ]; then
	printf  "
The file $CONDARC already exists. Please add manually the following as
appropiate:
\x1b[34m
$CONDARCCONTENT
\x1b(B\x1b[m
"
else
	echo "$CONDARCCONTENT" > $CONDARC
	if [ $? == 0 ]; then
		SET_CONDARC=$YES
		echo "Sucessfully updated .condarc."
		echo
	fi

fi

echo "Please enter the password for the NNPDF private repositories. Enter 'q' to skip."
PASSWORD_OK=false
while [ true ]
do
	read -s PASSWORD
	if [ ${PASSWORD:-''} == 'q' ]; then
		break
	fi
	echo "Testing password"
	TEST=$( wget -S --spider $PRIVATE_URL --user nnpdf --password \
	$PASSWORD 2>&1 | grep HTTP |  tail -1 | grep OK)
	if [ "$TEST" ]; then
		echo "Password appears to be correct."
		PASSWORD_OK=true
		break
	else
		echo "Password does not seem to work. Please enter it again. Enter 'q' to skip."
	fi
done

if [ $PASSWORD_OK == true ]; then
	if ! [ -s "$NETRC" ]; then
		touch $NETRC
		chmod 600 $NETRC
	fi
	echo "$(get_netrc $PASSWORD)" >> $NETRC
	if [ $? == 0 ]; then
		SET_NETRC=$YES
	fi
fi
if [ $SET_NETRC == $NO ]; then
	echo "
Could not set the pasword in $NETRC. Edit it manually to contain:
$BLUE
$( get_netrc '<password>' )
$RESET"
fi

echo
echo ---------------------------------------------------------------------- 
printf "${BOLD}Summary:$RESET\n"
printf "Installed conda: $INSTALLED_CONDA\n"
printf "Set channels in ~/.condarc: $SET_CONDARC\n"
printf "Set password in ~/.netrc: $SET_NETRC\n"
echo "$CONDA_READY"
echo ---------------------------------------------------------------------- 
echo "
If everything went well (see summary above), you should be able to
install the NNPDF binaries now. For example, to install the main code, run:
$BLUE
conda install nnpdf
$RESET"

