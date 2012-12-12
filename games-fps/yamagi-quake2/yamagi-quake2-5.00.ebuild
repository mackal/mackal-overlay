# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit games

MY_P="quake2-${PV}"
DESCRIPTION="Yamagi Quake 2 source port"
HOMEPAGE="http://deponie.yamagi.org/quake2/"
SRC_URI="http://deponie.yamagi.org/quake2/${MY_P}.tar.xz
	rogue? ( http://deponie.yamagi.org/quake2/quake2-rogue-1.06.tar.xz )
	xatrix? ( http://deponie.yamagi.org/quake2/quake2-xatrix-1.08.tar.xz )"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86 ~sparc"
IUSE="dedicated rogue xatrix"

DEPEND="sys-libs/zlib
		media-libs/openal
		virtual/jpeg
		media-libs/libogg
		media-libs/libvorbis
		virtual/opengl"
RDEPEND="${DEPEND}"

S=${WORKDIR}/${MY_P}
ROGUE="${WORKDIR}/quake2-rogue-1.06"
XATRIX="${WORKDIR}/quake2-xatrix-1.08"

src_prepare() {
	# Patch to be more Gentoo-y
	epatch "${FILESDIR}"/${P}-gentoo-paths.patch
	# Fix executable names
	sed -i 's/quake2/yquake2/g' Makefile || die
	sed -i 's/q2ded/yq2ded/g' Makefile || die
	# Fix zlib stuff
	sed -i -e '8i#define OF(x) x' src/common/unzip/ioapi.h || die
}

src_compile() {
	# Some ugly stuff, could probably be made prettier
	emake \
		DEFAULT_BASEDIR="${GAMES_DATADIR}/quake2" \
		DEFAULT_LIBDIR="$(games_get_libdir)/${PN}${libsuffix}" \
		|| die "make failed"
	use rogue \
		&& cd ${ROGUE} \
		&& make || die "rogue failed"
	use xatrix \
		&& cd ${XATRIX} \
		&& make || die "xatrix failed"
	cd "${S}"
	# Move tuff around to keep libs and bins seperate
	mkdir -p "${S}/rel-bin"
	mkdir -p "${S}/rel-lib"
	mv "${S}/release/yquake2" "${S}/rel-bin"
	mv "${S}/release/yq2ded" "${S}/rel-bin"
	mv "${S}/release/"* "${S}/rel-lib"
	use rogue \
		&& mkdir -p "${S}/rel-lib/rogue" \
		&& mv "${ROGUE}/release/game.so" "${S}/rel-lib/rogue"
	use xatrix \
		&& mkdir -p "${S}/rel-lib/xatrix" \
		&& mv "${XATRIX}/release/game.so" "${S}/rel-lib/xatrix"
}

src_install() {
	local q2dir=$(games_get_libdir)/${PN}

	dodoc README

	dodir "${q2dir}"
	cp -rf "${S}/rel-lib/"* "${D}/${q2dir}"/

	dogamesbin "${S}/rel-bin/yquake2"

	use dedicated \
		&& dogamesbin "${S}/rel-bin"/yq2ded
	use rogue \
		&& dogamesbin "${FILESDIR}"/yquake2-rogue \
		&& make_desktop_entry yquake2-rogue "Yamagi Quake II: Ground Zero" Quake2
	use xatrix \
		&& dogamesbin "${FILESDIR}"/yquake2-xatrix \
		&& make_desktop_entry yquake2-xatrix "Yamagi Quake II: The Reckoning" Quake2

	doicon "${S}"/stuff/icon/Quake2.png
	make_desktop_entry yquake2 "Yamagi Quake II" Quake2

	prepgamesdirs
}
