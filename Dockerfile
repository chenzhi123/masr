FROM fedora:33

RUN groupadd staff \
  && useradd -g staff -d /home/docker docker

LABEL org.label-schema.license="GPL-3.0" \
      org.label-schema.vcs-url="https://github.com/XiangyunHuang/masr" \
      org.label-schema.vendor="Book Project" \
      maintainer="Xiangyun Huang <xiangyunfaith@outlook.com>"

ARG CMDSTAN=/opt/cmdstan/cmdstan-2.24.0
ARG CMDSTAN_VERSION=2.24.0

# System dependencies required for R packages
RUN dnf -y upgrade \
  && dnf -y install dnf-plugins-core \
  && dnf -y install pandoc \
   pandoc-citeproc \
   pandoc-pdf \
   glibc-langpack-en \
   NLopt-devel \
   R-devel \
   R-littler \
   R-littler-examples \
   octave-devel \
   ghostscript \
   google-noto-emoji-fonts \
   google-noto-emoji-color-fonts \
   dejavu-serif-fonts \
   dejavu-sans-fonts \
   dejavu-sans-mono-fonts \
   liberation-narrow-fonts \
   liberation-serif-fonts \
   liberation-sans-fonts \
   liberation-mono-fonts \
   inkscape \
   optipng \
   ImageMagick \
   texinfo \
   cargo \
   bzip2 \
   ImageMagick-c++-devel \
   poppler-cpp-devel \
   libjpeg-turbo-devel \
   xorg-x11-server-Xvfb \
   libcurl-devel \
   openssl-devel \
   libssh2-devel \
   libgit2-devel \
   libxml2-devel \
   glpk-devel \
   gmp-devel \
   mariadb \
   mariadb-server \
   mariadb-devel \
   mariadb-connector-odbc \
   unixODBC-devel \
   sqlite-devel \
   gdal-devel \
   proj-devel \
   geos-devel \
   udunits2-devel \
   cairo-devel \
   v8-devel \
   igraph-devel \
   firewalld \
   python3-virtualenv \
   texlive-sourceserifpro \
   texlive-sourcecodepro \
   texlive-sourcesanspro \
   texlive-pdfcrop \
   texlive-dvisvgm \
   texlive-dvips \
   texlive-dvipng \
   texlive-ctex \
   texlive-fandol \
   texlive-xetex \
   texlive-framed \
   texlive-titling \
   texlive-fira \
   texlive-tufte-latex \
   texlive-awesomebox \
   texlive-fontawesome5 \
   texlive-fontawesome \
   texlive-newtx \
   texlive-tcolorbox \
   texlive-fibeamer \
   texlive-pgfornament-han \
   texlive-beamer-verona \
   texlive-beamertheme-metropolis \
   texlive-beamertheme-cuerna

RUN ln -s /usr/lib64/R/library/littler/examples/install.r /usr/bin/install.r \
 && ln -s /usr/lib64/R/library/littler/examples/install2.r /usr/bin/install2.r \
 && ln -s /usr/lib64/R/library/littler/examples/installGithub.r /usr/bin/installGithub.r \
 && ln -s /usr/lib64/R/library/littler/examples/testInstalled.r /usr/bin/testInstalled.r \
 && mkdir -p /usr/local/lib/R/site-library \
 && echo "options(repos = c(CRAN = 'https://cran.r-project.org/'))" | tee -a /usr/lib64/R/etc/Rprofile.site \
 && chmod a+r /usr/lib64/R/etc/Rprofile.site \
 && echo "LANG=en_US.UTF-8" >> /usr/lib64/R/etc/Renviron.site \
 && echo "CXXFLAGS += -Wno-ignored-attributes" >> /usr/lib64/R/etc/Makeconf \
 && Rscript -e 'x <- file.path(R.home("doc"), "html"); if (!file.exists(x)) {dir.create(x, recursive=TRUE); file.copy(system.file("html/R.css", package="stats"), x)}' \
 && mkdir -p ~/.R \
 && echo "CXXFLAGS += -Wno-ignored-attributes" >> ~/.R/Makevars \
 && echo "CXX14 = g++ -flto=2" >> ~/.R/Makevars \
 && echo "CXX14FLAGS = -mtune=native -march=native -Wno-unused-variable -Wno-unused-function -Wno-unused-local-typedefs -Wno-ignored-attributes -Wno-deprecated-declarations -Wno-attributes -O3" >> ~/.R/Makevars \
 && install.r docopt remotes vroom odbc bookdown ggplot2 shiny reactable lme4 glmmTMB data.table rstan sf brms rstanarm patchwork highcharter

# Python virtual env
RUN dnf install -y python3-devel \
  python3-matplotlib \
  python3-numpy \
  python3-scipy \
  python3-sympy \
  python3-scikit-learn \
  python3-pandas \
 && xvfb-run install2.r --error \
   reticulate \
   tikzDevice \
   tidyverse \
   showtext \
   plotly \
   kableExtra \
   hrbrthemes \
   ggrepel \
   ggridges \
   ggpubr \
   agridat \
   arules \
   blastula \
   beanplot \
   extrafont \
   fontcm \
   formatR \
   gganimate \
   rootSolve \
   ggbeeswarm \
   ggfortify \
   ggmosaic \
   ggnormalviolin \
   gifski \
   glmnet \
   magick \
   pdftools \
   quadprog \
   treemap \
   treemapify \
   vioplot \
   xkcd \
   webshot \
   heatmaply \
   Kendall \
   maps \
   mapdata \
   mapproj \
   mda \
   prettydoc \
   pspearman \
   pwr \
   quantmod \
   raster \
   rasterly \
   rasterVis \
   SuppDists \
 && install2.r --repo https://nowosad.github.io/drat spDataLarge \
 && install2.r --repo https://mc-stan.org/r-packages cmdstanr \
 && installGithub.r datalorax/equatiomatic hadley/emo \
 && R -e 'webshot::install_phantomjs()'

RUN mkdir -p /opt/cmdstan \
  && curl -fLo cmdstan-${CMDSTAN_VERSION}.tar.gz https://github.com/stan-dev/cmdstan/releases/download/v${CMDSTAN_VERSION}/cmdstan-${CMDSTAN_VERSION}.tar.gz \
  && tar -xzf cmdstan-${CMDSTAN_VERSION}.tar.gz -C /opt/cmdstan/ \
  && cd ${CMDSTAN} \
  && make build

RUN mkdir -p ~/.fonts \
 && curl -fLo ~/.fonts/xkcd.ttf http://simonsoftware.se/other/xkcd.ttf \
 && curl -fLo Adobe-Fonts.zip https://github.com/XiangyunHuang/fonts/releases/download/v0.1/Adobe-Fonts.zip \
 && unzip Adobe-Fonts.zip -d ~/.fonts/adobe \
 && fc-cache -fsv \
 && R -e 'library(showtext);font_install(source_han_serif());font_install(source_han_sans());hrbrthemes::import_roboto_condensed()' \
 && R -e 'library(extrafont);font_import(pattern="[X/x]kcd.ttf", prompt = FALSE)'

# COPY requirements.txt ./
# RUN RETICULATE_PYTHON_ENV=/opt/.virtualenvs/r-tensorflow \
#   && virtualenv -p /usr/bin/python3 $RETICULATE_PYTHON_ENV \
#   && /bin/bash -c "source $RETICULATE_PYTHON_ENV/bin/activate; pip3 install -r requirements.txt; pip3 list --format=columns; deactivate"

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

# Set default timezone
ENV TZ UTC

WORKDIR /home/docker/

EXPOSE 8181

CMD ["Rscript", "-e", "sessionInfo()"]
