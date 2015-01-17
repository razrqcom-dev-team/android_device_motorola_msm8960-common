# Custom creation of Motorola MSM8960DT devtree

LOCAL_PATH := $(call my-dir)

# Device trees from kernel
MSM8960DT_DEVTREE := mmi-8960pro.dtb \
    msm8960-vanquish-p1.dtb \
    msm8960-vanquish-p2.dtb \
    msm8960-vanquish-p1b2.dtb \
    msm8960-vanquish-p3.dtb \
    msm8960-smq-p1.dtb \
    msm8960-smq-p1a.dtb \
    msm8960-smq-p2.dtb \
    msm8960-smq-p2a.dtb \
    msm8960-smq-p20a.dtb \
    msm8960-solstice-p1.dtb \
    msm8960-solstice-p3.dtb

MSM8960DT_DEVTREE_OBJ := $(addprefix $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/arch/arm/boot/,$(MSM8960DT_DEVTREE))
MOTO_DTBTOOL := $(HOST_OUT_EXECUTABLES)/dtbToolMoto$(HOST_EXECUTABLE_SUFFIX)

INSTALLED_DTIMAGE_TARGET := $(PRODUCT_OUT)/dt.img

$(INSTALLED_DTIMAGE_TARGET): $(MOTO_DTBTOOL) $(TARGET_OUT_INTERMEDIATES)/KERNEL_OBJ/usr $(INSTALLED_KERNEL_TARGET)
	$(call pretty,"Create device tree image: $@")
	$(hide) $(MOTO_DTBTOOL) -o $(INSTALLED_DTIMAGE_TARGET) $(MSM8960DT_DEVTREE_OBJ)
	@echo -e ${CL_CYN}"Made device tree image: $@"${CL_RST}

$(INSTALLED_BOOTIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) $(INTERNAL_BOOTIMAGE_FILES) $(BOOTIMAGE_EXTRA_DEPS)
	$(call pretty,"Target boot image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_BOOTIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_BOOTIMAGE_PARTITION_SIZE))
	@echo -e ${CL_CYN}"Made boot image: $@"${CL_RST}

$(INSTALLED_RECOVERYIMAGE_TARGET): $(MKBOOTIMG) $(INSTALLED_DTIMAGE_TARGET) $(recovery_ramdisk) $(recovery_kernel)
	$(call pretty,"Target recovery image: $@")
	$(hide) $(MKBOOTIMG) $(INTERNAL_RECOVERYIMAGE_ARGS) $(BOARD_MKBOOTIMG_ARGS) --output $@
	$(hide) $(call assert-max-image-size,$@,$(BOARD_RECOVERYIMAGE_PARTITION_SIZE))
	@echo -e ${CL_CYN}"Made recovery image: $@"${CL_RST}
