# Class for creating rauc bundles
#
# Description:
# 
# You have to set the slot images in your recipe file following this example:
#
#   RAUC_BUNDLE_COMPATIBLE ?= "My Super Product"
#   RAUC_BUNDLE_VERSION ?= "v2015-06-07-1"
#
#   SRC_URI += "file://hook.sh"
#
#   RAUC_BUNDLE_HOOKS[file] ?= "hook.sh"
#   RAUC_BUNDLE_HOOKS[hooks] ?= "install-check"
#
#   RAUC_BUNDLE_SLOTS ?= "rootfs kernel dtb bootloader"
#   
#   RAUC_SLOT_rootfs ?= "core-image-minimal"
#   RAUC_SLOT_rootfs[fstype] = "ext4"
#   RAUC_SLOT_rootfs[hooks] ?= "pre-install;post-install"
#   RAUC_SLOT_rootfs[adaptive] ?= "block-hash-index"
#   
#   RAUC_SLOT_kernel ?= "linux-yocto"
#   RAUC_SLOT_kernel[type] ?= "kernel"
#   
#   RAUC_SLOT_bootloader ?= "barebox"
#   RAUC_SLOT_bootloader[type] ?= "boot"
#   RAUC_SLOT_bootloader[file] ?= "barebox.img"
#
#   RAUC_SLOT_dtb ?= linux-yocto
#   RAUC_SLOT_dtb[type] ?= "file"
#   RAUC_SLOT_dtb[file] ?= "${MACHINE}.dtb"
#
# To use a different image name, e.g. for variants
#   RAUC_SLOT_dtb ?= linux-yocto
#   RAUC_SLOT_dtb[name] ?= "dtb.my,compatible"
#   RAUC_SLOT_dtb[type] ?= "file"
#   RAUC_SLOT_dtb[file] ?= "${MACHINE}-variant1.dtb"
#
# To override the file name used in the bundle use 'rename'
#   RAUC_SLOT_rootfs ?= "core-image-minimal"
#   RAUC_SLOT_rootfs[rename] ?= "rootfs.ext4"
#
# To generate an artifact image, use <repo>/<artifact> as the image name:
#   RAUC_BUNDLE_SLOTS += "containers/test"
#   RAUC_SLOT_containers/test ?= "container-test-image"
#   RAUC_SLOT_containers/test[fstype] = "tar.gz"
#   RAUC_SLOT_containers/test[convert] = "tar-extract;composefs"
#
# To prepend an offset to a bootloader image, set the following parameter in bytes.
# Optionally you can use units allowed by 'dd' e.g. 'K','kB','MB'.
# If the offset is negative, bytes will not be added, but removed.
#   RAUC_SLOT_bootloader[offset] ?= "0"
#
# Enable building verity format bundles with
#
#   RAUC_BUNDLE_FORMAT = "verity"
#
# To add additional files to the bundle you can use RAUC_BUNDLE_EXTRA_FILES
# and RAUC_BUNDLE_EXTRA_DEPENDS.
# For files from the UNPACKDIR (fetched using SRC_URI) you can write:
#
#   SRC_URI += "file://myfile"
#   RAUC_BUNDLE_EXTRA_FILES += "myfile"
#
# For files from the DEPLOY_DIR_IMAGE (generated by another recipe) you can write:
#
#   RAUC_BUNDLE_EXTRA_DEPENDS += "myfile-recipe-pn"
#   RAUC_BUNDLE_EXTRA_FILES += "myfile.img"
#
# Extra arguments may be passed to the bundle command with BUNDLE_ARGS eg:
#   BUNDLE_ARGS += ' --mksquashfs-args="-comp zstd -Xcompression-level 22" '
#
# Likewise, extra arguments can be passed to the convert command with
# CONVERT_ARGS.
#
# Additionally you need to provide a certificate and a key file
#
#   RAUC_KEY_FILE ?= "development-1.key.pem"
#   RAUC_CERT_FILE ?= "development-1.cert.pem"
#
# For bundle signature verification a keyring file must be provided
#
#   RAUC_KEYRING_FILE ?= "ca.cert.pem"
#
# Enable building casync bundles with
#
#   RAUC_CASYNC_BUNDLE = "1"
#
# To define custom manifest 'meta' sections, you may use
# 'RAUC_META_SECTIONS' as follows:
#
#   RAUC_META_SECTIONS = "mydata foo"
#
#   RAUC_META_mydata[release-type] = "beta"
#   RAUC_META_mydata[release-notes] = "a few notes here"
#
#   RAUC_META_foo[bar] = "baz"
#
# Adding any sort of additional lines to the manifest can be done with the
# RAUC_MANIFEST_EXTRA_LINES variable (using '\n' to indicate newlines):
#
#   RAUC_MANIFEST_EXTRA_LINES = "[section]\nkey=value\n"

LICENSE ?= "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit nopackages

PACKAGES = ""
INHIBIT_DEFAULT_DEPS = "1"

# [""] is added to avoid "list index out of range" error with empty IMAGE_FSTYPES
RAUC_IMAGE_FSTYPE ??= "${@(d.getVar('IMAGE_FSTYPES').split() + [""])[0]}"
RAUC_IMAGE_FSTYPE[doc] = "Specifies the default file name extension to expect for collecting images. Defaults to first element set in IMAGE_FSTYPES."

do_fetch[cleandirs] = "${S}"
do_patch[noexec] = "1"
do_compile[noexec] = "1"
do_install[noexec] = "1"
deltask do_populate_sysroot

RAUC_BUNDLE_COMPATIBLE  ??= "${MACHINE}${TARGET_VENDOR}"
RAUC_BUNDLE_VERSION     ??= "${PV}"
RAUC_BUNDLE_DESCRIPTION ??= "${SUMMARY}"
RAUC_BUNDLE_BUILD       ??= "${DATETIME}"
RAUC_BUNDLE_BUILD[vardepsexclude] = "DATETIME"
RAUC_BUNDLE_COMPATIBLE[doc] = "Specifies the mandatory bundle compatible string. See RAUC documentation for more details."
RAUC_BUNDLE_VERSION[doc] = "Specifies the bundle version string. See RAUC documentation for more details."
RAUC_BUNDLE_DESCRIPTION[doc] = "Specifies the bundle description string. See RAUC documentation for more details."
RAUC_BUNDLE_BUILD[doc] = "Specifies the bundle build stamp. See RAUC documentation for more details."

RAUC_BUNDLE_SLOTS[doc] = "Space-separated list of slot classes to include in bundle (manifest)"
RAUC_BUNDLE_HOOKS[doc] = "Allows to specify an additional hook executable and bundle hooks (via varflags '[file'] and ['hooks'])"

RAUC_BUNDLE_EXTRA_FILES[doc] = "Specifies list of additional files to add to bundle. Files must either be located in UNPACKDIR (added by SRC_URI) or DEPLOY_DIR_IMAGE (assured by RAUC_BUNDLE_EXTRA_DEPENDS)"
RAUC_BUNDLE_EXTRA_DEPENDS[doc] = "Specifies list of recipes that create files in DEPLOY_DIR_IMAGE. For recipes not depending on do_deploy task also <recipename>:do_<taskname> notation is supported"

RAUC_CASYNC_BUNDLE ??= "0"

RAUC_BUNDLE_FORMAT ??= ""
RAUC_BUNDLE_FORMAT[doc] = "Specifies the bundle format to be used (plain/verity)."

RAUC_VARFLAGS_SLOTS = "name type fstype file hooks adaptive rename offset depends convert"
RAUC_VARFLAGS_HOOKS = "file hooks"

# Create dependency list from images
python __anonymous() {
    d.appendVarFlag('do_unpack', 'vardeps', ' RAUC_BUNDLE_HOOKS')
    for slot in (d.getVar('RAUC_BUNDLE_SLOTS') or "").split():
        slot_varflags = d.getVar('RAUC_VARFLAGS_SLOTS').split()
        slotflags = d.getVarFlags('RAUC_SLOT_%s' % slot, expand=slot_varflags) or {}

        imgtype = slotflags.get('type')
        if not imgtype:
            bb.debug(1, "No [type] given for slot '%s', defaulting to 'image'" % slot)
            imgtype = 'image'
        image = d.getVar('RAUC_SLOT_%s' % slot)

        if not image:
            bb.error("No image set for slot '%s'. Specify via 'RAUC_SLOT_%s = \"<recipe-name>\"'" % (slot, slot))
            return

        d.appendVarFlag('do_unpack', 'vardeps', ' RAUC_SLOT_%s' % slot)
        depends = slotflags.get('depends')
        if depends:
            d.appendVarFlag('do_unpack', 'depends', ' ' + depends)
            continue

        if imgtype == 'image':
            d.appendVarFlag('do_unpack', 'depends', ' ' + image + ':do_image_complete')
            d.appendVarFlag('do_rm_work_all', 'depends', ' ' + image + ':do_rm_work_all')
        else:
            d.appendVarFlag('do_unpack', 'depends', ' ' + image + ':do_deploy')

    for image in (d.getVar('RAUC_BUNDLE_EXTRA_DEPENDS') or "").split():
        imagewithdep = image.split(':')
        deptask = imagewithdep[1] if len(imagewithdep) > 1 else 'do_deploy'
        d.appendVarFlag('do_unpack', 'depends', ' %s:%s' % (imagewithdep[0], deptask))
        bb.note('adding extra dependency %s:%s' % (imagewithdep[0],  deptask))
}

S = "${UNPACKDIR}"
B = "${WORKDIR}/build"
BUNDLE_DIR = "${S}/bundle"

RAUC_KEY_FILE ??= ""
RAUC_KEY_FILE[doc] = "Specifies the path to the RAUC key file used for signing. Use COREBASE to reference files located in any shared BSP folder."
RAUC_CERT_FILE ??= ""
RAUC_CERT_FILE[doc] = "Specifies the path to the RAUC cert file used for signing. Use COREBASE to reference files located in any shared BSP folder."
RAUC_KEYRING_FILE ??= ""
RAUC_KEYRING_FILE[doc] = "Specifies the path to the RAUC keyring file used for bundle signature verification. Use COREBASE to reference files located in any shared BSP folder."
BUNDLE_ARGS ??= ""
BUNDLE_ARGS[doc] = "Specifies any extra arguments to pass to the rauc bundle command."
CONVERT_ARGS ??= ""
CONVERT_ARGS[doc] = "Specifies any extra arguments to pass to the rauc convert command."


DEPENDS = "rauc-native squashfs-tools-native"
DEPENDS += "${@bb.utils.contains('RAUC_CASYNC_BUNDLE', '1', 'virtual/fakeroot-native casync-native', '', d)}"

inherit image-artifact-names

def write_manifest(d):
    import shutil
    import subprocess
    from pathlib import PurePath

    machine = d.getVar('MACHINE')
    bundle_path = d.expand("${BUNDLE_DIR}")

    bb.utils.mkdirhier(bundle_path)
    try:
        manifest = open('%s/manifest.raucm' % bundle_path, 'w')
    except OSError:
        bb.fatal('Unable to open manifest.raucm')

    manifest.write('[update]\n')
    manifest.write(d.expand('compatible=${RAUC_BUNDLE_COMPATIBLE}\n'))
    manifest.write(d.expand('version=${RAUC_BUNDLE_VERSION}\n'))
    manifest.write(d.expand('description=${RAUC_BUNDLE_DESCRIPTION}\n'))
    manifest.write(d.expand('build=${RAUC_BUNDLE_BUILD}\n'))
    manifest.write('\n')

    bundle_format = d.getVar('RAUC_BUNDLE_FORMAT')
    if not bundle_format:
        bb.warn('No RAUC_BUNDLE_FORMAT set. This will default to using legacy \'plain\' format.'
                '\nIf you are unsure, set RAUC_BUNDLE_FORMAT = "verity" for new projects.'
                '\nRefer to https://rauc.readthedocs.io/en/latest/reference.html#sec-ref-formats for more information about RAUC bundle formats.')
    elif bundle_format != "plain":
        manifest.write('[bundle]\n')
        manifest.write(d.expand('format=${RAUC_BUNDLE_FORMAT}\n'))
        manifest.write('\n')

    hooks_varflags = d.getVar('RAUC_VARFLAGS_HOOKS').split()
    hooksflags = d.getVarFlags('RAUC_BUNDLE_HOOKS', expand=hooks_varflags) or {}
    have_hookfile = False
    if 'file' in hooksflags:
        have_hookfile = True
        manifest.write('[hooks]\n')
        manifest.write("filename=%s\n" % hooksflags.get('file'))
        if 'hooks' in hooksflags:
            manifest.write("hooks=%s\n" % hooksflags.get('hooks'))
        manifest.write('\n')
    elif 'hooks' in hooksflags:
        bb.warn("Suspicious use of RAUC_BUNDLE_HOOKS[hooks] without RAUC_BUNDLE_HOOKS[file]")

    for slot in (d.getVar('RAUC_BUNDLE_SLOTS') or "").split():
        slot_varflags = d.getVar('RAUC_VARFLAGS_SLOTS').split()
        slotflags = d.getVarFlags('RAUC_SLOT_%s' % slot, expand=slot_varflags) or {}

        slotname = slotflags.get('name', slot)
        manifest.write('[image.%s]\n' % slotname)

        imgtype = slotflags.get('type', 'image')

        img_fstype = slotflags.get('fstype', d.getVar('RAUC_IMAGE_FSTYPE'))

        if imgtype == 'image':
            fallback = "%s%s%s.%s" % (d.getVar('RAUC_SLOT_%s' % slot), d.getVar('IMAGE_MACHINE_SUFFIX'), d.getVar('IMAGE_NAME_SUFFIX'), img_fstype)
            imgname = imgsource = slotflags.get('file', fallback)
        elif imgtype == 'kernel':
            # TODO: Add image type support
            fallback = "%s-%s.bin" % ("zImage", machine)
            imgsource = slotflags.get('file', fallback)
            imgname = "%s.%s" % (imgsource, "img")
        elif imgtype == 'boot':
            imgname = imgsource = slotflags.get('file', 'barebox.img')
        elif imgtype == 'file':
            imgsource = slotflags.get('file')
            if not imgsource:
                bb.fatal('Image type "file" requires [file] varflag to be set for slot %s' % slot)
            imgname = "%s.%s" % (imgsource, "img")
        else:
            bb.fatal('Unknown image type: %s' % imgtype)

        imgname = slotflags.get('rename', imgname)
        if 'offset' in slotflags:
            padding = 'seek'
            imgoffset = slotflags.get('offset')
            if imgoffset:
                sign, magnitude = imgoffset[:1], imgoffset[1:]
                if sign == '+':
                    padding = 'seek'
                    imgoffset = magnitude
                elif sign == '-':
                    padding = 'skip'
                    imgoffset = magnitude
            if imgoffset == '':
                imgoffset = '0'

        # Keep only the image name in case the image is in a $DEPLOY_DIR_IMAGE subdirectory
        imgname = PurePath(imgname).name
        manifest.write("filename=%s\n" % imgname)
        if 'hooks' in slotflags:
            if not have_hookfile:
                bb.warn("A hook is defined for slot %s, but RAUC_BUNDLE_HOOKS[file] is not defined" % slot)
            manifest.write("hooks=%s\n" % slotflags.get('hooks'))
        if 'adaptive' in slotflags:
            manifest.write("adaptive=%s\n" % slotflags.get('adaptive'))
        if 'convert' in slotflags:
            manifest.write("convert=%s\n" % slotflags.get('convert'))
        manifest.write("\n")

        bundle_imgpath = "%s/%s" % (bundle_path, imgname)
        bb.note("adding image to bundle dir: '%s'" % imgname)
        searchpath = d.expand("${DEPLOY_DIR_IMAGE}/%s") % imgsource
        if os.path.isfile(searchpath):
            if imgtype == 'boot' and 'offset' in slotflags and imgoffset != '0':
                subprocess.call(['dd', 'if=%s' % searchpath,
                                 'of=%s' % bundle_imgpath,
                                 'iflag=skip_bytes', 'oflag=seek_bytes',
                                 '%s=%s' % (padding, imgoffset)])
            else:
                shutil.copy(searchpath, bundle_imgpath)
        else:
            searchpath = d.expand("${UNPACKDIR}/%s") % imgsource
            if os.path.isfile(searchpath):
                shutil.copy(searchpath, bundle_imgpath)
            else:
                raise bb.fatal('Failed to find source %s' % imgsource)
        if not os.path.exists(bundle_imgpath):
            raise bb.fatal("Failed adding image '%s' to bundle: not present in DEPLOY_DIR_IMAGE or UNPACKDIR" % imgsource)

    for meta_section in (d.getVar('RAUC_META_SECTIONS') or "").split():
        manifest.write("[meta.%s]\n" % meta_section)
        for meta_key in d.getVarFlags('RAUC_META_%s' % meta_section):
            meta_value = d.getVarFlag('RAUC_META_%s' % meta_section, meta_key)
            manifest.write("%s=%s\n" % (meta_key, meta_value))
        manifest.write("\n");

    manifest.write((d.getVar('RAUC_MANIFEST_EXTRA_LINES') or "").replace(r'\n', '\n'))

    manifest.close()

def try_searchpath(file, d):
    searchpath = d.expand("${DEPLOY_DIR_IMAGE}/%s") % file
    if os.path.isfile(searchpath):
        bb.note("adding extra file from deploy dir to bundle dir: '%s'" % file)
        return searchpath
    elif os.path.isdir(searchpath):
        bb.note("adding extra directory from deploy dir to bundle dir: '%s'" % file)
        return searchpath

    searchpath = d.expand("${UNPACKDIR}/%s") % file
    if os.path.isfile(searchpath):
        bb.note("adding extra file from workdir to bundle dir: '%s'" % file)
        return searchpath
    elif os.path.isdir(searchpath):
        bb.note("adding extra directory from workdir to bundle dir: '%s'" % file)
        return searchpath

    return None

python do_configure() {
    import shutil
    import os
    import stat
    import subprocess

    write_manifest(d)

    hooks_varflags = d.getVar('RAUC_VARFLAGS_HOOKS').split()
    hooksflags = d.getVarFlags('RAUC_BUNDLE_HOOKS', expand=hooks_varflags) or {}
    if 'file' in hooksflags:
        hf = hooksflags.get('file')
        if not os.path.exists(d.expand("${UNPACKDIR}/%s" % hf)):
            bb.error("hook file '%s' does not exist in UNPACKDIR" % hf)
            return
        dsthook = d.expand("${BUNDLE_DIR}/%s" % hf)
        bb.note("adding hook file to bundle dir: '%s'" % hf)
        shutil.copy(d.expand("${UNPACKDIR}/%s" % hf), dsthook)
        st = os.stat(dsthook)
        os.chmod(dsthook, st.st_mode | stat.S_IEXEC)

    for file in (d.getVar('RAUC_BUNDLE_EXTRA_FILES') or "").split():
        bundledir = d.getVar('BUNDLE_DIR')
        destpath = d.expand("${BUNDLE_DIR}/%s") % file

        searchpath = try_searchpath(file, d)
        if not searchpath:
            bb.error("extra file '%s' neither found in workdir nor in deploy dir!" % file)

        destdir = '.'
        # strip leading and trailing slashes to prevent installting into wrong location
        file = file.rstrip('/').lstrip('/')

        if file.find("/") != -1:
            destdir = file.rsplit("/", 1)[0] + '/'
            bb.utils.mkdirhier("%s/%s" % (bundledir, destdir))
        bb.note("Unpacking %s to %s/" % (file, bundledir))
        ret = subprocess.call('cp -fpPRH "%s" "%s"' % (searchpath, destdir), shell=True, cwd=bundledir)
}

do_configure[cleandirs] = "${BUNDLE_DIR}"

BUNDLE_BASENAME ??= "${PN}"
BUNDLE_BASENAME[doc] = "Specifies desired output base name of generated RAUC bundle."
BUNDLE_NAME ??= "${BUNDLE_BASENAME}-${MACHINE}-${DATETIME}"
BUNDLE_NAME[doc] = "Specifies desired full output name of generated RAUC bundle."
# Don't include the DATETIME variable in the sstate package sigantures
BUNDLE_NAME[vardepsexclude] = "DATETIME"
BUNDLE_LINK_NAME ??= "${BUNDLE_BASENAME}-${MACHINE}"
BUNDLE_EXTENSION ??= ".raucb"
BUNDLE_EXTENSION[doc] = "Specifies desired custom filename extension of generated RAUC bundle."

CASYNC_BUNDLE_BASENAME ??= "casync-${BUNDLE_BASENAME}"
CASYNC_BUNDLE_BASENAME[doc] = "Specifies desired output base name of generated RAUC casync bundle."
CASYNC_BUNDLE_NAME ??= "${CASYNC_BUNDLE_BASENAME}-${MACHINE}-${DATETIME}"
CASYNC_BUNDLE_NAME[doc] = "Specifies desired full output name of generated RAUC casync bundle."
# Don't include the DATETIME variable in the sstate package sigantures
CASYNC_BUNDLE_NAME[vardepsexclude] = "DATETIME"
CASYNC_BUNDLE_LINK_NAME ??= "${CASYNC_BUNDLE_BASENAME}-${MACHINE}"
CASYNC_BUNDLE_EXTENSION ??= "${BUNDLE_EXTENSION}"
CASYNC_BUNDLE_EXTENSION[doc] = "Specifies desired custom filename extension of generated RAUC casync bundle."

fakeroot do_bundle() {
	if [ -z "${RAUC_KEY_FILE}" ]; then
		bbfatal "'RAUC_KEY_FILE' not set. Please set to a valid key file location."
	fi

	if [ -z "${RAUC_CERT_FILE}" ]; then
		bbfatal "'RAUC_CERT_FILE' not set. Please set to a valid certificate file location."
	fi

	${STAGING_BINDIR_NATIVE}/rauc bundle \
		--debug \
		--cert="${RAUC_CERT_FILE}" \
		--key="${RAUC_KEY_FILE}" \
		${BUNDLE_ARGS} \
		${BUNDLE_DIR} \
		${B}/bundle.raucb

	if [ ${RAUC_CASYNC_BUNDLE} -eq 1 ]; then
		if [ -z "${RAUC_KEYRING_FILE}" ]; then
			bbfatal "'RAUC_KEYRING_FILE' not set. Please set a valid keyring file location."
		fi

		${STAGING_BINDIR_NATIVE}/rauc convert \
			--debug \
			--trust-environment \
			--cert=${RAUC_CERT_FILE} \
			--key=${RAUC_KEY_FILE} \
			--keyring=${RAUC_KEYRING_FILE} \
			${CONVERT_ARGS} \
			${B}/bundle.raucb \
			${B}/casync-bundle.raucb
	fi
}
do_bundle[dirs] = "${B}"
do_bundle[cleandirs] = "${B}"
do_bundle[file-checksums] += "${RAUC_CERT_FILE}:False ${RAUC_KEY_FILE}:False"

addtask bundle after do_configure

inherit deploy

SSTATE_SKIP_CREATION:task-deploy = '1'

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 0644 ${B}/bundle.raucb ${DEPLOYDIR}/${BUNDLE_NAME}${BUNDLE_EXTENSION}
	ln -sf ${BUNDLE_NAME}${BUNDLE_EXTENSION} ${DEPLOYDIR}/${BUNDLE_LINK_NAME}${BUNDLE_EXTENSION}

	if [ ${RAUC_CASYNC_BUNDLE} -eq 1 ]; then
		install -m 0644 ${B}/casync-bundle.raucb ${DEPLOYDIR}/${CASYNC_BUNDLE_NAME}${CASYNC_BUNDLE_EXTENSION}
		cp -r ${B}/casync-bundle.castr ${DEPLOYDIR}/${CASYNC_BUNDLE_NAME}.castr
		ln -sf ${CASYNC_BUNDLE_NAME}${CASYNC_BUNDLE_EXTENSION} ${DEPLOYDIR}/${CASYNC_BUNDLE_LINK_NAME}${CASYNC_BUNDLE_EXTENSION}
		ln -sf ${CASYNC_BUNDLE_NAME}.castr ${DEPLOYDIR}/${CASYNC_BUNDLE_LINK_NAME}.castr
	fi
}

addtask deploy after do_bundle before do_build
