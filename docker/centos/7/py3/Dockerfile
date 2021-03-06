FROM centos:7 as builder
MAINTAINER richard.berger@outlook.com

RUN yum update -y && yum install -y epel-release
RUN yum install -y make gcc gcc-c++ gcc-gfortran cmake3 git
RUN yum install -y openmpi-devel libpng-devel libjpeg-devel openmpi-devel fftw-devel zlib-devel python36-devel blas-devel lapack-devel eigen3-devel

ENV PATH=/usr/lib64/openmpi/bin${PATH:+:}${PATH}
ENV LD_LIBRARY_PATH=/usr/lib64/openmpi/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}

ADD lammps /tmp/lammps

RUN mkdir -p /tmp/lammps/build && \
    cd /tmp/lammps/build && \
    git checkout $VERSION && \
    cmake3 -C /tmp/lammps/cmake/presets/most.cmake \
          -D CMAKE_BUILD_TYPE=Release \
          -D CMAKE_CXX_STANDARD=11 \
          -D CMAKE_INSTALL_PREFIX=/usr \
          -D LAMMPS_MACHINE=mpi \
          -D BUILD_LIB=on \
          -D BUILD_TOOLS=on \
          -D BUILD_SHARED_LIBS=on \
          -D PYTHON_EXECUTABLE=/usr/bin/python3 \
          -D PKG_USER-PLUMED=off \
          /tmp/lammps/cmake && \
    make -j 24 && \
    make install && \
    rm -rf /tmp/lammps/build /tmp/lammps/.git

FROM centos:7
MAINTAINER richard.berger@outlook.com
RUN useradd -m lammps
RUN yum update -y && yum install -y epel-release && yum install -y fftw libjpeg libpng python36 python36-pip blas lapack openmpi && yum clean -y all
COPY --from=builder /tmp/lammps /home/lammps
COPY --from=builder /usr/bin/lmp_mpi /usr/bin/lmp_mpi
COPY --from=builder /usr/lib64/liblammps.so.0 /usr/lib64/liblammps.so.0
COPY --from=builder /usr/lib64/liblammps.so /usr/lib64/liblammps.so
COPY --from=builder /usr/include/lammps/ /usr/include/lammps/
COPY --from=builder /usr/lib64/pkgconfig/liblammps.pc /usr/lib64/pkgconfig/liblammps.pc
COPY --from=builder /usr/share/cmake/Modules/FindLAMMPS.cmake /usr/share/cmake/Modules/FindLAMMPS.cmake
COPY --from=builder /usr/share/man/man1/lmp_mpi.1 /usr/share/man/man1/lmp_mpi.1
COPY --from=builder /usr/bin/binary2txt /usr/bin/binary2txt
COPY --from=builder /usr/bin/msi2lmp /usr/bin/msi2lmp
COPY --from=builder /usr/share/man/man1/msi2lmp.1 /usr/share/man/man1/msi2lmp.1
COPY --from=builder /usr/share/lammps /usr/share/lammps
COPY --from=builder /usr/lib64/python3.6/site-packages/lammps.py /usr/lib64/python3.6/site-packages/lammps.py
RUN chown -R lammps:lammps /home/lammps/

ENV LAMMPS_POTENTIALS=/usr/share/lammps/potentials
ENV PATH=/usr/lib64/openmpi/bin${PATH:+:}${PATH}
ENV LD_LIBRARY_PATH=/usr/lib64/openmpi/lib${LD_LIBRARY_PATH:+:}${LD_LIBRARY_PATH}
USER lammps
WORKDIR /home/lammps
CMD /usr/bin/lmp_mpi
