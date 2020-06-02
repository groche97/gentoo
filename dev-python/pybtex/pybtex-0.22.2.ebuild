# Copyright 1999-2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{6,7,8} )
DISTUTILS_USE_SETUPTOOLS=rdepend

inherit distutils-r1

DESCRIPTION="BibTeX-compatible bibliography processor"
HOMEPAGE="https://pybtex.org https://pypi.org/project/pybtex/"
SRC_URI="https://files.pythonhosted.org/packages/source/p/${PN}/${P}.tar.gz"
PATCHES=( "${FILESDIR}/${P}-fix-test-installation.patch" )
IUSE="test"
RESTRICT="!test? ( test )"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"

RDEPEND="dev-python/latexcodec[${PYTHON_USEDEP}]
		dev-python/pyyaml[${PYTHON_USEDEP}]
		dev-python/six[${PYTHON_USEDEP}]"

BDEPEND="test?  (
				${RDEPEND}
				dev-python/nose[${PYTHON_USEDEP}]
				)"

distutils_enable_tests pytest
