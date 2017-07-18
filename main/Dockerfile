From amazonlinux

Run yum install -y yum-utils
Run yum-config-manager --enable epel
Run yum -y update
Run yum install -y gcc openssl-devel geos-devel python27 python27-test python27-pip python27-devel
RUN `command -v pip` install -U pip
RUN `command -v pip` install -U boto boto3 awscli bokeh paramiko bytebuffer pandas shapely flexx

RUN ["mkdir", "-p", "/tmp/taxi"]
COPY ./* /tmp/taxi/
CMD ["/tmp/taxi/mapred.py", "-w", "-vv"]

