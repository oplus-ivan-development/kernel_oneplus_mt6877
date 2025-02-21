#!/bin/bash
clear
function compile() 
{
echo ORIGIN KERNEL FOR ONEPLUS NORD CE 2 5G, CODENAMED - IVAN
echo
source ~/.bashrc && source ~/.profile
export LC_ALL=C && export USE_CCACHE=1
ccache -M 100G >/dev/null
export ARCH=arm64
export KBUILD_BUILD_HOST=origin
export KBUILD_BUILD_USER=
clangbin=clang/bin/clang
if ! [ -a $clangbin ]; then git clone --depth=1 https://github.com/techyminati/android_prebuilts_clang_host_linux-x86_clang-6443078 clang
fi
gcc64bin=los-4.9-64/bin/aarch64-linux-android-as
if ! [ -a $gcc64bin ]; then git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_aarch64_aarch64-linux-android-4.9 los-4.9-64
fi
gcc32bin=los-4.9-32/bin/arm-linux-androideabi-as
if ! [ -a $gcc32bin ]; then git clone --depth=1 https://github.com/LineageOS/android_prebuilts_gcc_linux-x86_arm_arm-linux-androideabi-4.9 los-4.9-32
fi
read -p "Wanna do dirty build? (Y/N): " build_type
if [[ $build_type == "N" || $build_type == "n" ]]; then
echo Deleting out directory and doing clean Build
rm -rf out && mkdir -p out
fi
if [[ $build_type == "Y" || $build_type == "y" ]]; then
echo Warning :- Doing dirty build
fi
if ! [[ $build_type == "Y" || $build_type == "y" ]]; then
if ! [[ $build_type == "N" || $build_type == "n" ]]; then
echo Invalid Input , Read carefully before typing
echo Trying to restart script
. build.sh && exit
fi
fi

make O=out ARCH=arm64 ivan_defconfig

PATH="${PWD}/clang/bin:${PATH}:${PWD}/los-4.9-32/bin:${PATH}:${PWD}/los-4.9-64/bin:${PATH}" \
make -j$(nproc --all)   O=out \
                        ARCH=arm64 \
                        CC="clang" \
                        CLANG_TRIPLE=aarch64-linux-gnu- \
                        CROSS_COMPILE="${PWD}/los-4.9-64/bin/aarch64-linux-android-" \
                        CROSS_COMPILE_ARM32="${PWD}/los-4.9-32/bin/arm-linux-androideabi-" \
                        LD=ld.lld \
                        AS=llvm-as \
                        AR=llvm-ar \
                        NM=llvm-nm \
                        LLVM_IAS=1 \
                        OBJCOPY=llvm-objcopy \
                        CONFIG_NO_ERROR_ON_MISMATCH=y
}

function zupload()
{
zimage=out/arch/arm64/boot/Image.gz
if ! [ -a $zimage ];
then
echo  " Failed to compile zImage, fix the errors first "
else
echo -e " Build succesful, generating flashable zip now "
rm -rf AnyKernel
git clone --depth=1 https://github.com/Notganesh/AnyKernel3.git AnyKernel
cp out/arch/arm64/boot/Image.gz AnyKernel
cd AnyKernel
zip -r9 ORIGIN-OSS-KERNEL-MT6877.zip *
#curl --upload-file ORIGIN-OSS-KERNEL-MT6877.zip https://transfer.sh/
curl -sL https://git.io/file-transfer | sh
./transfer anon ORIGIN-OSS-KERNEL-MT6877.zip
cd ../
fi
}

compile
zupload
