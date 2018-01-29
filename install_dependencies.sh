#!/bin/bash
#
# Install the necessary dependencies for openFrameworks on openSUSE Tumbleweed
# This script assumes the git repository of openFrameworks to be located at the 
# given argument path 
#
# Suggested usage:
#
# $ sudo -e ./install_dependencies.sh ${OF_HOME}
#
# Copyright 2018 Greg von Winckel
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
# PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
# FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
# DEALINGS IN THE SOFTWARE.
#

if [ "$#" -lt 1 ]; then
  echo "You must supply the openFrameworks source path"
  exit 1
fi

OF_HOME=${1}
FORMULAS="${OF_HOME}/scripts/apothecary/apothecary/formulas"

CURRENT_PATH=`pwd`

WORK_PATH="${CURRENT_PATH}/work"
if [ ! -d ${WORK_PATH} ]; then
  mkdir ${WORK_PATH}
fi

cd ${WORK_PATH}

# Add the repository for RT Audio
zypper addrepo http://ftp.gwdg.de/pub/opensuse/repositories/multimedia:/libs/openSUSE_Tumbleweed/ opensuse-multimedia-libs

# Install the development versions of packages
zypper install                  \
alsa-devel                      \
boost-devel                     \
cmake                           \
flac-devel                      \
freeglut-devel                  \
freeimage-devel                 \
gcc-c++                         \
glew-devel                      \
gstreamer-devel                 \
gstreamer-plugins-base-devel    \
libcurl-devel                   \
libjack-devel                   \
libpulse-devel                  \
libraw1394-devel                \
libsndfile-devel                \
libtheora-devel                 \
libudev-devel                   \
libvorbis-devel                 \
libXmu-devel                    \
libXxf86vm-devel                \
make                            \
openal-soft-devel               \
portaudio-devel                 \
python-lxml                     \
rtaudio-devel  

ln -s /usr/include/rtaudio/RtAudio.h /usr/include/RtAudio.h


# Install the packages from source
zypper si      \
assimp         \
glfw           \
gmp            \
libXcursor     \
libXi          \
mpc            \
mpfr           \
opencv         \
liburiparser1  \
pugixml        \
xrandr         


# Where zypper should install the package source archives
PACKAGES_PATH="/usr/src/packages/SOURCES"

extract_pkg() 
{
  PKG=${1}
  EXT=${2}
  RESULT=`ls ${PACKAGES_PATH} | grep -m1 "${PKG}.*${EXT}"`
  FILENAME=`echo ${RESULT}%.${EXT}*`

  FOLDER="${PACKAGES_PATH}/${FILENAME}"

  if [[ ${EXT} = *"bz2" ]]; then
    tar xfj "${PACKAGES_PATH}/${RESULT}" 
  elif [[ ${EXT} = *"gz" ]]; then
    tar xfz "${PACKAGES_PATH}/${RESULT}" 
  else
    tar xf "${PACKAGES_PATH}/${RESULT}" 
  fi

  echo ${FOLDER}
}

build_configure()
{
  DIR=${1}
  cd ${DIR}
  ./configure
  make -j`ncores` && make install
  cd ${WORK_PATH}
}

build_cmake()
{
  DIR=${1}
  cd ${DIR}
  mkdir build
  cd build
  cmake ..
  make -j`ncores` && make install
  cd ${WORK_PATH}
}


##########################################################################################
echo "Extracting assimp - Library to load and process 3D scenes from various data formats"  

DIR=`extract_pkg assimp tar.gz`
build_cmake ${DIR}

##########################################################################################
echo "Extracting cairo - Vector Graphics Library with Cross-Device Output Support"

DIR=`extract_pkg cairo tar.xz`
build_configure ${DIR}

##########################################################################################
echo "Extracting glfw - Framework for OpenGL application development"

DIR=`extract_pkg glfw tar.gz`
build_cmake ${DIR}

##########################################################################################
echo "Extracting gmp - The GNU MP Library"

DIR=`extract_pkg gmp tar.xz`
build_configure ${DIR}

##########################################################################################
echo "Extracting libXcursor - X Window System Cursor management library"

DIR=`extract_pkg libXcursor tar.bz2`
build_configure ${DIR}

##########################################################################################
echo "Extracting libXi - X Input Extension library"

DIR=`extract_pkg libXi tar.bz2`
build_configure ${DIR}

##########################################################################################
echo "Extracting mpc - MPC multiple-precision complex shared library"

DIR=`extract_pkg mpc tar.gz`
build_configure ${DIR}

##########################################################################################
echo "Extracting mpfr - The GNU multiple-precision floating-point library"

DIR=`extract_pkg mpfr tar.bz2`
build_configure ${DIR}
svgtiny
##########################################################################################
echo "Extracting pugixml - Light-weight C++ XML Processing Library"

DIR=`extract_pkg pugixml tar.gz`
build_cmake ${DIR}

##########################################################################################
echo "Extacting liburiparser1 - A strictly RFC 3986 compliant URI parsing library"

DIR=`extract_pkg uriparser tar.bz2`
build_configure ${DIR}

##########################################################################################
echo "Extracting xrandr - Primitive command line interface to RandR extension"

DIR=svgtiny`extract_pkg xrandr tar.bz2`
build_configure ${DIR}



# Install packages using the Apothecary scripts
cd ${FORMULAS}

./FreeImage/FreeImage.sh
./fmodex.sh
./json.sh
./kiss/kiss.sh
./libpng/libpng.sh
./libxml2/libxml2.sh
./openssl/openssl.sh
./poco/poco.sh
./svgtiny/svgtiny.sh
./tess2/tess2.sh
./uri/uri.sh
./utf8.sh
./videoInput.sh

cd ${CURRENT_PATH}
