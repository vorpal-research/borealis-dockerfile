FROM base/archlinux
MAINTAINER Marat Akhin <akhin@kspt.icc.spbstu.ru>

RUN pacman -Syy --noconfirm
RUN pacman -S --noconfirm \
	archlinux-keyring
RUN pacman -Su --noconfirm
RUN pacman-db-upgrade

RUN trust extract-compat

RUN pacman -S --noconfirm \
	base-devel \
	diffutils \
	gettext \
	git \
	wget \
	yajl

RUN groupadd borealis
RUN useradd -m -g borealis -G wheel borealis

COPY sudoers /etc/sudoers

USER borealis
WORKDIR /tmp
RUN git clone https://aur.archlinux.org/package-query.git
WORKDIR /tmp/package-query
RUN makepkg
USER root
RUN pacman -U --noconfirm *.pkg.tar.xz

USER borealis
WORKDIR /tmp
RUN git clone https://aur.archlinux.org/yaourt.git
WORKDIR /tmp/yaourt
RUN makepkg
USER root
RUN pacman -U --noconfirm *.pkg.tar.xz

USER root
WORKDIR /tmp
RUN rm -rf package-query yaourt

USER borealis
RUN mkdir ~/tmp
RUN yaourt -S --tmp ~/tmp --noconfirm \
	jdk \
	jsoncpp \
	log4cpp \
	mathsat-5 \
	ocaml \
	protobuf \
	tinyxml2 \
	z3-stable-git

ENV PATH $PATH:/usr/bin/core_perl

RUN yaourt -S --tmp ~/tmp --noconfirm \
	clang-debug

RUN rm -rf ~/tmp
RUN yaourt -Sc --noconfirm

USER root
RUN find /opt/clang -name "*.a" -exec strip --strip-debug {} \;
RUN find /opt/clang -name "*.so" -exec strip --strip-debug {} \;
RUN find /opt/clang/3.5.1/bin -type f -exec strip --strip-debug {} \;
RUN rm -rf /var/cache/pacman/pkg/

USER borealis
RUN yaourt -S --noconfirm \
	clang \
	cmake \
	gperftools \
	gtest \
	mercurial

WORKDIR /home/borealis
RUN hg clone http://kallithea.local/org/jetbrains/borealis
WORKDIR /home/borealis/borealis
RUN make -j8

RUN yaourt -Rs --noconfirm \
	chrpath \
	jdk \
	ocaml \
	pth \
	python-sphinx \
	run-parts
