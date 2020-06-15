#!/bin/sh
#
# -----------------------------------------------------------------------------
# Purpose : macOS Package Uninstaller
# -----------------------------------------------------------------------------
# Description :
#  macOS Package Uninstaller   
#
# 2019.08.27 created https://github.com/n-isoda
# -----------------------------------------------------------------------------
#
#
# 

LC_ALL=C
LANG=C

usage () {
    echo ""
	echo "usage: $0 [[-h]|[l|d] PKGID]"
    echo ""
    echo "Options:"
    echo "  -h          Show this usage guide"
    echo "  -l PKGID    Show package files list"
    echo "  -d PKGID    Delete package files"
    echo "              * you must be root"
    echo ""
    exit 1
}

main () {(

	PKGID=$1
    
    PKG_INSTALL_PATH=$(pkgutil --info ${PKGID} 2>/dev/null | awk -F': ' '/^(volume|location)/{printf $2}')

    if [ "x${PKG_INSTALL_PATH}" != "x" ]; then

        pkgutil --files $PKGID | sort -r | \
            while IFS= read file; do
                echo $PKG_INSTALL_PATH$file
                if [ -f "$PKG_INSTALL_PATH$file" ]; then
                    echo rm "$PKG_INSTALL_PATH$file"
                    if ${isDelete}; then
                        rm "$PKG_INSTALL_PATH$file"
                    fi
                elif [ -d "$PKG_INSTALL_PATH$file" ]; then
                    echo rmdir "$PKG_INSTALL_PATH$file"
                    if ${isDelete}; then
                        rmdir "$PKG_INSTALL_PATH$file"
                    fi
                fi
            done


        if ${isDelete};  then
            pkgutil --forget ${PKGID}
        fi
    else
        echo "PKGID: ${PKGID} is not found."
        echo "    You can get PKGID via following command"
        echo "    pkgutil --pkgs"
    fi
)}

if [ "x$(uname)" != 'xDarwin' ]; then
    echo This Script Support Only macOS.
    exit 1
fi

# No Args
if [ $# -eq 0 ]; then
    usage
fi

while getopts :hl:d: OPT; do
    case $OPT in
        "h") usage ;;
        "d")
            isDelete=true
            PKGID="$OPTARG"
            if [ $(id -u) -ne 0 ]; then
                echo "You must be root"
                exit 1
            else
                main $PKGID
            fi
            ;;
        "l") 
            isDelete=false
            PKGID="$OPTARG"
            main $PKGID
            ;;
         :) usage ;;
         \?) usage ;;
         *) usage ;;
    esac
done

shift $((OPTIND - 1))

