echo "******************************************************************************"
echo "Install OS Packages." `date`
echo "******************************************************************************"
microdnf install -y unzip tar gzip shadow-utils
microdnf install -y bc
microdnf install -y binutils
microdnf install -y elfutils-libelf
microdnf install -y elfutils-libelf-devel
microdnf install -y fontconfig-devel
microdnf install -y glibc
microdnf install -y glibc-devel
microdnf install -y ksh
microdnf install -y libaio
microdnf install -y libaio-devel
microdnf install -y libXrender
microdnf install -y libX11
microdnf install -y libXau
microdnf install -y libXi
microdnf install -y libXtst
microdnf install -y libgcc
microdnf install -y libnsl
microdnf install -y librdmacm
microdnf install -y libstdc++
microdnf install -y libstdc++-devel
microdnf install -y libxcb
microdnf install -y libibverbs
microdnf install -y make
microdnf install -y smartmontools
microdnf install -y sysstat
microdnf install -y psmisc
microdnf update -y
rm -Rf /var/cache/yum
rm -Rf /var/cache/dnf
