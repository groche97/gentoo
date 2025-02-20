# Copyright 1999-2024 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{10..12} )
inherit autotools bash-completion-r1 flag-o-matic python-any-r1

DESCRIPTION="Tools for the TPM 2.0 TSS"
HOMEPAGE="https://github.com/tpm2-software/tpm2-tools"
SRC_URI="https://github.com/tpm2-software/tpm2-tools/releases/download/${PV}/${P}.tar.gz"
SRC_URI+=" https://dev.gentoo.org/~sam/distfiles/${CATEGORY}/${PN}/tpm2-tools-5.6-tpm2_eventlog-Create-raw-and-pretty-print-format-for.patch.xz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~arm64 ~ppc64 ~x86"
IUSE="+fapi test"

RESTRICT="!test? ( test )"

RDEPEND=">=app-crypt/tpm2-tss-3.0.1:=[fapi?]
	dev-libs/openssl:=
	net-misc/curl
	sys-libs/efivar:="
DEPEND="${RDEPEND}
	test? (
		app-crypt/swtpm
		app-crypt/tpm2-abrmd
		dev-util/cmocka
	)"
BDEPEND="virtual/pkgconfig
	dev-build/autoconf-archive
	test? (
		app-editors/vim-core
		dev-tcltk/expect
		$(python_gen_any_dep 'dev-python/pyyaml[${PYTHON_USEDEP}]')
	)
	${PYTHON_DEPS}"

PATCHES=(
	"${FILESDIR}/${PN}-5.6-test-eventlog-fix-check-eventlog.sh-if-efivar.h-exis.patch"
	"${WORKDIR}/${PN}-5.6-tpm2_eventlog-Create-raw-and-pretty-print-format-for.patch"
	"${FILESDIR}/${PN}-5.6-Makefile-am-Dont-require-pandoc-for-tests.patch"
)

python_check_deps() {
	python_has_version "dev-python/pyyaml[${PYTHON_USEDEP}]"
}

pkg_setup() {
	use test && python-any-r1_pkg_setup
}

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	# tests fail with LTO enabbled. See bug 865275 and 865277
	filter-lto
	econf \
		$(use_enable fapi) \
		$(use_enable test unit) \
		--with-bashcompdir=$(get_bashcompdir) \
		--enable-hardening
}

src_install() {
	default
	mv "${ED}"/$(get_bashcompdir)/tpm2{_completion.bash,} || die
	local utils=( "${ED}"/usr/bin/tpm2_* )
	utils=("${utils[@]##*/}")
	# these utiltites don't have bash completions
	local nobashcomp=( tpm2_encodeobject tpm2_getpolicydigest tpm2_sessionconfig )
	mapfile -d $'\0' -t utils < <(printf '%s\0' "${utils[@]}" | grep -Ezvw "${nobashcomp[@]/#/-e}")
	bashcomp_alias tpm2 "${utils[@]}"
}
